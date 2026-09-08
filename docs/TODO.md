# TODO

Tracked as GitHub issues; this file is the short index.

| # | Item | Notes |
|---|---|---|
| [#1](https://github.com/drlholloway/sightings/issues/1) ✅ | BJT readings at the DCA55's test conditions (done 2026‑09‑07) | DCA55 measures hFE at Ic 2.50 mA, Vce 2–3 V (confirmed from Peak's guide); DCA75 identify is fixed at 5 mA, so measure via the sweep engine and show a "DCA55‑equivalent" block. |
| [#2](https://github.com/drlholloway/sightings/issues/2) ✅ | Measure diode reverse leakage (done 2026‑09‑07) | MT2 sense path floors at ~1 µA; use the 470 kΩ gate path (nA resolution) at chosen reverse voltages. |
| [#3](https://github.com/drlholloway/sightings/issues/3) | Classify transistors and diodes for classic circuits | Circuit profiles (Fuzz Face Q1/Q2, Tone Bender, Rangemaster, Big Muff, clipping diode pairs) with per‑position rules on hFE, DCA55 hFE, leakage and Vf; "Fits" panel on readings and candidate/pair finder per circuit. |

Still open from the plan (no issue yet):

- **Release polish:** macOS notarization (needs an Apple Developer account); Mac App Store and
  Google Play listings, which need a demo mode so reviewers can exercise the app without a unit.
- **Hardware checks:** a reverse sweep on a zener; a numeric side‑by‑side of one sweep
  against Peak's own app. (Linux verified on Pop!_OS, 2026‑09‑07.)
- **Measurement refinement:** open‑clip calibration for the leakage measurement to cancel ADC
  gain mismatch (≈20 nA per 0.1 % at 10 V).
