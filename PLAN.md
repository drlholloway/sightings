# Sightings (DCA75 Workbench) — Project Plan

Product name: **Sightings**, subtitle **DCA75 Workbench** (decided 2026‑09‑05). Internal
identifiers (`workbench` Dart package, `dev.laneholloway.workbench` bundle id) are unchanged.

Desktop (macOS, Linux) and Android application that talks to a Peak Atlas DCA75
(“DCA Pro”) semiconductor analyser over USB, runs identify tests and curve
sweeps, visualises the results, and stores every reading in a local SQLite
database so parts can be reviewed, compared and binned later.

This document is the master plan. Each phase has a detailed implementation
plan under `docs/plans/`.

| Phase | Document | Outcome |
|---|---|---|
| 0 | [00-scaffolding](docs/plans/00-scaffolding.md) | Repo, workspace, CI, coding standards |
| 1 | [01-protocol-core](docs/plans/01-protocol-core.md) | Pure-Dart DCA75 protocol library with tests |
| 2 | [02-usb-transport](docs/plans/02-usb-transport.md) | USB bulk transport for macOS, Linux, Android |
| 3 | [03-device-service](docs/plans/03-device-service.md) | Connection state machine, identify flow, polling |
| 4 | [04-datastore](docs/plans/04-datastore.md) | SQLite schema (drift), DAOs, export/import |
| 5 | [05-app-ui](docs/plans/05-app-ui.md) | Identify, history, part bins, settings screens |
| 6 | [06-curve-tracer](docs/plans/06-curve-tracer.md) | Sweep engine, live plot, saved sweeps |
| 7 | [07-packaging-release](docs/plans/07-packaging-release.md) | DMG, AppImage/Flatpak, APK, udev, signing |
| 8 | [08-future-ios-sync](docs/plans/08-future-ios-sync.md) | iOS viewer, cross-device sync (out of initial scope) |

---

## 1. Goals and scope

### In scope (initial release)
- Connect to a DCA75 over USB on **macOS**, **Linux** and **Android** (USB host / OTG).
- **Identify**: run a test from the app or pick up a test started with the unit's own
  button; show component type, pinout by lead colour, flags and all measured parameters.
- **Curves**: BJT Ic/Vce family, hFE vs Ic, FET Id/Vds family, Id/Vgs transfer, diode PN I‑V.
  Live plotting, cancel, CSV/PNG export.
- **Datastore**: every identify result and every sweep is persisted to SQLite with the raw
  64‑byte frame, decoded parameters, device identity and timestamps.
- **Review**: browse history, filter by type/part/date, open a reading, overlay saved sweeps.
- **Part bins**: tag readings with a part number / batch; see the distribution (histogram,
  percentile) of hFE, Vbe, Vgs(th), Vf, etc. within that bin and where a given reading falls.
- **Export**: CSV per reading or bin, PNG of plots, and full database backup/restore.

### Explicitly out of initial scope
- Firmware update, calibration, serial‑number writes (blocked at the transport layer, never exposed).
- Windows (the architecture allows it later; not a target now).
- iPhone live USB (not possible, see §3.4). An iOS **viewer** of the database is planned for later.
- Cloud sync. Local‑first; a file‑based backup/restore is the sync mechanism for now.

---

## 2. What we already have

`ref-docs/dca-bench.html` is a working single‑file WebUSB client. It is the most
valuable input to this project because it contains, verified against hardware:

- USB identity: **VID 0x04D8, PID 0xF8CA**, vendor‑specific bulk interface (WinUSB on
  Windows, driverless on macOS/Linux).
- The frame format: **64‑byte packets**, byte 0 = opcode, response echoes the opcode,
  little‑endian IEEE‑754 floats, three retries on a stale frame.
