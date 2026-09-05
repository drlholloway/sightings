import 'dart:async';

import 'package:dca75_transport/dca75_transport.dart';
import 'package:flutter/services.dart';

/// Android transport over a small Kotlin bridge (`UsbBridge.kt`) that uses
/// `UsbManager` / `UsbDeviceConnection.bulkTransfer` on a background thread.
class AndroidUsbTransport extends SerializedTransport {
  AndroidUsbTransport({super.timeout, super.maxAttempts, super.log}) {
    _events.receiveBroadcastStream().listen(_onEvent, onError: (_) {});
  }

  static const _channel = MethodChannel('dca75/usb');
  static const _events = EventChannel('dca75/usb_events');

  Future<Uint8List>? _pendingIn;
  final _permission = <String, Completer<bool>>{};

  void _onEvent(dynamic e) {
    final m = (e as Map).cast<String, Object?>();
    switch (m['event']) {
      case 'attached':
        emit(TransportEvent(TransportEventKind.attached, device: _info(m)));
      case 'detached':
        final d = _info(m);
        if (openDevice?.id == d.id) markClosed();
        emit(
          TransportEvent(
            TransportEventKind.detached,
            device: d,
            message: 'device unplugged',
          ),
        );
      case 'permission':
        _permission.remove(m['id'] as String)?.complete(m['granted'] == true);
    }
  }

  DcaDeviceInfo _info(Map<String, Object?> m) => DcaDeviceInfo(
    id: m['id'] as String,
    vendorId: m['vid'] as int? ?? 0,
    productId: m['pid'] as int? ?? 0,
    productName: m['product'] as String?,
    serialNumber: m['serial'] as String?,
    accessError: m['hasPermission'] == false
        ? 'USB permission not granted'
        : null,
  );

  TransportException _map(PlatformException e) {
    final kind = switch (e.code) {
      'timeout' => TransportErrorKind.timeout,
      'disconnected' => TransportErrorKind.disconnected,
      'notFound' => TransportErrorKind.noDevice,
      'notOpen' => TransportErrorKind.notOpen,
      _ => TransportErrorKind.io,
    };
    return TransportException(kind, e.message ?? e.code, e);
  }

  Future<T> _call<T>(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args) as T;
    } on PlatformException catch (e) {
      throw _map(e);
    }
  }

  @override
  Future<List<DcaDeviceInfo>> listDevices() async {
    final raw = await _call<List<dynamic>>('list');
    return raw
        .map((e) => _info((e as Map).cast<String, Object?>()))
        .where((d) => d.isDca75)
        .toList();
  }

  Future<bool> requestPermission(DcaDeviceInfo d) async {
    if (await _call<bool>('hasPermission', {'id': d.id})) return true;
    final c = _permission.putIfAbsent(d.id, Completer.new);
    await _call<void>('requestPermission', {'id': d.id});
    return c.future.timeout(const Duration(minutes: 2), onTimeout: () => false);
  }

  @override
  Future<void> open(DcaDeviceInfo device) async {
    if (!await requestPermission(device)) {
      throw TransportException(TransportErrorKind.io, 'USB permission denied');
    }
    await _call<void>('open', {'id': device.id});
    markOpen(device);
  }

  @override
  Future<void> close() async {
    try {
      await _call<void>('close');
    } finally {
      markClosed();
    }
  }

  @override
  Future<void> transferOut(Uint8List bytes, Duration timeout) async {
    _pendingIn = _call<Uint8List>('exchange', {
      'data': Uint8List.fromList(bytes),
      'timeoutMs': timeout.inMilliseconds,
    });
    _pendingIn!.ignore();
  }

  @override
  Future<Uint8List> transferIn(Duration timeout) {
    final f = _pendingIn;
    _pendingIn = null;
    return f ??
        Future.error(
          TransportException(TransportErrorKind.io, 'no pending transfer'),
        );
  }
}
