// Worker isolate that owns the libusb context and device handle. All libusb
// calls (which block) happen here so the UI isolate never stalls.
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'bindings.dart';

/// Message protocol (all lists):
///   ['list']                     -> ['ok', List<Map<String,Object?>>]
///   ['open', String id]          -> ['ok', null]
///   ['xchg', Uint8List out, int timeoutMs] -> ['ok', Uint8List in]
///   ['close']                    -> ['ok', null]
///   ['exit']                     -> ['ok', null] then the isolate ends
/// Errors: ['err', String code, String message]
/// where code is one of: timeout, disconnected, access, io, notFound, busy, init.
class LibusbWorkerArgs {
  const LibusbWorkerArgs(this.replyTo, this.libraryPath);
  final SendPort replyTo;
  final String? libraryPath;
}

void libusbWorkerMain(LibusbWorkerArgs args) {
  final commands = ReceivePort();
  args.replyTo.send(commands.sendPort);
  _Worker? w;
  try {
    w = _Worker(Libusb(Libusb.load(explicitPath: args.libraryPath)));
  } catch (e) {
    args.replyTo.send(['init-failed', e.toString()]);
    commands.close();
    return;
  }
  args.replyTo.send(['ready']);
  commands.listen((dynamic msg) {
    final m = msg as List<dynamic>;
    final reply = m.last as SendPort;
    try {
      switch (m[0] as String) {
        case 'list':
          reply.send(['ok', w!.list()]);
        case 'open':
          w!.open(m[1] as String);
          reply.send(['ok', null]);
        case 'xchg':
          reply.send(['ok', w!.exchange(m[1] as Uint8List, m[2] as int)]);
        case 'close':
          w!.close();
          reply.send(['ok', null]);
        case 'exit':
          w!.close();
          w.dispose();
          reply.send(['ok', null]);
          commands.close();
        default:
          reply.send(['err', 'io', 'unknown command ${m[0]}']);
      }
    } on _UsbError catch (e) {
      reply.send(['err', e.code, e.message]);
    } catch (e) {
      reply.send(['err', 'io', e.toString()]);
    }
  });
}

class _UsbError implements Exception {
  _UsbError(this.code, this.message);
  final String code;
  final String message;
}

class _Worker {
  _Worker(this.usb) {
    final ctxp = calloc<Pointer<Void>>();
    final rc = usb.init(ctxp);
    if (rc != 0) {
      calloc.free(ctxp);
      throw _UsbError('init', 'libusb_init failed: ${usb.errorString(rc)}');
    }
    ctx = ctxp.value;
    calloc.free(ctxp);
  }

  final Libusb usb;
  late final Pointer<Void> ctx;
  Pointer<Void> handle = nullptr;
  int iface = -1;
  int epIn = 0, epOut = 0;

  _UsbError _err(int rc, String what) {
    final code = switch (rc) {
      libusbErrorTimeout => 'timeout',
      libusbErrorNoDevice => 'disconnected',
      libusbErrorAccess => 'access',
      libusbErrorNotFound => 'notFound',
      libusbErrorBusy => 'busy',
      _ => 'io',
    };
    return _UsbError(code, '$what: ${usb.errorString(rc)} ($rc)');
  }

  List<Map<String, Object?>> list() {
    final listp = calloc<Pointer<Pointer<Void>>>();
    final n = usb.getDeviceList(ctx, listp);
    if (n < 0) {
      calloc.free(listp);
      throw _err(n, 'get_device_list');
    }
    final out = <Map<String, Object?>>[];
    final desc = calloc<LibusbDeviceDescriptor>();
    try {
      for (var i = 0; i < n; i++) {
        final dev = listp.value[i];
        if (usb.getDeviceDescriptor(dev, desc) != 0) continue;
        final d = desc.ref;
        out.add({
          'id': '${usb.getBusNumber(dev)}:${usb.getDeviceAddress(dev)}',
          'vid': d.idVendor,
          'pid': d.idProduct,
          ...(_strings(dev, d)),
        });
      }
    } finally {
      calloc.free(desc);
      usb.freeDeviceList(listp.value, 1);
      calloc.free(listp);
    }
    return out;
  }

