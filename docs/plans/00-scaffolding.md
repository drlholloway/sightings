# Phase 0 — Scaffolding

**Goal:** a monorepo that builds and runs an empty Flutter shell on macOS, Linux and
Android, with CI, linting and the package boundaries in place so later phases only add code.

**Effort:** 1–2 days. **Hardware:** none.

## Tasks

1. **Toolchain**
   - Flutter stable (3.3x+), Dart 3.x with pub workspaces.
   - macOS: Xcode + CocoaPods. Linux: `clang cmake ninja-build pkg-config libgtk-3-dev libusb-1.0-0-dev`.
     Android: SDK 34+, NDK, a device with USB host support for later phases.
   - `flutter doctor` clean on both desktops.

2. **Repository layout**
   ```
   pubspec.yaml                  # workspace root: `workspace: [apps/workbench, packages/*, tools/*]`
   apps/workbench/               # flutter create --platforms=macos,linux,android --org dev.lane.dca75
   packages/dca75_protocol/      # dart create -t package
   packages/dca75_transport/     # plain Flutter package depending on quick_usb (FFI/platform-channel fallback lives here too)
   packages/dca75_store/         # dart package with drift + drift_dev
   tools/dca75_cli/              # dart CLI: capture, replay, decode frames
   docs/plans/                   # this directory
   ```

3. **Shared tooling**
   - `analysis_options.yaml` at root with `package:flutter_lints` + `strict-casts`, `strict-raw-types`.
   - `melos` is optional; pub workspaces + a `Makefile`/`justfile` with `test`, `analyze`, `format`, `run-macos`, `run-linux`, `run-android` is enough.
   - Pre‑commit: `dart format --set-exit-if-changed`, `dart analyze`.

4. **CI (GitHub Actions)**
   - `test.yml`: ubuntu + macos matrix; `flutter pub get`, `dart analyze`, `flutter test` across the workspace. Android build via `flutter build apk --debug` on ubuntu.
   - No hardware in CI; transport tests use the fake transport only.

5. **App shell**
   - `apps/workbench/lib/main.dart`: MaterialApp with a `NavigationRail` (desktop) / `NavigationBar` (phone) holding four destinations: Identify, Curves, History, Settings. All are placeholders.
   - Riverpod (`flutter_riverpod`) for state; `go_router` for navigation.
   - Adaptive breakpoints: < 840 dp = phone layout, otherwise two‑pane desktop layout.

6. **Platform configuration placeholders** (filled in Phase 2/7)
   - macOS: `Runner/DebugProfile.entitlements` and `Release.entitlements` — note where USB entitlement goes if sandboxing is ever enabled.
   - Linux: `linux/packaging/60-dca75.rules` committed now.
   - Android: `android/app/src/main/res/xml/device_filter.xml` with `<usb-device vendor-id="1240" product-id="63690" />`; `<uses-feature android:name="android.hardware.usb.host" />`.

7. **Docs**
   - Rewrite `README.md` to describe the actual targets (macOS, Linux, Android), point to `PLAN.md`, and give the one‑paragraph safety note (no firmware/EEPROM writes).

## Acceptance criteria
- `flutter run -d macos`, `-d linux`, and `-d <android>` each launch the shell.
- `dart test` runs (zero tests is fine) in every package from the workspace root.
- CI passes on a push.