- The full opcode table (0x82–0x97) and the byte layouts of STATE, CAL, ADCS, TEST results.
- Result decoders for BJT, MOSFET/IGBT, JFET, SCR/TRIAC, diode networks, short, V‑reg.
- Lead/configuration tables (config 1–12 → red/green/blue ↔ MT1/MT2/GATE, Vce/Vbe lead pairs).
- Derived‑measurement formulas (Ib, Ic, Vce, Vbe from the ADC mirrors and sense resistors).
- The five sweep algorithms, ported from the vendor app's `Graph_*.DoGraph`, including
  the Vce/Vds servo loops and the R‑gate selection walk.
- Hard safety rules: never send 0x88 (BOOTL) or 0x87 (LOCK); never send status 0x5C
  (EEPROM write arm) with CAL/SERIAL.

Phase 1 is largely a **faithful port of this file's logic into a typed, tested Dart
library**. The HTML stays in `ref-docs/` as the reference implementation and as a
hardware sanity‑check tool.

Note on provenance: the reference client was built from a reverse‑engineered protocol
dossier. **Permission to distribute binaries has been granted** (decision recorded 2026‑09‑05):
signing, notarisation and store listings are in scope for Phase 7. The **source is public under
PolyForm Shield 1.0.0** (decided 2026‑09‑06, see `LICENSE`): anyone may use, build and modify it
but not compete with it; builds are free on every platform, and users are bound by `docs/EULA.md`.

---

## 3. Technology decisions

### 3.1 Framework: Flutter (Dart)

Requirement: one codebase for macOS, Linux and Android now; iOS later; SQLite everywhere;
charts; and raw USB bulk transfers. Three candidates were considered.

| | **Flutter** (chosen) | Kotlin Multiplatform + Compose | Tauri 2 (Rust + web UI) |
|---|---|---|---|
| macOS / Linux desktop | First‑class | JVM desktop, mature | Mature |
| Android | First‑class | First‑class | Supported, newer |
| iOS later | First‑class | Compose for iOS, maturing | Supported, newer |
| SQLite | `drift` (typed, reactive, migrations) on all platforms | SQLDelight, all platforms | `rusqlite` + JS bridge |
| USB bulk | `quick_usb` (libusb on desktop, `UsbManager` on Android) or thin FFI / platform channel | `usb4java` on JVM, `UsbManager` on Android; two impls | `nusb`/`rusb` on desktop, JNI to `UsbManager` on Android |
| Charts | `fl_chart` or a `CustomPainter` port of the existing canvas plotter | Vico / Koala | Reuse existing JS canvas plotter directly |
| Reuse of `dca-bench.html` | Logic ports 1:1 to Dart (same byte ops, same async shape) | Port to Kotlin | Plot + decode code reusable as‑is; transport must move to Rust |
| Risk | `quick_usb` maintenance; mitigated by a transport interface | More per‑platform glue | Mobile story least proven; three languages |

Flutter wins on “fewest moving parts across all four targets”, and the async/await shape of
the reference JavaScript maps directly onto Dart, which keeps the port low‑risk.

Fallback if `quick_usb` proves inadequate: keep the same `DcaTransport` interface and
implement it with `dart:ffi` → libusb‑1.0 on desktop and a ~150‑line Kotlin platform
channel on Android. This is planned as an explicit checkpoint in Phase 2.

### 3.2 Datastore: SQLite via `drift`

- Single file database in the app documents directory, WAL mode.
- Schema versioned with drift migrations; a `schema_version` check on open.
- Raw 64‑byte frames are stored verbatim (BLOB) so readings can be re‑decoded if a decoder
  bug is fixed later.
- Sweep points stored as packed `Float64` BLOBs per trace (compact, fast to load, trivial
  to export to CSV).
- The `.sqlite` file is the interchange format for backup, restore and the future iOS viewer.

### 3.3 Charts

Start with `fl_chart` for the identify‑screen sparklines/histograms. For the curve tracer,
port the reference canvas plotter to a `CustomPainter` (it is ~120 lines, already tuned for
this data, supports hover read‑out and PNG export via `toImage`). Decide per screen; both are
pure Dart and work on every target.

