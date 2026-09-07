# Changelog

All notable changes to Sightings. The section for a tagged version becomes the
GitHub Release notes.

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
