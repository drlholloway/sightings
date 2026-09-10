# Sightings (DCA75 Workbench)

Companion app for the Peak Atlas DCA75 (DCA Pro) semiconductor analyzer:
connect over USB, run identify tests and curve sweeps, keep every reading in
a local SQLite database, compare and bin parts. Targets macOS, Linux and
Android; iPhones cannot talk to the unit, so iOS is a future viewer only.
Product name **Sightings**, subtitle DCA75 Workbench; internal identifiers
(`workbench` package, `dev.laneholloway.workbench` bundle id) are unchanged.

Read `PLAN.md` first (design, decisions, phase table), then `docs/plans/` for
the phase you are touching. `docs/TODO.md` is the short index of open work,
`docs/hardware-notes.md` records what has been verified on a real unit, and
`CHANGELOG.md` becomes the GitHub release notes.

## Layout

Pub workspace; dependencies flow strictly downward.

- `packages/dca75_protocol/` — pure Dart, no I/O: frames, opcodes, decoders,
  lead tables, derived measurements. Golden frames from real parts live in
  `test/golden/`.
- `packages/dca75_transport/` — transport interface, policy enforcement,
  logging, fake and replay transports; the libusb (`dart:ffi`) desktop
  transport.
- `packages/dca75_device/` — typed client, connection controller (state
  machine, polling, drafts), sweep engine, DCA55-equivalent and leakage
  measurements, demo device.
- `packages/dca75_circuits/` — Pedal Builder circuit profiles and fit rules.
- `packages/dca75_store/` — SQLite via drift: readings, sweeps, parts, bins,
  stats. Regenerate with `just codegen` after schema changes.
- `tools/dca75_cli/` — decode, probe, identify, bench, replay from the terminal.
- `apps/workbench/` — Flutter app (Riverpod, go_router, shared_preferences)
  plus the Kotlin USB bridge for Android.
- `packaging/` — udev rule, AppImage, Flatpak, macOS libusb bundling, icon script.
- `ref-docs/` — gitignored. The reference WebUSB client the protocol was
  ported from is kept locally only. Never `git add` it or quote it in
  committed files.

## Commands

```sh
dart pub get
just test          # every package's tests + widget tests
just analyze       # dart analyze + flutter analyze
just codegen       # drift code generation
just run-macos     # or run-linux / run-android
just probe         # talk to a plugged-in unit (also identify, bench)
```

Shell PATH needs `/opt/homebrew/bin` for `flutter`; desktop builds need
`libusb-1.0` (`brew install libusb`). No unit attached? Turn on **Demo
device** in Settings, or use `ScriptedDca` and the replay transport in tests.
Run `dart format .`, `just analyze` and `just test` before finishing a change.

## Hard rules (safety)

- **Never add a way to write the unit's firmware, calibration or serial
  number.** Opcodes 0x88 (BOOTL) and 0x87 (LOCK) cannot be constructed in
  `dca75_protocol`; the EEPROM write-arm status byte (0x5C) is rejected in
  `dca75_transport`. Tests pin both. Do not loosen them.
- **Every error path returns the unit to its leads-safe state.** Sweeps and
  measurements go through the sweep engine's safe shutdown; do not bypass it.
- No telemetry, accounts or network calls. Readings stay on the device.

## Conventions

- American spelling in code, UI text, docs and the wiki.
- Pinouts are shown by lead color (red, green, blue); the config tables in
  `dca75_protocol` map lead colors to E/B/C, MT1/MT2/GATE and so on.
- Decoder changes need a golden frame captured from a real part, plus what
  the unit's screen or Peak's app showed for it.
- Identify results from the unit's own button land as **drafts**; tests
  started from the app save immediately. Keep that default.
- Raw 64-byte frames are stored verbatim so readings can be re-decoded after
  a decoder fix (Settings → re-decode).
- Add a line under **Unreleased** in `CHANGELOG.md` for anything users would
  notice; update the wiki page or note that it needs updating.

## Licensing and distribution decisions

Source is public under PolyForm Shield 1.0.0; all builds are free; only
Cryptid Effects may publish a paid edition; users are bound by
`docs/EULA.md`. Do not propose MIT/Apache/GPL (they would allow competing
paid editions) and do not re-raise the distribution question. Details in
`PLAN.md` section 10.

## Git and releases

- Commit only when asked. Push over SSH; the `gh` token lacks the `workflow`
  scope, so workflow-file changes (including Dependabot's Actions bumps)
  cannot be merged through `gh pr merge`.
- Release: fold **Unreleased** into a dated `## X.Y.Z` section, bump
  `version:` in `apps/workbench/pubspec.yaml` and the Flatpak metainfo,
  commit `Release X.Y.Z`, `git tag -a vX.Y.Z -m "Sightings X.Y.Z"`, push
  branch and tag. The `release` workflow builds the macOS zip, Linux
  tarball/AppImage/Flatpak and the signed Android APK, and publishes the
  release with the changelog section as notes.
- Android signing uses the `ANDROID_*` repo secrets; the keystore is
  `apps/workbench/android/app/sightings-release.jks` with `key.properties`
  beside it, both gitignored. Never regenerate it.