### 3.4 Platform USB realities

| Platform | How | Notes |
|---|---|---|
| macOS | libusb opens the vendor‑class device directly; no kext, no driver | Hardened runtime + notarisation for direct distribution. If ever sandboxed (App Store), add the `com.apple.security.device.usb` entitlement. |
| Linux | libusb; udev rule grants access | Ship `60-dca75.rules`: `SUBSYSTEM=="usb", ATTR{idVendor}=="04d8", ATTR{idProduct}=="f8ca", MODE="0660", TAG+="uaccess"`. Flatpak needs `--device=all`. |
| Android | `UsbManager` + `UsbDeviceConnection.bulkTransfer`; USB Host + OTG cable | `device_filter.xml` (vendor 1240 / product 63690 decimal), `ACTION_USB_DEVICE_ATTACHED` intent so the app launches on plug‑in, runtime permission dialog. Phone must supply bus power; DCA75 runs from USB when connected. Verify with a real phone early (Phase 2 gate). |
| iOS / iPadOS | **Not feasible for live USB.** iPhone has no third‑party USB host API. iPadOS DriverKit exists only on M‑series iPads and requires a per‑vendor‑ID entitlement from Apple. | iOS gets a **viewer‑only** app later (Phase 8) that opens the SQLite file. |

---

## 4. Architecture

Pub workspace (Dart 3 workspaces) with five packages. Dependencies flow strictly downward.

```
apps/workbench/            Flutter app (UI, state, DI, platform config, Android USB bridge in Kotlin)
packages/dca75_protocol/   Pure Dart. Frames, opcodes, decoders, config tables, math. No I/O.
packages/dca75_transport/  DcaTransport interface, libusb dart:ffi transport (worker isolate), Fake/replay impls.
packages/dca75_device/     Typed client, DeviceController (state machine, polling), SweepEngine. Pure Dart.
packages/dca75_store/      drift schema, repository, stats, CSV. Depends on dca75_protocol/device for types.
tools/dca75_cli/           decode / probe / identify / bench / replay from the terminal.
ref-docs/                  Reference WebUSB client (unchanged).
```

*Implementation note (2026‑09‑05):* `quick_usb` turned out to be four years stale and pins
`ffi 1.x`, incompatible with drift. The fallback described in §3.1 was taken from the start:
hand‑written `dart:ffi` bindings to libusb‑1.0 running in a worker isolate on desktop, and a
~200‑line Kotlin `UsbBridge` over `UsbManager` on Android. The device logic that the plan put in
the app was split out into the pure‑Dart `dca75_device` package so sweeps and the controller are
unit‑tested against the fake transport.

Runtime layering inside the app:

```
UI (Flutter widgets)
  └─ ViewModels / Notifiers (riverpod)
       ├─ DeviceService  (state machine: disconnected → connecting → idle → testing → sweeping)
       │     ├─ DcaProtocol (dca75_protocol)  — builds/parses frames, derived measurements
       │     └─ DcaTransport (dca75_transport) — exchange(64 bytes) → 64 bytes, disconnect events
       ├─ SweepEngine   (curve algorithms, cancellable, emits points)
       └─ ReadingsRepository (dca75_store) — save/query readings, sweeps, parts, bins
```

Key design rules:
- **One in‑flight exchange at a time.** The transport serialises `exchange()` calls exactly
  as the reference client's `busy` promise chain does.
- **Every hardware error path ends in `leadsSafe()`**, mode NONE, gate CC/CV OFF.
- **Protocol package has zero platform dependencies** and is tested with golden frames.
- **Readings are immutable once saved**; annotations (part number, notes, tags) live in
  separate tables so re‑decoding never loses user data.

---

## 5. Protocol summary (for orientation; Phase 1 has the detail)