  /// Product and serial strings require opening the device; failures are
  /// reported in `accessError` rather than thrown so listing never fails.
  Map<String, Object?> _strings(Pointer<Void> dev, LibusbDeviceDescriptor d) {
    if (d.idVendor != 0x04D8 || d.idProduct != 0xF8CA) {
      return const {'product': null, 'serial': null, 'accessError': null};
    }
    final hp = calloc<Pointer<Void>>();
    final rc = usb.open(dev, hp);
    if (rc != 0) {
      calloc.free(hp);
      return {
        'product': null,
        'serial': null,
        'accessError': usb.errorString(rc),
      };
    }
    final h = hp.value;
    calloc.free(hp);
    try {
      return {
        'product': _string(h, d.iProduct),
        'serial': _string(h, d.iSerialNumber),
        'accessError': null,
      };
    } finally {
      usb.close(h);
    }
  }

  String? _string(Pointer<Void> h, int index) {
    if (index == 0) return null;
    final buf = calloc<Uint8>(256);
    try {
      final n = usb.getStringDescriptorAscii(h, index, buf, 255);
      if (n <= 0) return null;
      return String.fromCharCodes(buf.asTypedList(n));
    } finally {
      calloc.free(buf);
    }
  }

  void open(String id) {
    close();
    final listp = calloc<Pointer<Pointer<Void>>>();
    final n = usb.getDeviceList(ctx, listp);
    if (n < 0) {
      calloc.free(listp);
      throw _err(n, 'get_device_list');
    }
    try {
      for (var i = 0; i < n; i++) {
        final dev = listp.value[i];
        if ('${usb.getBusNumber(dev)}:${usb.getDeviceAddress(dev)}' != id) {
          continue;
        }
        _openDevice(dev);
        return;
      }
      throw _UsbError('notFound', 'device $id is no longer present');
    } finally {
      usb.freeDeviceList(listp.value, 1);
      calloc.free(listp);
    }
  }

  void _openDevice(Pointer<Void> dev) {
    final hp = calloc<Pointer<Void>>();
    final rc = usb.open(dev, hp);
    if (rc != 0) {
      calloc.free(hp);
      throw _err(rc, 'open');
    }
    handle = hp.value;
    calloc.free(hp);
    try {
      _findEndpoints(dev);
      usb.setAutoDetachKernelDriver(handle, 1); // harmless where unsupported
      final crc = usb.claimInterface(handle, iface);
      if (crc != 0) throw _err(crc, 'claim_interface $iface');
    } catch (_) {
      usb.close(handle);
      handle = nullptr;
      rethrow;
    }
  }

  void _findEndpoints(Pointer<Void> dev) {
    final cfgp = calloc<Pointer<LibusbConfigDescriptor>>();
    final rc = usb.getActiveConfigDescriptor(dev, cfgp);
    if (rc != 0) {
      calloc.free(cfgp);
      throw _err(rc, 'get_active_config_descriptor');
    }
    try {
      final cfg = cfgp.value.ref;
      for (var i = 0; i < cfg.bNumInterfaces; i++) {
        final itf = cfg.interface[i];
        for (var a = 0; a < itf.numAltsetting; a++) {
          final alt = itf.altsetting[a];
          int? bin, bout;
          for (var e = 0; e < alt.bNumEndpoints; e++) {
            final ep = alt.endpoint[e];
            if ((ep.bmAttributes & 0x03) != libusbTransferTypeBulk) continue;
            if ((ep.bEndpointAddress & libusbEndpointIn) != 0) {
              bin ??= ep.bEndpointAddress;
            } else {
              bout ??= ep.bEndpointAddress;
            }
          }
          if (bin != null && bout != null) {
            iface = alt.bInterfaceNumber;
            epIn = bin;
            epOut = bout;
            return;
          }
        }
      }
      throw _UsbError('notFound', 'no bulk endpoint pair found');
    } finally {
      usb.freeConfigDescriptor(cfgp.value);
      calloc.free(cfgp);
    }
  }

  Uint8List exchange(Uint8List out, int timeoutMs) {
    if (handle == nullptr) throw _UsbError('io', 'not open');
    final buf = calloc<Uint8>(64);
    final xfer = calloc<Int32>();
    try {
      buf.asTypedList(64).setAll(0, out);
      var rc = usb.bulkTransfer(handle, epOut, buf, 64, xfer, timeoutMs);
      if (rc != 0) throw _err(rc, 'bulk out');
      rc = usb.bulkTransfer(handle, epIn, buf, 64, xfer, timeoutMs);
      if (rc != 0) throw _err(rc, 'bulk in');
      return Uint8List.fromList(buf.asTypedList(xfer.value));
    } finally {
      calloc.free(buf);
      calloc.free(xfer);
    }
  }

  void close() {
    if (handle == nullptr) return;
    if (iface >= 0) usb.releaseInterface(handle, iface);
    usb.close(handle);
    handle = nullptr;
    iface = -1;
  }

  void dispose() => usb.exit(ctx);
}
