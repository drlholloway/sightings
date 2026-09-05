import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';

import 'capture.dart';
import 'transport.dart';

/// Dynamic responder: return 64 bytes for the outgoing frame, or null to fall
/// through to the queued responses / default echo.
typedef FakeHandler = Uint8List? Function(Uint8List out);

/// In-memory transport for tests and hardware-free UI development.
///
/// Response resolution order for each outgoing frame:
/// 1. [handler], if set and it returns non-null;
/// 2. the next queued response for that opcode ([enqueue]);
/// 3. a default reply: the opcode echoed, everything else zero.
///
/// Every outgoing frame is recorded in [sent].
class FakeTransport extends SerializedTransport {
  FakeTransport({
    this.handler,
    this.devices = const [
      DcaDeviceInfo(id: 'fake', productName: 'DCA Pro', serialNumber: 'FAKE01')
    ],
    this.latency = Duration.zero,
    super.timeout,
    super.maxAttempts,
    super.log,
  });

  FakeHandler? handler;
  List<DcaDeviceInfo> devices;
  Duration latency;

  final List<Uint8List> sent = [];
  final _queues = <int, Queue<Uint8List>>{};
  Uint8List? _pendingIn;

  /// Whether the "device" currently answers. Set false to simulate a pull.
  bool present = true;

  void enqueue(int opcode, Uint8List response) =>
      _queues.putIfAbsent(opcode, Queue.new).addLast(response);

  void enqueueResponse(Response r) => enqueue(r.opcode, r.bytes);

  /// Opcodes of everything sent so far.
  List<int> get sentOpcodes => sent.map((b) => b[0]).toList();

  /// Frames sent for one opcode.
  List<Uint8List> sentFor(Opcode op) =>
      sent.where((b) => b[0] == op.code).toList();

  void clearSent() => sent.clear();

  /// Simulate the cable being pulled: subsequent transfers fail with
  /// `disconnected` and a detached event is emitted by the base class.
  void pull() => present = false;

  @override
  Future<List<DcaDeviceInfo>> listDevices() async => present ? devices : [];

  @override
  Future<void> open(DcaDeviceInfo device) async {
    if (!present) {
      throw TransportException(TransportErrorKind.noDevice, 'no device');
    }
    markOpen(device);
    emit(TransportEvent(TransportEventKind.attached, device: device));
  }

  @override
  Future<void> close() async {
    markClosed();
  }

  @override
  Future<void> transferOut(Uint8List bytes, Duration timeout) async {
    if (!present) {
      throw TransportException(TransportErrorKind.disconnected, 'device gone');
    }
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final copy = Uint8List.fromList(bytes);
    sent.add(copy);
    _pendingIn = handler?.call(copy) ??
        _queues[copy[0]]?.let((q) => q.isEmpty ? null : q.removeFirst()) ??
        _echo(copy[0]);
  }

  @override
  Future<Uint8List> transferIn(Duration timeout) async {
    if (!present) {
      throw TransportException(TransportErrorKind.disconnected, 'device gone');
    }
    final r = _pendingIn ?? _echo(0);
    _pendingIn = null;
    return r;
  }

  static Uint8List _echo(int opcode) => Uint8List(frameLength)..[0] = opcode;
}

extension<T> on T {
  R let<R>(R Function(T) f) => f(this);
}

/// Replays a `.dcalog` capture. Each outgoing frame must match the next
/// recorded one (whole frame when [strict], otherwise opcode only); the
/// recorded reply is returned. Records the same log format so a replay can
/// be diffed against the original.
class ReplayTransport extends SerializedTransport {
  ReplayTransport(this.lines,
      {this.strict = true, this.honourTiming = false, super.log})
      : super(timeout: const Duration(seconds: 3), maxAttempts: 1);

  factory ReplayTransport.fromText(String text,
          {bool strict = true, bool honourTiming = false}) =>
      ReplayTransport(parseCapture(text),
          strict: strict, honourTiming: honourTiming);

  final List<CaptureLine> lines;
  final bool strict;
  final bool honourTiming;
  int _cursor = 0;
  CaptureLine? _current;

  int get position => _cursor;
  int get remaining => lines.length - _cursor;
  bool get exhausted => _cursor >= lines.length;

  @override
  Future<List<DcaDeviceInfo>> listDevices() async =>
      const [DcaDeviceInfo(id: 'replay', productName: 'DCA Pro (replay)')];

  @override
  Future<void> open(DcaDeviceInfo device) async => markOpen(device);

  @override
  Future<void> close() async => markClosed();

