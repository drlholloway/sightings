import 'dart:async';
import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:meta/meta.dart';

import 'transport_log.dart';

/// A USB device that looks like a DCA75.
class DcaDeviceInfo {
  const DcaDeviceInfo({
    required this.id,
    this.vendorId = usbVendorId,
    this.productId = usbProductId,
    this.productName,
    this.serialNumber,
    this.accessError,
  });

  /// Platform-specific handle (libusb address, Android device name, "fake").
  final String id;
  final int vendorId;
  final int productId;
  final String? productName;
  final String? serialNumber;

  /// Set when the device is visible but could not be opened for
  /// identification (Linux without the udev rule, for instance).
  final String? accessError;

  bool get isDca75 => vendorId == usbVendorId && productId == usbProductId;

  @override
  String toString() =>
      'DcaDeviceInfo($id ${productName ?? ''} ${serialNumber ?? ''})';
}

enum TransportEventKind { attached, detached, error }

class TransportEvent {
  const TransportEvent(this.kind, {this.device, this.message});
  final TransportEventKind kind;
  final DcaDeviceInfo? device;
  final String? message;

  @override
  String toString() =>
      'TransportEvent(${kind.name} ${device ?? message ?? ''})';
}

enum TransportErrorKind {
  notOpen,
  timeout,
  disconnected,
  io,
  mismatch,
  noDevice
}

class TransportException implements Exception {
  TransportException(this.kind, this.message, [this.cause]);
  final TransportErrorKind kind;
  final String message;
  final Object? cause;

  @override
  String toString() => 'TransportException(${kind.name}): $message';
}

/// Moves 64-byte frames to and from a DCA75.
abstract class DcaTransport {
  Stream<TransportEvent> get events;
  TransportLog get log;
  bool get isOpen;
  DcaDeviceInfo? get openDevice;

  Future<List<DcaDeviceInfo>> listDevices();
  Future<void> open(DcaDeviceInfo device);
  Future<void> close();

  /// One serialised exchange. Validates the frame against policy, sends it,
  /// reads the reply, and retries up to [maxAttempts] times if the reply's
  /// opcode does not echo the request. Every call is logged.
  ///
  /// [timeout] overrides the transport default for this exchange. The unit
  /// does not service USB while it runs an identify test (several seconds),
  /// so the STATE poll after TEST(1) needs a long one.
  Future<Response> exchange(Frame frame, {Duration? timeout});

  /// Release resources; the transport cannot be reused afterwards.
  Future<void> dispose();
}

/// Base class that implements the exchange discipline. Concrete transports
/// only provide [transferOut] / [transferIn] plus device management.
abstract class SerializedTransport implements DcaTransport {
  SerializedTransport({
    this.timeout = const Duration(seconds: 5),
    this.maxAttempts = 3,
    TransportLog? log,
  }) : log = log ?? TransportLog();

  final Duration timeout;
  final int maxAttempts;
  @override
  final TransportLog log;

  final _events = StreamController<TransportEvent>.broadcast();
  Future<void> _chain = Future<void>.value();
  DcaDeviceInfo? _openDevice;
  bool _disposed = false;

  @override
  Stream<TransportEvent> get events => _events.stream;
  @override
  DcaDeviceInfo? get openDevice => _openDevice;
  @override
  bool get isOpen => _openDevice != null;

  @protected
  void emit(TransportEvent e) {
    if (!_events.isClosed) _events.add(e);
  }

  @protected
  void markOpen(DcaDeviceInfo d) => _openDevice = d;
  @protected
  void markClosed() => _openDevice = null;

  /// Write exactly 64 bytes to the bulk OUT endpoint. [timeout] is the
  /// budget for this transfer.
  @protected
  Future<void> transferOut(Uint8List bytes, Duration timeout);

  /// Read up to 64 bytes from the bulk IN endpoint.
  @protected
  Future<Uint8List> transferIn(Duration timeout);

  @override
  Future<Response> exchange(Frame frame, {Duration? timeout}) {
    // Policy first: never enqueue a frame that must not be sent.
    final bytes = frame.bytes; // throws ProtocolPolicyError
    final completer = Completer<Response>();
    final budget = timeout ?? this.timeout;
    _chain = _chain.then((_) async {
      try {
        completer.complete(await _exchange(bytes, budget));
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<Response> _exchange(Uint8List out, Duration budget) async {
    if (_disposed) {
      throw TransportException(
          TransportErrorKind.notOpen, 'transport disposed');
    }
    if (!isOpen) {
      throw TransportException(TransportErrorKind.notOpen, 'not connected');
    }
    final want = out[0];
    final sw = Stopwatch()..start();
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      Uint8List inBytes;
      try {
        await _timed(transferOut(out, budget), budget);
        inBytes = await _timed(transferIn(budget), budget);
      } on TransportException catch (e) {
        log.add(TransportLogEntry(
            opcode: want,
            out: out,
            input: null,
            duration: sw.elapsed,
            error: e.toString()));
        if (e.kind == TransportErrorKind.disconnected) {
          markClosed();
          emit(TransportEvent(TransportEventKind.detached, message: e.message));
        }
        rethrow;
      }
      if (inBytes.length != frameLength) {
        log.add(TransportLogEntry(
            opcode: want,
            out: out,
            input: inBytes,
            duration: sw.elapsed,
            error: 'short read ${inBytes.length}'));
        throw TransportException(
            TransportErrorKind.io, 'short read: ${inBytes.length} bytes');
      }
      if (inBytes[0] == want) {
        log.add(TransportLogEntry(
            opcode: want, out: out, input: inBytes, duration: sw.elapsed));
        return Response(inBytes);
      }
      log.add(TransportLogEntry(
          opcode: want,
          out: out,
          input: inBytes,
          duration: sw.elapsed,
          error:
              'stale frame 0x${inBytes[0].toRadixString(16)} (wanted 0x${want.toRadixString(16)}), attempt $attempt'));
    }
    throw TransportException(TransportErrorKind.mismatch,
        'response mismatch after $maxAttempts tries for opcode 0x${want.toRadixString(16)}');
  }

  Future<T> _timed<T>(Future<T> f, Duration budget) => f.timeout(
      budget + const Duration(milliseconds: 500),
      onTimeout: () =>
          throw TransportException(TransportErrorKind.timeout, 'USB timeout'));

  @override
  @mustCallSuper
  Future<void> dispose() async {
    _disposed = true;
    if (isOpen) {
      try {
        await close();
      } catch (_) {}
    }
    await _events.close();
  }
}