Opcodes: SERIAL 0x82, ADCS 0x83, CAL 0x84, TEST 0x85, STATE 0x86, LOCK 0x87 ✗, BOOTL 0x88 ✗,
MESSAGE 0x89, BOOST 0x8A, BOOSTED 0x8B, BOOSTOFF 0x8C, LEADSAFE 0x8D, RGATE 0x8E, VOLTS 0x8F,
ALLVOLTS 0x90, MATRIXRGB 0x91, MATRIXPLUS 0x92, MODE 0x93, CCGATE 0x94, CVGATE 0x95,
CNTRST 0x96, BRIDGEGATE 0x97.

Identify flow: `TEST(1)` → poll `STATE` every 150 ms until state = TESTED (2), 15 s timeout →
`STATE(ack=130)` → `TEST(2)` returns the 64‑byte result frame (byte 2 = type, byte 3 = config,
byte 4 = flags, floats from byte 5).

Unit‑button pickup: poll `STATE` every 600 ms while idle; a TESTED state means the user
pressed the button on the unit; ack and fetch the same way.

Result types: 0 none, 1 BJT, 2 MOSFET, 3 IGBT, 4 SCR, 5 TRIAC, 6 diode network, 7 short,
8 JFET, 9 V‑reg, 10 low battery, 11 USB voltage fail.

---

## 6. Data model (summary; Phase 4 has DDL)

```
devices        serial PK, hardware_rev, firmware_rev, r_mt2, cal_r1k0..cal_r470k, first_seen, last_seen
sessions       id, device_serial FK, started_at, ended_at, platform, app_version, notes
readings       id, session_id FK, taken_at, source (app|unit_button), type, config, flags,
               raw_frame BLOB(64), decoder_version, batt_v, v12_v, vref_v
reading_params reading_id FK, key, value REAL, unit          -- e.g. ('hfe', 212.4, ''), ('vbe_5ma', 0.71, 'V')
parts          id, part_number, manufacturer, description, family
bins           id, part_id FK, name, created_at              -- a batch/lot/bag of one part
reading_tags   reading_id FK, part_id FK NULL, bin_id FK NULL, label, notes
sweeps         id, reading_id FK NULL, session_id FK, kind, params_json, started_at, duration_ms, cancelled
sweep_traces   id, sweep_id FK, idx, label, x_label, y_label, points BLOB (float64 x,y pairs), n_points
schema_meta    key, value
```

Denormalised “headline” numeric columns (hFE, Vbe, Vgs_th, Vf, Idss, Vgs_off, Vout) are
exposed through a SQL view over `reading_params` so bin statistics are a single query.

---

## 7. Safety and correctness rules (non‑negotiable)

1. Opcodes 0x87 and 0x88 are rejected inside `Frame` construction; there is no API to send them.
2. Byte 1 = 0x5C is rejected for every opcode; CAL is read‑only (status 0).
3. Any exception during identify or sweep runs the shutdown sequence:
   `LEADSAFE → CCGATE OFF → CVGATE OFF → MODE NONE`, then re‑throws.
4. App lifecycle: on pause/background/quit with a device open, run the shutdown sequence.
5. Sweep guards are preserved from the reference: current > 12 mA stops the trace; Vce/Vds
   requests are clamped 0–12 V; boost never above 15 V; servo loops cap at 20/64 iterations.
6. Transport timeout 3 s per transfer; three retries on opcode mismatch; disconnect on failure.
7. Every USB exchange is logged (opcode, first bytes, duration) to a rolling in‑app log that
   can be exported for bug reports.

---

## 8. Roadmap and effort

Effort is for one developer familiar with Flutter, with hardware on the desk. Phases 1, 4 and
the fake transport can be built without hardware.

