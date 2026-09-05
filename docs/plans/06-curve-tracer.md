# Phase 6 — Curve tracer

**Goal:** the five sweep types from the reference client, run by a cancellable
`SweepEngine`, plotted live, saved to the datastore, exportable, and comparable against
saved sweeps. Lives in `apps/workbench/lib/curves/` with the algorithms in a testable
`sweep_engine` library that depends only on `dca75_protocol` and `DcaTransport`.

**Effort:** 5–8 days. **Hardware:** required for validation.

## Engine

```dart
abstract class Sweep {
  SweepKind get kind; String get xLabel, yLabel;
  bool canRun(IdentifyResult? last);                    // BJT for icvce/hfeic, JFET/MOSFET for idvds/idvgs, none for pniv
  SweepParams defaultsFor(IdentifyResult? last);         // applyResultDefaults port
  Stream<SweepEvent> run(DeviceSession dev, SweepParams p, CancelToken c);   // traceStarted, point, progress, traceEnded, done, error
}
```

`DeviceSession` wraps the transport with the mid‑level helpers from the reference `DCA`
class: `boostOn/boosted/boostOff/boostWait`, `trnPowerOn/trnSetVc/trnSetVgate`,
`fetPowerOn/fetSetVgs/fetSetVdsVgs/fetSetVds`, `setGateCurrent/stopGateCurrent/
waitForCcOneShot`, `setGateVoltage/stopGateVoltage/waitForCvOneShot`, `setRGate`,
`pickRGateBelow`, `readAdcsBurst`, `leadsSafe`, `mode`, plus the `DeviceMirror` for
`ic/vce/vbe/ib`.

Sweeps to port (keep every constant and guard):

| Kind | Reference | Key details to preserve |
|---|---|---|
| `icvce` | `SWEEPS.icvce` | R‑gate walk to `10200/ib`; boost 12.5 V; `trnPowerOn(cfg,7,12)`; CC one‑shot burst 200 ms; stop trace at Ic > 12 mA; LEADSAFE between traces |
| `hfeic` | `SWEEPS.hfeic` | Vce servo: up to 20 iterations, gain 0.9, tolerance 3 mV or 0.1 %; leakage floor via 470k + gate 0 V, `readAdcsBurst(24)`; hFE = (Ic − Ic0)/Ib |
| `idvds` | `SWEEPS.idvds` | R‑gate 8k2; `fetPowerOn` sends raw cfg; CV gate ON each point; one‑shot burst 500 ms |
| `idvgs` | `SWEEPS.idvgs` | Three‑phase Vds servo (double, bisect, LSB step 0.0033341474), 64‑iteration cap; `readAdcsBurst(248)`; x = `vbe(cfg)` |
| `pniv` | `SWEEPS.pniv` | `configFrom12G` + `revM1M2` for reverse; MATRIXRGB drive map; third‑lead options (open, 470k→Vs, 470k→0 V, low‑Ω to anode/cathode via BRIDGEGATE); boost `0.5 + max(vMin,vMax)` |

Common frame around each run: `MODE ANALOG_USB` → `LEADSAFE` → sweep → `LEADSAFE` →
`MODE NONE`; on cancel or exception → `safeShutdown()`. Timing delays (3, 20, 24, 50 ms and
the 300 ms boost wait) are kept as named constants.

## Plotting

Port `drawPlot`/`niceTicks` to a `CustomPainter` (`CurvePlot`): auto‑ranging with the
same zero‑snapping rules, grid, axis labels, legend, 8‑colour palette, hover/touch read‑out,
theme‑aware colours. `RepaintBoundary` + `toImage` for PNG export. Overlay mode: any number
of saved sweeps drawn together with distinct palettes and a legend grouped by sweep.

## UI (Curves screen)
- Curve type selector; parameter form generated from `CURVE_DEFS` (same fields and defaults,
  incl. anode/cathode/third‑lead/bias for PN I‑V); defaults auto‑filled from the last identify
  result (`applyResultDefaults`).
- Start/Stop button, progress bar, status line, plot, “save with reading #N” checkbox
  (pre‑checked when a matching identify result exists), Clear, CSV, PNG.
- Right pane / bottom sheet: saved sweeps for the current reading or part with checkboxes to
  overlay. “Compare bin” overlays the same sweep kind across selected readings in a bin.
- Cancel is immediate at the next await point; the engine drains to `safeShutdown()`.

## Persistence
- On done/cancel/error, `ReadingsRepository.saveSweep` with params JSON, labels, traces,
  duration and error text. Cancelled partial sweeps are saved (flag set) unless empty.

## Tests
- Engine tests with the scripted `FakeTransport`: assert the exact opcode sequence for a
  1‑trace, 3‑point `icvce` (matches a hand‑written list derived from the reference), the
  R‑gate walk, Ic > 12 mA termination, cancellation → shutdown frames, `pniv` drive map for
  every lead permutation and third‑lead option.
- Replay test: a captured real `icvce` session replays and reproduces the recorded points.
- Plot golden tests (`matchesGoldenFile`) for an empty plot and a 5‑trace family.

## Hardware validation checklist (record in `docs/hardware-notes.md`)
- 2N3904: identify → Ic/Vce family (5 traces) and hFE vs Ic; compare visually and by CSV
  against the reference client run on the same part (expect agreement within noise).
- 2N7000: Id/Vds family and Id/Vgs transfer; check Vgs(th) from the identify agrees with
  the transfer curve.
- J201/2N5457 JFET: Idss and Vgs(off) from transfer curve vs identify.
- 1N4148 and a red LED: PN I‑V forward; reverse sweep on a 5.1 V zener shows the knee.
- Cancel mid‑family: unit returns to idle, leads safe (identify works immediately after).

## Acceptance criteria
- All five sweeps run to completion and save; CSV exports match the reference format.
- Engine opcode‑sequence tests green; replay test green.
- No sweep leaves the unit in analog mode after error/cancel (verified by immediate identify).
