# Hardware notes

Results of the hardware checklists from the phase plans. Fill in as each
platform is exercised with a real DCA75.

## Bring-up (Phase 2)

| Check | macOS | Linux | Android |
|---|---|---|---|
| Device enumerates (`just probe`) | _pending_ | _pending_ | _pending_ |
| STATE serial / firmware match the unit | _pending_ | _pending_ | _pending_ |
| 1 000 STATE exchanges (`just bench`): p50 / p95 / errors | _pending_ | _pending_ | _pending_ |
| Identify a 2N3904 matches the unit's screen | _pending_ | _pending_ | _pending_ |
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
