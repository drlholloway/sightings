# Sightings — DCA75 Workbench

Companion application for the **Peak Atlas DCA75 (DCA Pro)** semiconductor
analyzer. Connects over USB, runs identify tests and curve sweeps, shows the
results, and keeps every reading in a local SQLite database so parts can be
compared, binned and reviewed later.

Targets: **macOS**, **Linux**, **Android** (USB host / OTG). An iOS viewer of
the database is planned; iPhones cannot talk to the unit directly.

**Help and how-tos:** the [Wiki](https://github.com/drlholloway/sightings/wiki) covers installation, first
steps, curves, the DCA55 and leakage measurements, parts and bins, troubleshooting and backups.

See [PLAN.md](PLAN.md) for the design and `docs/plans/` for the phase plans.

## Download

Ready-made builds are on the [Releases page](https://github.com/drlholloway/sightings/releases);
what changed in each version is in [CHANGELOG.md](CHANGELOG.md):

| Platform | File | Notes |
|---|---|---|
| macOS | `sightings-macos-<version>.zip` | Not notarized yet: on first launch use System Settings → Privacy & Security → **Open Anyway** (older macOS: right-click → Open). No driver needed. |
| Linux x86-64 (AppImage) | `Sightings-<version>-x86_64.AppImage` | `chmod +x`, run. Updates in place with AppImageUpdate. Bundles libusb; needs GTK 3 with GLib 2.72 or newer (Ubuntu 22.04, Debian 12 or later) and `libfuse2` on some distributions. Install the udev rule (see [Linux](#linux) below). |
| Linux x86-64 (Flatpak) | `sightings-linux-x64-<version>.flatpak` | `flatpak install --user <file>` (needs the Flathub remote for the runtime), then install the udev rule (see [Linux](#linux) below). GTK and libusb come with the runtime. |
| Linux x86-64 (tarball) | `sightings-linux-x64-<version>.tar.gz` | Extract, install the udev rule from the bundled README, run `./workbench`. Needs GTK 3 and libusb-1.0. |
| Android | `sightings-android-<version>.apk` | Open the APK on the phone; needs a USB OTG cable. |

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
sign and notarize before sharing.

### Linux
Three builds: an **AppImage** (single file, bundles libusb), a **Flatpak** bundle (brings its own
GTK and libusb) and a plain **tarball**. Whichever you use, install the udev rule once so the
app can open the device as a normal user. This command writes the rule and reloads udev, with
no file to download:

```sh
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04d8", ATTR{idProduct}=="f8ca", MODE="0660", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/60-dca75.rules >/dev/null && sudo udevadm control --reload && sudo udevadm trigger
```

The rules file itself is attached to every release and included in the tarball
(`sudo cp 60-dca75.rules /etc/udev/rules.d/`, then the two `udevadm` commands). Settings →
Linux USB access in the app has the command with a copy button. Then replug the unit. The
tarball also needs `libusb-1.0` from your distribution.

Still "access denied"? See the troubleshooting steps in
[`packaging/linux/README-linux.md`](packaging/linux/README-linux.md#if-it-shows-access-denied)
(covers SSH and remote sessions, where `uaccess` does not apply).

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

## Contributing

Bug reports with a `.dcalog` capture, wrong-reading reports, fixes with tests and wiki
corrections are all welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the setup, the pull
request checklist and the hard safety rules; the project follows the
[Contributor Covenant](CODE_OF_CONDUCT.md). Security problems go through
[private reporting](SECURITY.md), not public issues.

## License

[PolyForm Shield 1.0.0](https://polyformproject.org/licenses/shield/1.0.0), see `LICENSE`.
You may use, build, modify and share Sightings freely, including at work, but not use it
to make or sell anything that competes with it; any commercial edition is Cryptid Effects'
alone. The macOS, Linux and Android builds are free, and users of the builds are bound by
the End User License Agreement in `docs/EULA.md`.

Sightings is a Cryptid Effects project. Not affiliated with Peak Electronic Design Ltd.