| Phase | Effort | Hardware needed | Milestone |
|---|---|---|---|
| 0 Scaffolding | 1–2 days | no | `flutter run` on macOS/Linux/Android shows an empty shell; CI green |
| 1 Protocol core | 3–5 days | no (golden frames) | 100 % of reference `selfTest` ported + golden decode tests |
| 2 USB transport | 3–6 days | yes, all 3 platforms | STATE round‑trip on macOS, Linux, Android; fake transport replays a capture |
| 3 Device service | 2–3 days | yes | Identify from app and from unit button; rails shown |
| 4 Datastore | 3–4 days | no | Readings/sweeps persisted; backup/restore; migration test |
| 5 App UI | 5–8 days | partly | Identify, history, reading detail, part bins with histogram |
| 6 Curve tracer | 5–8 days | yes | All five sweeps match the reference client on a 2N3904 / 2N7000 / 1N4148 |
| 7 Packaging | 3–4 days | yes | Signed DMG, AppImage + udev, APK; install docs |
| **Total** | **~5–8 weeks** | | |

Suggested order: 0 → 1 → 4 (both hardware‑free) → 2 → 3 → 5 → 6 → 7. Start Phase 2's
Android power check as soon as a phone and OTG cable are available; it is the biggest
unknown.

---

## 8a. Build status (2026‑09‑05)

| Phase | Status |
|---|---|
| 0 Scaffolding | done — pub workspace, lints, CI workflow, justfile, udev rule |
| 1 Protocol core | done — 55 tests |
| 2 USB transport | done — libusb FFI verified on macOS (p95 0.35 ms); Android bridge verified on a phone over OTG (2026‑09‑06) |
| 3 Device service | done — controller with polling/drafts, 30 tests with the sweep engine |
| 4 Datastore | done — drift schema, repository, stats, CSV, backup — 18 tests |
| 5 App UI | done — identify/drafts, history, detail, parts/bins/stats, settings, log; 6 widget tests incl. end‑to‑end flow |
| 6 Curve tracer | all five sweeps run on hardware on macOS and Android (2N5088, diode, J201); identify vs curve cross‑checks agree; reverse/zener sweep and a comparison with Peak's app still open |
| 7 Packaging | partial — debug builds verified for macOS and Android APK; Linux build, signing, notarisation, release CI pending |

## 9. Risks and mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| `quick_usb` unmaintained or broken on a Flutter upgrade | medium | `DcaTransport` interface; FFI/platform‑channel fallback designed in Phase 2 |
| Android phone cannot bus‑power the DCA75 over OTG | medium | Test early; document powered OTG hub as workaround; the unit's AAA battery may cover it |
| Timing‑sensitive sweeps behave differently than in Chrome | low | Same delays (3/20/24/50 ms) kept; measure per‑exchange latency in the log; compare curves to reference |
| macOS 15+/26 USB permission prompts or sandbox changes | low | Direct distribution first; entitlement documented |
| Decoder mistake corrupts stored data | low | Raw frames stored; `decoder_version` column; re‑decode command |
| Protocol/IP status of the reverse‑engineered dossier | resolved | Distribution permission granted; dossier stays out of the repo, only the ported Dart code ships |

---

## 10. Decisions and open questions

### Decided (2026‑09‑05)
1. **Everything public and free; source under PolyForm Shield.** Free builds on macOS, Linux
   and Android; the repository is public under PolyForm Shield 1.0.0 (no competing products),
   with an EULA for users of the builds (2026‑09‑06). Phase 7 includes
   signed/notarised macOS builds, a Linux AppImage and the Play listing. See §2.
2. **Unit‑button results land as drafts.** A test started from the unit's own button is
   shown as a *draft* card that the user confirms (Save, optionally tagging first) or
   discards. Tests started from the app's Test button save immediately. Drafts are held in
   memory with their raw frame; multiple drafts queue in a tray. See Phases 3 and 5.

### Still open
1. Should the “part bins” statistics include outlier rejection, or just raw percentiles?
   Plan assumes raw percentiles.
2. Preferred Linux packaging: AppImage (simplest, works with udev rule) or Flatpak?
   Plan assumes AppImage first.
3. Should drafts survive an app restart (persist to a `drafts` table) or be discarded on
   exit? Plan assumes **in‑memory only**, with a confirmation prompt if drafts exist on quit.
