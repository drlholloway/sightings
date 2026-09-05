# Hardware notes

Results of the hardware checklists from the phase plans. Fill in as each
platform is exercised with a real DCA75.

## Bring-up (Phase 2)

| Check | macOS | Linux | Android |
|---|---|---|---|
| Device enumerates (`just probe`) | ✅ 2026‑09‑05, bus 1 addr 1; USB string descriptors empty (product/serial come from STATE) | _pending_ | _pending_ |
| STATE serial / firmware match the unit | ✅ s/n 225000, hw 0001, fw 0023, R(MT2) 559.5 Ω; CAL 1012 / 8110 / 59409 / 470261 Ω | _pending_ | _pending_ |
| STATE exchange loop (`just bench`): p50 / p95 / errors | ✅ 300 exchanges: p50 0.27 ms, p95 0.35 ms, max 0.54 ms, 0 stale/errors | _pending_ | _pending_ |
| Identify matches the unit's screen | ✅ 2N5088: NPN, hFE 404, E=Green B=Red C=Blue, Vbe 769 mV @ 5 mA, Vce(sat) 22.8 mV (confirmed against the unit's display) | _pending_ | _pending_ |
| Unit-button test appears as a draft | _pending_ | _pending_ | _pending_ |
| Unplug mid-session → disconnected, replug → auto-connect | _pending_ | _pending_ | _pending_ |
| Android: unit powers from OTG with battery removed | | | _pending_ |

## Curves (Phase 6)

| Sweep | Part | Matches reference client? | Notes |
|---|---|---|---|
| Ic/Vce family | 2N3904 | _pending_ | |
| hFE vs Ic | 2N3904 | _pending_ | |
| Id/Vds family | 2N7000 | _pending_ | |
| Id/Vgs transfer | 2N7000 / J201 | _pending_ | |
| PN I-V forward | 1N4148, red LED | _pending_ | |
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
