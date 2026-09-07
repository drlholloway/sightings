# Hardware notes

Results of the hardware checklists from the phase plans. Fill in as each
platform is exercised with a real DCA75.

## Bring-up (Phase 2)

| Check | macOS | Linux | Android |
|---|---|---|---|
| Device enumerates (`just probe`) | ✅ 2026‑09‑05, bus 1 addr 1; USB string descriptors empty (product/serial come from STATE) | _pending_ | ✅ 2026‑09‑06, USB OTG, release APK sideloaded |
| STATE serial / firmware match the unit | ✅ s/n 225000, hw 0001, fw 0023, R(MT2) 559.5 Ω; CAL 1012 / 8110 / 59409 / 470261 Ω | _pending_ | ✅ |
| STATE exchange loop (`just bench`): p50 / p95 / errors | ✅ 300 exchanges: p50 0.27 ms, p95 0.35 ms, max 0.54 ms, 0 stale/errors | _pending_ | not measured (no CLI on Android); sweeps ran normally |
| Identify matches the unit's screen | ✅ 2N5088: NPN, hFE 404, E=Green B=Red C=Blue, Vbe 769 mV @ 5 mA, Vce(sat) 22.8 mV (confirmed against the unit's display) | _pending_ | ✅ 2N5088, silicon diode, J201 — same results as macOS |
| Unit-button test appears as a draft | ✅ app: identify, draft flow and tagging confirmed by the owner | _pending_ | ✅ |
| Unplug mid-session → disconnected, replug → auto-connect | _pending_ | _pending_ | _pending_ |
| Android: unit powers from OTG with battery removed | | | _not yet checked_ (worked with the phone as host; battery state not recorded) |

## Curves (Phase 6)

| Sweep | Part | Matches reference client? | Notes |
|---|---|---|---|
| Ic/Vce family | 2N5088 | ✅ runs (not yet compared numerically) | 5 traces × 51 pts, Ib 5–25 µA from hFE 404, 29.5 s, no errors (2 runs) |
| hFE vs Ic | 2N5088 | ✅ runs (not yet compared numerically) | 21 pts, Ib 0.49–25 µA, Vce 5 V, 16.5 s, no errors |
| Id/Vds family | J201 | ✅ 5 traces Vgs −0.734…0 V, Vgs=0 trace saturates at 0.50 mA vs Idss 0.48 mA from identify | 253 pts, 33.9 s, no errors |
| Id/Vgs transfer | J201 | ✅ Id 0.49 mA at Vgs≈0, ≈0 at −0.73 V (matches Vgs(off) −0.734 V); slope ≈1.1 mS near 0 V | 41 pts, 24.2 s |
| PN I-V forward | silicon diode | ✅ classic knee; Vf 0.6935 V @ 4.84 mA on the curve vs 0.693 V @ 5.0 mA from identify (agree within 1 mV); leads pre-filled A=Red K=Blue from the identify | 51 pts to 5 V, 7.3 s, current reaches 7.1 mA (series R(MT2) limit) |
| PN I-V reverse | 5.1 V zener | _pending_ | |
| Cancel mid-family → immediate identify works | | _pending_ | |

## Golden frames

Real captures replace the synthetic fixtures in
`packages/dca75_protocol/test/`. Record them with
`just identify --capture golden-2n3904.dcalog` and copy the 64-byte hex of
the TEST(2) reply into `test/golden/`.

## Observations (macOS, 2026‑09‑05)

- Idle rails with the AAA fitted: battery 1.40 V, 12 V rail 2.99 V (boost off in idle, as
  expected), Vref 1.243 V, prereg 4.54 V.
- The unit reported state TESTED on first contact: it had a result waiting from a button press
  made before the app connected. The app's poller acknowledges and shows this as a draft.
- CAL returns further floats after R(MT2) (≈6.65, 6.64, 6.65, 4.5…) whose meaning is unknown;
  they are not used.
- The unit does **not** service USB while it runs an identify test: the STATE poll sent
  right after TEST(1) was answered only after 3.5 s (2N5088). The first attempt failed with a
  2.5 s libusb timeout; the poll after TEST(1) now uses the full 15 s identify budget and the
  default exchange timeout is 5 s. Captures: `docs/captures/identify-2n5088.dcalog`.
- BJT result floats 3 and 4 are the collector test currents for the two Vbe measurements
  (5.00 mA and 1.00 mA), not base currents as the reference client labelled them; labels fixed.
- Diode identify: PN junction, config 6, Vf 0.693 V @ 5.0 mA, reverse current 0. The first
  PN I‑V attempt used the default Red/Green leads on a diode sitting Red/Blue and traced a flat
  reverse line; the form now takes anode/cathode from the identify result.
- J201 identify: N‑ch JFET, config 1, Vgs(off) −0.734 V, Idss 484 µA, gfs 1.56 **mS**. The
  raw gfs/gm fields are in mS (the reference client showed them as S); decoder fixed.
  Golden frame: `test/golden/jfet-j201.hex`.

## Android (2026‑09‑06)

Release APK sideloaded onto a phone over Wi‑Fi. The Kotlin `UsbBridge` worked first time:
permission dialog, connect, identify, unit‑button drafts and the BJT, diode and JFET sweeps all
behaved exactly as on macOS with the same three parts (2N5088, silicon diode, J201).

## DCA55‑equivalent measurement (macOS, 2026‑09‑07)

2N5088: DCA75 identify hFE 405 @ 5 mA; DCA55‑equivalent hFE 410 @ Ic 2.53 mA, Vce 2.498 V,
Ib 6.2 µA, converged; Vbe 648 mV at that point, 765 mV @ Ib 4.50 mA; leakage 0. Servo lands
within tolerance in a few iterations from the identify's hFE as the starting guess.

## Reverse leakage (macOS, 2026‑09‑07)

Silicon diode (Vf 687 mV): Ir 5.1 nA @ 5.00 V, 30.6 nA @ 10.02 V through the 470 kΩ gate path
with baseline subtraction; the DCA75 identify's own reverse‑current field reads 0. The 10 V value
may include ADC gain mismatch (≈20 nA per 0.1 %); an open‑clip calibration would cancel it.
- D9B germanium diode (Vf 455 mV): 2.98 µA with the junction at 3.60 V (5 V requested) and
  4.79 µA at 7.76 V (10 V requested). The shortfall equals I × 470 kΩ exactly, confirming the
  gate‑path measurement; the DCA75 identify's reverse‑current field still reads 0. The DAC is
  now servoed so the junction reaches the requested voltage where the 12.5 V ceiling allows.
- D9B re‑run with the DAC servo: 2.89 µA at 4.99 V (target met) and 5.35 µA at 9.58 V (DAC
  ceiling reached: 5.35 µA × 470 kΩ = 2.5 V drop). Leakage nearly flat with voltage, as
  expected for germanium saturation current.

## Germanium transistor (MP40A, PNP, macOS, 2026‑09‑07)

DCA75 identify: hFE 29.3 @ 5 mA, Vbe 332 mV, Vce(sat) 56 mV, Iceo 31.2 µA. DCA55‑equivalent:
hFE 25.0 @ Ic 2.48 mA, Vce 2.47 V, Ib 98 µA, converged; (2.48 mA − 30 µA) / 98 µA reproduces the
stored value, so the leakage subtraction is verified. Icbo through the gate path: 2.85 µA @ 4.99 V,
6.0 µA @ 9.24 V (DAC ceiling). Iceo/Icbo ≈ 11, the low‑current gain, as expected.
