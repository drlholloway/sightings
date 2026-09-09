## What this changes

<!-- One or two sentences. Link the issue it addresses, if any: "Fixes #12". -->

## How it was tested

- [ ] `just test` passes locally (or `dart test` in the touched packages and `flutter test` in `apps/workbench`)
- [ ] `flutter analyze` is clean in `apps/workbench`
- [ ] Tested against a real DCA75 on: <!-- macOS / Linux / Android, or "demo device only" -->

## Checklist

- [ ] Decoder or protocol changes come with a golden frame captured from a real part
- [ ] Nothing here adds a way to write firmware, calibration or the serial number, or bypasses safe shutdown
- [ ] `CHANGELOG.md` has a line under **Unreleased** if users would notice this
- [ ] Wiki page updated, or noted below as needing an update
