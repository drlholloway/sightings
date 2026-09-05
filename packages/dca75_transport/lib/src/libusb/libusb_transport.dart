import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';

import '../transport.dart';
import 'worker.dart';

/// Desktop transport over libusb-1.0 via `dart:ffi`, executed in a worker
/// isolate so bulk transfers never block the caller. Works on macOS and
/// Linux (and Windows with WinUSB, untested).
class LibusbTransport extends SerializedTransport {
  LibusbTransport({
    this.libraryPath,
    super.timeout,
    super.maxAttempts,
    super.log,
  });

  final String? libraryPath;

  Isolate? _isolate;
  SendPort? _commands;
  Future<void>? _starting;
  Uint8List? _pendingOut;
  Future<Uint8List>? _pendingIn;
  Timer? _watch;
  Set<String> _lastSeen = {};

  Future<void> _ensureWorker() {
    if (_commands != null) return Future.value();
    return _starting ??= _start();
  }

  Future<void> _start() async {
    final rx = ReceivePort();
    final ready = Completer<void>();
    late StreamSubscription<dynamic> sub;
    sub = rx.listen((dynamic m) {
      if (m is SendPort) {
        _commands = m;
      } else if (m is List && m.isNotEmpty) {
        if (m[0] == 'ready') {
          ready.complete();
          sub.cancel();
        } else if (m[0] == 'init-failed') {
          ready.completeError(TransportException(
              TransportErrorKind.io, 'libusb unavailable: ${m[1]}'));
          sub.cancel();
        }
      }
    });
    _isolate = await Isolate.spawn(
        libusbWorkerMain, LibusbWorkerArgs(rx.sendPort, libraryPath),
        debugName: 'dca75-libusb');
    try {
      await ready.future;
    } catch (_) {
      _isolate?.kill();
      _isolate = null;
      _commands = null;
      _starting = null;
      rethrow;
    }
  }

  Future<T> _call<T>(List<Object?> msg) async {
    await _ensureWorker();
    final reply = ReceivePort();
    _commands!.send([...msg, reply.sendPort]);
    final dynamic r = await reply.first;
    reply.close();
    final list = r as List<dynamic>;
    if (list[0] == 'ok') return list[1] as T;
    final code = list[1] as String;
    final kind = switch (code) {
      'timeout' => TransportErrorKind.timeout,
      'disconnected' => TransportErrorKind.disconnected,
      'notFound' => TransportErrorKind.noDevice,
      'access' => TransportErrorKind.io,
      _ => TransportErrorKind.io,
    };
    throw TransportException(kind, list[2] as String);
  }

  @override
  Future<List<DcaDeviceInfo>> listDevices() async {
    final raw = await _call<List<dynamic>>(['list']);
    return raw
        .cast<Map<dynamic, dynamic>>()
        .where((m) => m['vid'] == usbVendorId && m['pid'] == usbProductId)
        .map((m) => DcaDeviceInfo(
              id: m['id'] as String,
              vendorId: m['vid'] as int,
              productId: m['pid'] as int,
              productName: m['product'] as String?,
              serialNumber: m['serial'] as String?,
              accessError: m['accessError'] as String?,
            ))
        .toList();
  }

  @override
  Future<void> open(DcaDeviceInfo device) async {
    await _call<void>(['open', device.id]);
    markOpen(device);
    emit(TransportEvent(TransportEventKind.attached, device: device));
  }

  @override
  Future<void> close() async {
    if (_commands == null) return;
    try {
      await _call<void>(['close']);
    } finally {
      markClosed();
    }
  }

  @override
  Future<void> transferOut(Uint8List bytes, Duration timeout) async {
    _pendingOut = Uint8List.fromList(bytes);
    _pendingIn =
        _call<Uint8List>(['xchg', _pendingOut, timeout.inMilliseconds]);
    // Surface OUT-side failures here; IN-side ones surface in transferIn.
    _pendingIn!.ignore();
  }

  @override
  Future<Uint8List> transferIn(Duration timeout) {
    final f = _pendingIn;
    _pendingIn = null;
    if (f == null) {
      return Future.error(TransportException(
          TransportErrorKind.io, 'transferIn without transferOut'));
    }
    return f;
  }

  /// Poll the device list every [interval] and emit attached / detached
  /// events for DCA75 units. Used while disconnected to auto-connect.
  void startWatching({Duration interval = const Duration(seconds: 1)}) {
    _watch?.cancel();
    _watch = Timer.periodic(interval, (_) async {
      try {
        final now = await listDevices();
        final ids = now.map((d) => d.id).toSet();
        for (final d in now) {
          if (!_lastSeen.contains(d.id)) {
            emit(TransportEvent(TransportEventKind.attached, device: d));
          }
        }
        for (final id in _lastSeen.difference(ids)) {
          if (openDevice?.id == id) {
            markClosed();
          }
          emit(TransportEvent(TransportEventKind.detached,
              device: DcaDeviceInfo(id: id), message: 'device unplugged'));
        }
        _lastSeen = ids;
      } catch (_) {}
    });
  }

  void stopWatching() {
    _watch?.cancel();
    _watch = null;
  }

  @override
  Future<void> dispose() async {
    stopWatching();
    await super.dispose();
    if (_commands != null) {
      try {
        await _call<void>(['exit']).timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
    _isolate?.kill();
    _isolate = null;
    _commands = null;
  }
}
