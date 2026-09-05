// ignore_for_file: library_private_types_in_public_api
// Hand-written dart:ffi bindings for the small subset of libusb-1.0 that the
// DCA75 transport needs. Struct layouts follow libusb.h 1.0.30.
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

const int libusbErrorIo = -1;
const int libusbErrorInvalidParam = -2;
const int libusbErrorAccess = -3;
const int libusbErrorNoDevice = -4;
const int libusbErrorNotFound = -5;
const int libusbErrorBusy = -6;
const int libusbErrorTimeout = -7;
const int libusbErrorPipe = -9;
const int libusbEndpointIn = 0x80;
const int libusbTransferTypeBulk = 2;

final class LibusbDeviceDescriptor extends Struct {
  @Uint8()
  external int bLength;
  @Uint8()
  external int bDescriptorType;
  @Uint16()
  external int bcdUSB;
  @Uint8()
  external int bDeviceClass;
  @Uint8()
  external int bDeviceSubClass;
  @Uint8()
  external int bDeviceProtocol;
  @Uint8()
  external int bMaxPacketSize0;
  @Uint16()
  external int idVendor;
  @Uint16()
  external int idProduct;
  @Uint16()
  external int bcdDevice;
  @Uint8()
  external int iManufacturer;
  @Uint8()
  external int iProduct;
  @Uint8()
  external int iSerialNumber;
  @Uint8()
  external int bNumConfigurations;
}

final class LibusbEndpointDescriptor extends Struct {
  @Uint8()
  external int bLength;
  @Uint8()
  external int bDescriptorType;
  @Uint8()
  external int bEndpointAddress;
  @Uint8()
  external int bmAttributes;
  @Uint16()
  external int wMaxPacketSize;
  @Uint8()
  external int bInterval;
  @Uint8()
  external int bRefresh;
  @Uint8()
  external int bSynchAddress;
  external Pointer<Uint8> extra;
  @Int32()
  external int extraLength;
}

final class LibusbInterfaceDescriptor extends Struct {
  @Uint8()
  external int bLength;
  @Uint8()
  external int bDescriptorType;
  @Uint8()
  external int bInterfaceNumber;
  @Uint8()
  external int bAlternateSetting;
  @Uint8()
  external int bNumEndpoints;
  @Uint8()
  external int bInterfaceClass;
  @Uint8()
  external int bInterfaceSubClass;
  @Uint8()
  external int bInterfaceProtocol;
  @Uint8()
  external int iInterface;
  external Pointer<LibusbEndpointDescriptor> endpoint;
  external Pointer<Uint8> extra;
  @Int32()
  external int extraLength;
}

final class LibusbInterface extends Struct {
  external Pointer<LibusbInterfaceDescriptor> altsetting;
  @Int32()
  external int numAltsetting;
}

final class LibusbConfigDescriptor extends Struct {
  @Uint8()
  external int bLength;
  @Uint8()
  external int bDescriptorType;
  @Uint16()
  external int wTotalLength;
  @Uint8()
  external int bNumInterfaces;
  @Uint8()
  external int bConfigurationValue;
  @Uint8()
  external int iConfiguration;
  @Uint8()
  external int bmAttributes;
  @Uint8()
  external int maxPower;
  external Pointer<LibusbInterface> interface;
  external Pointer<Uint8> extra;
  @Int32()
  external int extraLength;
}

typedef _InitC = Int32 Function(Pointer<Pointer<Void>>);
typedef _InitD = int Function(Pointer<Pointer<Void>>);
typedef _ExitC = Void Function(Pointer<Void>);
typedef _ExitD = void Function(Pointer<Void>);
typedef _StrerrorC = Pointer<Utf8> Function(Int32);
typedef _StrerrorD = Pointer<Utf8> Function(int);
typedef _GetDeviceListC = IntPtr Function(
    Pointer<Void>, Pointer<Pointer<Pointer<Void>>>);
typedef _GetDeviceListD = int Function(
    Pointer<Void>, Pointer<Pointer<Pointer<Void>>>);
typedef _FreeDeviceListC = Void Function(Pointer<Pointer<Void>>, Int32);
typedef _FreeDeviceListD = void Function(Pointer<Pointer<Void>>, int);
typedef _GetDeviceDescriptorC = Int32 Function(
    Pointer<Void>, Pointer<LibusbDeviceDescriptor>);
typedef _GetDeviceDescriptorD = int Function(
    Pointer<Void>, Pointer<LibusbDeviceDescriptor>);
typedef _GetU8C = Uint8 Function(Pointer<Void>);
typedef _GetU8D = int Function(Pointer<Void>);
typedef _OpenC = Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>);
typedef _OpenD = int Function(Pointer<Void>, Pointer<Pointer<Void>>);
typedef _CloseC = Void Function(Pointer<Void>);
typedef _CloseD = void Function(Pointer<Void>);
typedef _GetActiveConfigC = Int32 Function(
    Pointer<Void>, Pointer<Pointer<LibusbConfigDescriptor>>);
typedef _GetActiveConfigD = int Function(
    Pointer<Void>, Pointer<Pointer<LibusbConfigDescriptor>>);
typedef _FreeConfigC = Void Function(Pointer<LibusbConfigDescriptor>);
typedef _FreeConfigD = void Function(Pointer<LibusbConfigDescriptor>);
typedef _HandleIntC = Int32 Function(Pointer<Void>, Int32);
typedef _HandleIntD = int Function(Pointer<Void>, int);
typedef _BulkC = Int32 Function(
    Pointer<Void>, Uint8, Pointer<Uint8>, Int32, Pointer<Int32>, Uint32);
