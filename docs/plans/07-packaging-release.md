# Phase 7 — Packaging and release

**Goal:** publicly distributable builds for macOS, Linux and Android with the USB permissions
in place, plus install docs. Distribution permission has been granted (PLAN.md §10), so
signing, notarisation and store listings are part of this phase rather than optional.

**Effort:** 3–4 days. **Hardware:** for smoke tests.

## macOS
- `flutter build macos --release`; hardened runtime on; sign with a Developer ID
  Application certificate; notarise with `notarytool`; staple; wrap in a DMG (`create-dmg`).
- Sandbox: leave **off** for direct distribution (simplest for libusb). If App Store
  distribution is ever wanted, enable sandbox and add `com.apple.security.device.usb`;
  re‑test device enumeration.
- Bundle `libusb-1.0.dylib` if the transport uses FFI (quick_usb ships its own).
- Smoke test on a clean user account: first launch, plug in, connect, identify.

## Linux
- `flutter build linux --release`; package as **AppImage** (`appimagetool`) with `libusb-1.0`
  bundled or declared; desktop file + icon.
- Ship `packaging/linux/60-dca75.rules` and a `install-udev-rule.sh`; the app shows a banner
  with the exact commands when it sees the device but gets `EACCES`.
- Optional Flatpak manifest (`--device=all`, `--share=ipc`, `--socket=wayland|x11`).
- Test on Ubuntu LTS and Fedora current, X11 and Wayland.

## Android
- `minSdk 26`, `targetSdk` current; `uses-feature android.hardware.usb.host required="true"`
  (so the Play listing filters to capable devices); `device_filter.xml`; intent filter for
  `ACTION_USB_DEVICE_ATTACHED` on the main activity with `launchMode="singleTask"`.
- Release signing config from a local keystore (not committed); `flutter build apk` for
  side‑loading (attached to GitHub releases) and `appbundle` for the Play Store listing.
- Play listing: screenshots, data‑safety form (no data leaves the device), USB host
  feature filter, privacy policy page (static, in the repo's `docs/`).
- Landscape and portrait layouts verified on a phone and a tablet.
- Document: OTG cable, permission dialog, powered hub note from Phase 2 findings, battery note.

## CI/CD
- Tag‑triggered workflow builds all three artefacts and attaches them to a GitHub release
  (macOS job needs secrets for signing/notarisation; without them it produces an unsigned
  build marked as such).
- Version from `pubspec.yaml`; `app_version` written into every session row.

## Licence and attribution
- Choose and add a licence file (MIT or Apache‑2.0 suggested) before the first public tag.
- Keep the reverse‑engineered dossier out of the repository; `ref-docs/dca-bench.html`
  may stay as the reference client now that distribution is cleared. State in the README
  that the project is not affiliated with Peak Electronic Design.

## Docs
- `README.md`: features, screenshots, install per platform, safety note, troubleshooting
  (Linux permissions, Android permission dialog, “device busy” if Peak's app/Chrome holds it).
- `docs/hardware-notes.md`: results of every hardware checklist from Phases 2, 3, 6.
- `CHANGELOG.md`.

## Acceptance criteria
- A fresh machine per platform can install from the artefact alone, plug in, connect, identify
  and run one sweep following only the README.