  @override
  Future<void> transferOut(Uint8List bytes, Duration timeout) async {
    if (exhausted) {
      throw TransportException(
          TransportErrorKind.io, 'replay exhausted after $_cursor exchanges');
    }
    final line = lines[_cursor];
    final same = strict ? _same(line.out, bytes) : line.out[0] == bytes[0];
    if (!same) {
      throw ReplayMismatch(_cursor, line.out, bytes);
    }
    _current = line;
    _cursor++;
    if (honourTiming) {
      await Future<void>.delayed(
          Duration(microseconds: (line.durationMs * 1000).round()));
    }
  }

  @override
  Future<Uint8List> transferIn(Duration timeout) async {
    final c = _current;
    _current = null;
    final input = c?.input;
    if (input == null) {
      throw TransportException(
          TransportErrorKind.timeout, 'recorded exchange had no reply');
    }
    return Uint8List.fromList(input);
  }

  static bool _same(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class ReplayMismatch extends TransportException {
  ReplayMismatch(this.index, this.expected, this.actual)
      : super(TransportErrorKind.mismatch,
            'replay mismatch at exchange $index: expected ${hexDump(expected).split('\n').first}… got ${hexDump(actual).split('\n').first}…');
  final int index;
  final Uint8List expected;
  final Uint8List actual;
}

/// Convenience for tests: a [FakeTransport] whose STATE replies carry an
/// identity and whose TEST(2) reply is [result], with TESTED reported after
/// [testedAfterPolls] STATE polls following a TEST(1).
class ScriptedDca {
  ScriptedDca({
    this.serial = 'ABC123',
    this.hardware = 0x00A5,
    this.firmware = 0x0112,
    this.rMt2 = 618.5,
    this.result,
    this.testedAfterPolls = 2,
    this.unitButtonPress = false,
  }) {
    transport = FakeTransport(handler: _handle);
  }

  late final FakeTransport transport;
  final String serial;
  final int hardware, firmware;
  final double rMt2;
  Uint8List? result;
  int testedAfterPolls;

  /// When true the next STATE poll reports TESTED without a TEST(1), as if
  /// the button on the unit had been pressed.
  bool unitButtonPress;

  int _pollsSinceTest = -1;
  bool _tested = false;
  bool boosted = true;
  int ccStatus = 0x04;
  int cvStatus = 0x04;
  double rGateOhms = 470000;

  /// ADCS "always" block values returned on every ADCS.
  List<double> adcAlways = [0.5, 0.5, 0.5, 6.5, 5.26, 1.0, 4.0, 1.65];
  List<double> adcRails = [1.5, 1.2, 12.1, 5.0, 2.5];

  Uint8List? _handle(Uint8List out) {
    final op = out[0];
    final b = Uint8List(frameLength)..[0] = op;
    final d = ByteData.sublistView(b);
    switch (op) {
      case 0x86: // STATE
        var state = 0;
        if (unitButtonPress) {
          state = 2;
          _tested = true;
          unitButtonPress = false;
        } else if (_pollsSinceTest >= 0) {
          _pollsSinceTest++;
          if (_pollsSinceTest >= testedAfterPolls) {
            state = 2;
            _tested = true;
            _pollsSinceTest = -1;
          } else {
            state = 1;
          }
        } else if (_tested) {
          state = 2;
        }
        if (out[2] == 130 && _tested) {
          _tested = false; // acknowledged
          state = 2;
        }
        d.setUint8(2, state);
        d.setUint16(3, hardware, Endian.little);
        d.setUint16(5, firmware, Endian.little);
        for (var i = 0; i < 6; i++) {
          d.setUint16(7 + 2 * i, serial.codeUnitAt(i), Endian.little);
        }
        d.setFloat32(19, rMt2, Endian.little);
        return b;
      case 0x84: // CAL
        for (final (i, v)
            in [1000.0, 8200.0, 68000.0, 470000.0, rMt2].indexed) {
          d.setFloat32(2 + 4 * i, v, Endian.little);
        }
        return b;
      case 0x85: // TEST
        if (out[1] == 1) {
          _pollsSinceTest = 0;
          return b;
        }
        return result ?? b;
      case 0x83: // ADCS
        if (out[2] != 0) {
          for (final (i, v) in adcRails.indexed) {
            d.setFloat32(5 + 4 * i, v, Endian.little);
          }
        }
        for (final (i, v) in adcAlways.indexed) {
          d.setFloat32(25 + 4 * i, v, Endian.little);
        }
        return b;
      case 0x8B: // BOOSTED
        d.setUint8(1, boosted ? 1 : 0);
        return b;
      case 0x8E: // RGATE
        rGateOhms = switch (out[2]) {
          1 => 1000,
          2 => 8200,
          3 => 68000,
          _ => 470000,
        };
        d.setFloat32(3, rGateOhms, Endian.little);
        return b;
      case 0x94: // CCGATE
        if (out[2] == 3) d.setUint8(9, ccStatus);
        return b;
      case 0x95: // CVGATE
        if (out[2] == 3) d.setUint8(10, cvStatus);
        return b;
      default:
        return null; // echo
    }
  }
}