typedef _BulkD = int Function(
    Pointer<Void>, int, Pointer<Uint8>, int, Pointer<Int32>, int);
typedef _StringDescC = Int32 Function(
    Pointer<Void>, Uint8, Pointer<Uint8>, Int32);
typedef _StringDescD = int Function(Pointer<Void>, int, Pointer<Uint8>, int);

/// Resolved libusb functions.
class Libusb {
  Libusb(this.lib)
      : init = lib.lookupFunction<_InitC, _InitD>('libusb_init'),
        exit = lib.lookupFunction<_ExitC, _ExitD>('libusb_exit'),
        strerror =
            lib.lookupFunction<_StrerrorC, _StrerrorD>('libusb_strerror'),
        getDeviceList = lib.lookupFunction<_GetDeviceListC, _GetDeviceListD>(
            'libusb_get_device_list'),
        freeDeviceList = lib.lookupFunction<_FreeDeviceListC, _FreeDeviceListD>(
            'libusb_free_device_list'),
        getDeviceDescriptor =
            lib.lookupFunction<_GetDeviceDescriptorC, _GetDeviceDescriptorD>(
                'libusb_get_device_descriptor'),
        getBusNumber =
            lib.lookupFunction<_GetU8C, _GetU8D>('libusb_get_bus_number'),
        getDeviceAddress =
            lib.lookupFunction<_GetU8C, _GetU8D>('libusb_get_device_address'),
        open = lib.lookupFunction<_OpenC, _OpenD>('libusb_open'),
        close = lib.lookupFunction<_CloseC, _CloseD>('libusb_close'),
        getActiveConfigDescriptor =
            lib.lookupFunction<_GetActiveConfigC, _GetActiveConfigD>(
                'libusb_get_active_config_descriptor'),
        freeConfigDescriptor = lib.lookupFunction<_FreeConfigC, _FreeConfigD>(
            'libusb_free_config_descriptor'),
        setAutoDetachKernelDriver =
            lib.lookupFunction<_HandleIntC, _HandleIntD>(
                'libusb_set_auto_detach_kernel_driver'),
        claimInterface = lib
            .lookupFunction<_HandleIntC, _HandleIntD>('libusb_claim_interface'),
        releaseInterface = lib.lookupFunction<_HandleIntC, _HandleIntD>(
            'libusb_release_interface'),
        bulkTransfer =
            lib.lookupFunction<_BulkC, _BulkD>('libusb_bulk_transfer'),
        getStringDescriptorAscii =
            lib.lookupFunction<_StringDescC, _StringDescD>(
                'libusb_get_string_descriptor_ascii');

  final DynamicLibrary lib;
  final _InitD init;
  final _ExitD exit;
  final _StrerrorD strerror;
  final _GetDeviceListD getDeviceList;
  final _FreeDeviceListD freeDeviceList;
  final _GetDeviceDescriptorD getDeviceDescriptor;
  final _GetU8D getBusNumber;
  final _GetU8D getDeviceAddress;
  final _OpenD open;
  final _CloseD close;
  final _GetActiveConfigD getActiveConfigDescriptor;
  final _FreeConfigD freeConfigDescriptor;
  final _HandleIntD setAutoDetachKernelDriver;
  final _HandleIntD claimInterface;
  final _HandleIntD releaseInterface;
  final _BulkD bulkTransfer;
  final _StringDescD getStringDescriptorAscii;

  String errorString(int code) {
    try {
      return strerror(code).toDartString();
    } catch (_) {
      return 'libusb error $code';
    }
  }

  /// Locate and load libusb-1.0. Search order: `DCA75_LIBUSB_PATH`, the
  /// application bundle / executable directory, then system locations.
  static DynamicLibrary load({String? explicitPath}) {
    final candidates = <String>[
      if (explicitPath != null) explicitPath,
      if (Platform.environment['DCA75_LIBUSB_PATH'] != null)
        Platform.environment['DCA75_LIBUSB_PATH']!,
    ];
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    if (Platform.isMacOS) {
      candidates.addAll([
        '$exeDir/../Frameworks/libusb-1.0.0.dylib',
        '$exeDir/libusb-1.0.0.dylib',
        '/opt/homebrew/lib/libusb-1.0.0.dylib',
        '/usr/local/lib/libusb-1.0.0.dylib',
        '/opt/local/lib/libusb-1.0.0.dylib',
        'libusb-1.0.0.dylib',
      ]);
    } else if (Platform.isLinux) {
      candidates.addAll([
        '$exeDir/lib/libusb-1.0.so.0',
        '$exeDir/libusb-1.0.so.0',
        'libusb-1.0.so.0',
        'libusb-1.0.so',
        '/usr/lib/x86_64-linux-gnu/libusb-1.0.so.0',
        '/usr/lib/aarch64-linux-gnu/libusb-1.0.so.0',
        '/usr/lib64/libusb-1.0.so.0',
        '/usr/lib/libusb-1.0.so.0',
      ]);
    } else if (Platform.isWindows) {
      candidates.addAll(['$exeDir/libusb-1.0.dll', 'libusb-1.0.dll']);
    }
    Object? last;
    for (final c in candidates) {
      try {
        return DynamicLibrary.open(c);
      } catch (e) {
        last = e;
      }
    }
    throw StateError(
        'libusb-1.0 not found (tried ${candidates.length} locations; last error: $last). '
        'Install it (brew install libusb / apt install libusb-1.0-0) or set DCA75_LIBUSB_PATH.');
  }
}
