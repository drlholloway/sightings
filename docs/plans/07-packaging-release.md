# Phase 7 — Packaging and release

**Goal:** publicly distributable builds for macOS, Linux and Android with the USB permissions
in place, plus install docs. Distribution permission has been granted (PLAN.md §10), so
signing, notarization and store listings are part of this phase rather than optional.

**Effort:** 3–4 days. **Hardware:** for smoke tests.

## macOS
- `flutter build macos --release`; hardened runtime on; sign with a Developer ID
  Application certificate; notarize with `notarytool`; staple; wrap in a DMG (`create-dmg`).
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
- Flatpak manifest (`--device=all`, `--share=ipc`, `--socket=wayland|x11`); both AppImage and
  Flatpak are shipped (decided 2026‑09‑08), built by `packaging/appimage/build-appimage.sh`
  and `packaging/flatpak/`.
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
  (macOS job needs secrets for signing/notarization; without them it produces an unsigned
  build marked as such).
- Version from `pubspec.yaml`; `app_version` written into every session row.

## License and attribution
- `LICENSE` is PolyForm Shield 1.0.0 with a Required Notice; `docs/EULA.md` holds the
  users' terms for the builds (shown in About and bundled as `assets/EULA.md`, keep the two
  in sync). Free on every platform; a free Play listing cannot later become paid. Once the
  repository is public, Actions minutes are free and the macOS CI jobs can run on every push.
- Keep the reverse‑engineered dossier out of the repository. State in the README and the
  App that the project is not affiliated with Peak Electronic Design.

## Docs
- `README.md`: features, screenshots, install per platform, safety note, troubleshooting
  (Linux permissions, Android permission dialog, “device busy” if Peak's app/Chrome holds it).
- `docs/hardware-notes.md`: results of every hardware checklist from Phases 2, 3, 6.
- `CHANGELOG.md`.

## Acceptance criteria
- A fresh machine per platform can install from the artefact alone, plug in, connect, identify
  and run one sweep following only the README.
