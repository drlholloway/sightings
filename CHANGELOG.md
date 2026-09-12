# Changelog

All notable changes to Sightings. The section for a tagged version becomes the
GitHub Release notes.

## 0.3.4 — 2026-09-12

### Fixed
- **Linux packaging** (issue #13, thanks to KnatterKnilch): the AppImage and tarball are
  now built on Ubuntu 22.04, so they run on distributions with GLib 2.72 or newer (Ubuntu
  22.04, Debian 12, Linux Mint 21, Pop!_OS 22.04) instead of requiring GLib 2.80. The
  Flatpak now really bundles libusb (built without the udev backend, so the sandbox needs
  nothing from /run/udev), the loader looks in /app/lib, and the "install libusb" hint no
  longer appears inside a Flatpak where it cannot help.
- With both *Also measure at DCA55 conditions* and *Also measure reverse leakage* on, a
  saved transistor identify started the two follow-ups at once and the leakage one failed
  with "device is busy". They now run one after the other.
- The Circuits page no longer claims diode profiles judge gain by hFE.

### Changed
- Demo device: an optional part-to-part spread (used by the screenshot tour; off in the
  app) so repeated identifies of the same demo part vary like a bag of real ones.
- Developer: `just tour` builds the app with a screenshot tour that walks every screen
  against the demo device and writes PNGs for the wiki.

## 0.3.3 — 2026-09-09

### Added
- **Outlier warnings in bin statistics.** Percentiles stay raw, but readings outside Tukey's
  fences (1.5 × IQR beyond the quartiles, once a bin has five or more values) are flagged:
  a warning under "Where does this fall?" on a reading, an outliers column in the bin table
  and a marker on the affected member chips.
- **Linux AppImage** on the Releases page next to the Flatpak and tarball: one executable file
  with libusb bundled; needs GTK 3 from the distribution.

## 0.3.2 — 2026-09-08

Maintenance release driven by Dependabot: every dependency and GitHub Action it flagged
is now current, and one of those bumps carries a security fix.

### Security
- **file_picker 10.3 → 12.2** includes the upstream fix for a path-traversal
  vulnerability (CWE-22) when resolving file paths handed over by Android content
  providers. Sightings uses that path when you pick a backup file to restore on Android.
- GitHub Actions used by the CI and release pipelines updated to their current majors
  (checkout 7, upload-artifact 7, download-artifact 8, setup-java 6, action-gh-release 3).
- No open Dependabot security alerts against the project at the time of release.

### Fixed
- macOS release builds keep their entitlements when the app is ad-hoc re-signed after
  bundling libusb. Previous releases lost them, which made the file picker refuse to
  open the Backup and Restore dialogs on macOS.

### Changed
- Dependency refresh: riverpod 3, go_router 18, share_plus 13, package_info_plus 10;
  Android build moved to AGP 9.4 / Gradle 9.7 / Kotlin 2.4.10 with built-in Kotlin.
- Backup now snapshots the database to a temporary file and hands the bytes to the save
  dialog, which writes them itself. Behavior is unchanged from the user's side.

## 0.3.1 — 2026-09-08

### Added
- **Linux Flatpak bundle** on the Releases page alongside the tarball: installs with
  `flatpak install --user`, brings GTK and libusb with the Freedesktop runtime; the udev rule is
  still installed by hand.

## 0.3.0 — 2026-09-07

### Added
- **Pedal Builder.** A Settings switch adds a Circuits tab with classic pedal circuits (germanium
  and silicon Fuzz Face, Tone Bender MkII, Rangemaster, Big Muff, silicon/germanium/LED clipping
  diodes), each with its positions and the accepted ranges for gain, leakage and Vf, editable with
  reset to defaults and an active switch per circuit. Every transistor and diode reading then gets a
  "Pedal circuits" card listing the positions it is valid for, and why it misses the others.
  Germanium gain rules read the DCA55-equivalent hFE when it has been measured.
- **Demo device.** A Settings switch runs the app against a simulated DCA75 built from real
  captured parts (2N5088, MP40A, J201, silicon and germanium diodes): identify, unit-button
  drafts, every sweep, the DCA55-equivalent and leakage measurements all work with no
  hardware. A banner shows the part "clipped in" with **Press unit button** and **Next part**
  controls; demo readings are recorded under a demo session and can be deleted in one go.

## 0.2.1 — 2026-09-07

### Added
- **Buy me a coffee** link in Settings → About, and in the macOS "About Sightings" panel
  along with a link to the source. Sightings stays free; tips are welcome.
- **Wiki**: installation, first steps, curves, the DCA55 and leakage measurements, parts
  and bins, troubleshooting, backups and building from source, linked from the README.

### Changed
- American spellings throughout the app text and documentation (analyzer, license,
  color, notarized…). The EULA row now reads "End User License Agreement".
- The macOS About panel shows the real copyright line instead of the template placeholder.

## 0.2.0 — 2026-09-07

### Added
- **DCA55-equivalent figures for transistors.** After a saved BJT identify the app holds
  Vce at 2.5 V, servos the base current until Ic = 2.50 mA (the Peak DCA55's published test
  conditions) and reports hFE with leakage subtracted, plus Vbe at that point and at a forced
  base current. Shown under the DCA75 result, stored with the reading and available in bin
  statistics. Automatic (Settings switch) or on demand.
- **Reverse leakage with nA resolution** for diodes (Ir) and for a transistor's
  collector–base junction (Icbo), at 5 V and 10 V, measured through the unit's 470 kΩ gate
  path so the current can never exceed ~25 µA. The DAC is servoed so the junction really
  sees the requested voltage; a leaky part reports the voltage actually reached.
- **Reverse leakage I‑V sweep** on the Curves tab.
- App icon on every platform.

### Changed
- The Curves tab offers only the sweeps that apply to the identified component, and
  switches to the first applicable sweep after each identify.
- Diode sweeps take their anode/cathode from the identify result instead of a fixed default.
- Readings written by an older decoder are re-decoded automatically when the database opens.

### Fixed
- JFET gfs and MOSFET gm were shown a thousand times too large (the unit reports mS).
- Two BJT fields labeled as base currents are the collector test currents for the Vbe
  readings; relabeled.

## 0.1.0 — 2026-09-06

First public release: identify with pinout by lead color, unit-button results as drafts,
tagging into parts and bins with percentile and histogram views, five curve sweeps with live
plotting and overlays, SQLite storage with backup and restore, CSV/PNG export, USB log.
Builds for macOS, Linux (x86-64) and Android.
