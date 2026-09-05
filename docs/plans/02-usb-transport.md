# Phase 2 — USB transport (`packages/dca75_transport`)

**Goal:** a `DcaTransport` interface with (a) a real USB implementation working on macOS,
Linux and Android, and (b) a fake implementation that replays recorded exchanges for tests
and UI development. Also the gate decision on `quick_usb` versus a hand‑rolled FFI/platform
channel.

**Effort:** 3–6 days. **Hardware:** DCA75, macOS machine, Linux machine (or VM with USB
pass‑through), Android phone with USB host + OTG cable.

## Interface

```dart
abstract class DcaTransport {
  Stream<TransportEvent> get events;                 // attached, detached, error
  Future<List<DcaDeviceInfo>> listDevices();         // VID 0x04D8 / PID 0xF8CA only
  Future<void> open(DcaDeviceInfo dev);              // claim iface, resolve bulk IN/OUT endpoints
  Future<void> close();
  bool get isOpen;
  /// One serialised 64‑byte exchange. Enforces policy (forbidden opcodes, 0x5C), 3 s timeout,
  /// up to 3 retries on opcode mismatch, logs every transfer.
  Future<Response> exchange(Frame frame);
}
class TransportLog { /* ring buffer of (t, opcode, dir, bytes[0..8], durationMs, error) */ }
```

`exchange()` must serialise callers (a `Completer` chain / mutex) — this is what keeps the
device's request/response pairing intact when the poller and a sweep overlap.

## Tasks

1. **Endpoint discovery** — iterate configuration 1 interfaces/alternates, pick the first
   alt with a bulk IN and bulk OUT pair; claim it (Linux: `detachKernelDriver` where supported,
   though no kernel driver binds this vendor‑class device).

2. **`QuickUsbTransport`** — implement with `quick_usb`:
   `QuickUsb.init()`, `getDeviceList()` filtered by VID/PID, `openDevice`, `getConfiguration`,
   `claimInterface`, `bulkTransferOut(epOut, 64 bytes)`, `bulkTransferIn(epIn, 64, timeout)`,
   `releaseInterface`, `closeDevice`. Android additionally: `hasPermission` / `requestPermission`.
   Wrap each call with the 3 s timeout and map plugin exceptions to `TransportException`.

3. **Hot‑plug** — desktop: poll `listDevices()` every 1 s while disconnected (libusb hot‑plug
   callbacks are not exposed by the plugin); Android: `ACTION_USB_DEVICE_ATTACHED/DETACHED`
   broadcast via the plugin or a tiny `EventChannel`. Emit `TransportEvent.detached` when a
   transfer fails with a “no device” error so the service can clean up.

4. **`FakeTransport`** — two modes:
   - *Scripted*: a `Map<int opcode, List<Uint8List> responses>` FIFO plus an optional
     `Response Function(Frame)` handler for stateful behaviour (e.g. STATE returns TESTED
     after N polls). Used by unit tests of the device service and sweep engine.
   - *Replay*: loads a capture file (`.dcalog`, newline‑delimited `hex_out hex_in duration_ms`)
     recorded from the real transport and answers in order, asserting the outgoing frames match.
     Used for UI development without hardware and for regression tests of the sweep algorithms.

5. **Capture tool** — `tools/dca75_cli capture --out session.dcalog` uses the real transport
   and writes every exchange; `replay` drives `FakeTransport`. Record: connect + identify for a
   2N3904, 2N7000, 1N4148, an LED, a 78L05, a shorted pair, and empty clips → these become the
   golden frames for Phase 1 tests.

6. **Platform bring‑up checklist** (record results in `docs/hardware-notes.md`)
   - macOS: no driver; verify `ioreg -p IOUSB` shows the device; run STATE, confirm serial
     matches the sticker and firmware matches the unit's boot screen.
   - Linux: install udev rule, `udevadm control --reload && udevadm trigger`; run as a normal
     user; STATE round‑trip. Test on both X11 and Wayland sessions (irrelevant to USB but to
     the Flutter shell).
   - Android: plug in, accept the permission dialog, STATE round‑trip. **Power check**: with
     the AAA battery removed, does the unit boot and pass STATE + a full identify over OTG on
     the target phone? Then repeat with battery installed. Record current draw if a USB meter
     is available. Outcome decides whether a powered OTG hub is a documented requirement.
   - All: run 1 000 STATE exchanges in a loop; record p50/p95 latency and any mismatches.

7. **Gate decision** — after (6), decide: keep `quick_usb`, or replace with:
   - desktop: `dart:ffi` bindings to libusb‑1.0 (package `libusb` on pub or `ffigen` over
     `libusb.h`), bundling `libusb-1.0.dylib` in the macOS app and linking system libusb on Linux;
   - Android: a Kotlin `MethodChannel` (`list`, `open`, `claim`, `bulkOut`, `bulkIn`, `close`)
     over `UsbManager` / `UsbDeviceConnection.bulkTransfer` — about 150 lines.
   Both live behind the same interface, so nothing above the transport changes.

## Outcome (2026‑09‑05)

`quick_usb` was rejected before writing any code against it (last release four years old,
`ffi ^1.2` pin). Implemented instead:

- `LibusbTransport` in `dca75_transport`: hand‑written `dart:ffi` bindings for the dozen libusb
  calls needed, running in a **worker isolate** so the blocking `libusb_bulk_transfer` never
  stalls the UI; per‑transfer libusb timeout 2.5 s under the 3 s Dart timeout; device list polling
  for attach/detach; product/serial strings read at list time with `accessError` reported when the
  device cannot be opened (Linux udev hint).
- `AndroidUsbTransport` (Dart) + `UsbBridge.kt` in the app: `list`, `hasPermission`,
  `requestPermission`, `open`, `exchange`, `close` over a `MethodChannel`; attach/detach/permission
  over an `EventChannel`; transfers on a single background thread.
- `FakeTransport` (scripted/handler), `ScriptedDca` (behaves like a unit for STATE/CAL/ADCS/TEST/
  RGATE/CC/CV), `ReplayTransport` (`.dcalog`), and `encodeCapture`/`parseCapture`.
- CLI: `probe`, `identify [--wait] [--capture f.dcalog]`, `bench -n`, `replay`.

Hardware bring‑up and the Android power check are still pending (see `docs/hardware-notes.md`).

## Acceptance criteria
- `STATE` round‑trip succeeds on all three platforms with the serial/firmware shown.
- Forbidden opcodes and 0x5C cannot reach the wire (test with `FakeTransport` asserting
  `exchange` throws before any transfer).
- Latency loop: no opcode mismatches over 1 000 exchanges; p95 under 20 ms on desktop.
- Replay of a captured identify session decodes to the same result as live.
- Hardware notes document the Android power outcome.
