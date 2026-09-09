# Contributing to Sightings

Thanks for your interest. Sightings is a small project maintained by one person, so the
most useful contributions are focused ones: a clear bug report with a capture attached, a
reading from a part the decoder gets wrong, a fix with a test, or a wiki correction.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to help

- **Report a bug.** Use the *Bug report* issue form. If the unit was involved, open **Log**
  (terminal icon in the header), export a `.dcalog` capture and attach it. It contains only
  the USB exchange with the unit, no personal data.
- **Report a wrong reading.** Use the *Wrong reading* form. A `.dcalog` capture plus what
  Peak's own app or the unit's screen shows for the same part is exactly what is needed to
  fix a decoder.
- **Suggest a feature.** Use the *Feature request* form. Check `docs/TODO.md` and the
  [wiki](https://github.com/drlholloway/sightings/wiki) first; it may already be planned.
- **Improve the wiki.** It is a normal GitHub wiki; edits are welcome. American spelling,
  please, to match the app.
- **Add a circuit profile** to the Pedal Builder (`packages/dca75_circuits/lib/src/defaults.dart`)
  with a source for the rules you encode.

## Development setup

Requirements: Flutter stable 3.47 or newer, `libusb-1.0` for desktop
(`brew install libusb` / `apt install libusb-1.0-0-dev`), and for Android the SDK
(platform 36) plus JDK 17 or newer.

```sh
git clone https://github.com/drlholloway/sightings.git
cd sightings
dart pub get
just test                      # every package's tests plus the widget tests
just run-macos                 # or run-linux / run-android
```

Without `just`: run `dart test` in each package under `packages/` and `tools/`, and
`flutter test` / `flutter run -d macos` in `apps/workbench`.

No unit? Turn on **Demo device** in Settings. It simulates a DCA75 from real captured frames,
and most of the app can be exercised against it. `ScriptedDca` and the replay transport in
`packages/dca75_transport` do the same for tests.

The layout is described in the README. In short: `dca75_protocol` is pure Dart with no I/O,
`dca75_transport` talks USB, `dca75_device` drives the unit, `dca75_store` is the database,
`dca75_circuits` is the Pedal Builder rules, and `apps/workbench` is the Flutter app.

## Pull requests

1. Open an issue first for anything beyond a small fix, so the approach can be agreed before
   you spend time on it.
2. Branch from `main`. Keep a PR to one change.
3. Add or update tests. Decoder changes need a golden frame in
   `packages/dca75_protocol/test/golden/` captured from a real part.
4. Run `dart format .`, `flutter analyze` in `apps/workbench`, and `just test`. CI runs the
   same on macOS, Linux and Android.
5. Add a line under **Unreleased** in `CHANGELOG.md` if users would notice the change.
6. Fill in the PR template. Say what hardware you tested on, or that you tested against the
   demo device only.

## Hard rules

These are safety properties of the app and are not negotiable:

- **Never add a way to write to the unit's firmware, calibration or serial number.** The
  forbidden opcodes are rejected in `dca75_protocol` and the EEPROM write-arm byte is
  rejected in `dca75_transport`; tests pin both. A PR that loosens them will be closed.
- **Every error path must return the unit to its leads-safe state.** Sweeps and measurements
  go through the sweep engine's safe shutdown for this reason; do not bypass it.
- **No telemetry, accounts or network calls** from the app. Readings stay on the device.

## Licensing of contributions

Sightings is licensed under [PolyForm Shield 1.0.0](LICENSE). By submitting a contribution
you agree that it is licensed under the same terms and that Cryptid Effects may include it
in any edition of Sightings, including a commercial one. Please do not submit code copied
from Peak's software or from other projects under incompatible licenses.

## Questions

Open an issue with the *Question* label, or start from the
[Troubleshooting](https://github.com/drlholloway/sightings/wiki/Troubleshooting) page.
