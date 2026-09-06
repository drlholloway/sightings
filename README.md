# Sightings — DCA75 Workbench

Companion application for the **Peak Atlas DCA75 (DCA Pro)** semiconductor
analyser. Connects over USB, runs identify tests and curve sweeps, shows the
results, and keeps every reading in a local SQLite database so parts can be
compared, binned and reviewed later.

Targets: **macOS**, **Linux**, **Android** (USB host / OTG). An iOS viewer of
the database is planned; iPhones cannot talk to the unit directly.

See [PLAN.md](PLAN.md) for the design and `docs/plans/` for the phase plans.

## Safety

The app never writes to the unit's firmware, calibration or serial number.
Those opcodes cannot be constructed in the protocol library, and the EEPROM
write-arm status byte is rejected at the transport. Every error path returns
the unit to its leads-safe state.

## Layout

```
apps/workbench/            Flutter app (macOS, Linux, Android)
packages/dca75_protocol/   Pure Dart: frames, opcodes, decoders, lead tables, measurements
packages/dca75_transport/  Transport interface, libusb (dart:ffi) desktop transport, fake/replay transports
packages/dca75_device/     Typed client, connection controller (polling, drafts), sweep engine
packages/dca75_store/      SQLite via drift: readings, params, parts, bins, sweeps, stats
tools/dca75_cli/           decode / probe / identify / bench / replay from the terminal
packaging/                 udev rule, macOS libusb bundling
```

## Building

Requirements: Flutter stable (3.47+), and for desktop `libusb-1.0`
(`brew install libusb` / `apt install libusb-1.0-0-dev`). Android needs the
SDK (platform 36) and a JDK.

```sh
dart pub get
just test              # all package tests + widget tests
just run-macos         # or run-linux / run-android
```

Without `just`: `cd apps/workbench && flutter run -d macos`.

## Installing

### macOS
No driver needed. Run the app, plug the unit in, it connects automatically.
For a distributable build, `just build-macos` copies libusb into the bundle;
sign and notarise before sharing.

### Linux
Install the udev rule once so the app can open the device as a normal user:

```sh
sudo cp packaging/linux/60-dca75.rules /etc/udev/rules.d/
sudo udevadm control --reload && sudo udevadm trigger
```

Then replug the unit. `libusb-1.0` must be installed.

### Android
Use a USB OTG cable. When the unit is plugged in, Android offers to open the
app and asks for USB permission; accept it. If the unit does not power up
from the phone, use a powered OTG hub or keep the AAA battery in.

## Using it

- **Identify** — press *Test* (or the unit's own button). Results from the
  app are saved immediately; results from the unit button appear as a
  *draft* you can tag then *Save* (Enter) or *Discard* (Backspace). Tag a
  reading with a part number and bin to see where it falls among its
  siblings.
- **Curves** — Ic/Vce family, hFE vs Ic, Id/Vds, Id/Vgs, and PN I‑V sweeps,
  with live plotting, cancel, CSV/PNG export, and overlays of saved sweeps.
- **History** — filter, tag in bulk, export CSV, delete.
- **Parts** — per-part and per-bin statistics, histograms, closest-match
  search for transistor matching.
- **Settings** — backup/restore the database, re-decode readings, theme.

The app is called *Sightings*: every component you clip in is a sighting to be
identified, recorded and compared with the rest of its kind.

## Terminal tools

```sh
just probe                         # identity, calibration, rails
just identify --capture s.dcalog   # run a test, save the USB exchange log
just identify --wait -n 5          # collect five unit-button results
just bench -n 1000                 # latency / mismatch loop
```

## Status

Phases 0–6 of the plan are implemented and unit-tested against a fake
transport. Hardware validation is tracked in
[docs/hardware-notes.md](docs/hardware-notes.md).

## Licence

[PolyForm Shield 1.0.0](https://polyformproject.org/licenses/shield/1.0.0), see `LICENSE`.
You may use, build, modify and share Sightings freely, including at work, but not use it
to make or sell anything that competes with it; any commercial edition is Cryptid Effects'
alone. The macOS, Linux and Android builds are free, and users of the builds are bound by
the End User Licence Agreement in `docs/EULA.md`.

Sightings is a Cryptid Effects project. Not affiliated with Peak Electronic Design Ltd.
