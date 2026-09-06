# Phase 1 — Protocol core (`packages/dca75_protocol`)

**Goal:** a pure‑Dart, dependency‑free library that encodes every DCA75 command, decodes
every response, exposes the lead/config tables and derived measurements, and is proven by
unit tests and golden frames. It is a faithful port of the `DCA` class, `decodeResult`,
`pinsFor`, `diodePins`, `configFrom12G` and the constants in the reference WebUSB client (kept privately, not in the repository).

**Effort:** 3–5 days. **Hardware:** none (golden frames can be captured later in Phase 2
and added to the test corpus).

## Public API (target shape)

```dart
// constants.dart
enum Opcode { serial(0x82), adcs(0x83), cal(0x84), test(0x85), state(0x86), /* lock, bootl omitted on purpose */
              message(0x89), boost(0x8A), boosted(0x8B), boostOff(0x8C), leadSafe(0x8D), rGate(0x8E),
              volts(0x8F), allVolts(0x90), matrixRgb(0x91), matrixPlus(0x92), mode(0x93),
              ccGate(0x94), cvGate(0x95), cntrst(0x96), bridgeGate(0x97); }
const forbiddenOpcodes = {0x87, 0x88};
const writeArmStatus = 0x5C;
enum DeviceMode { none, display, analogLocal, analogUsb }
enum DeviceState { idle(0), testing(1), tested(2), ack(128), testedAck(130) }
enum Dac { mt1, mt2, gate }        enum Drive { none, mt1, mt2, gate }
enum Lead { none, red, green, blue } enum RGateIdx { r1k0(1), r8k2(2), r68k(3), r470k(4) }
enum CxMode { off, on, read(3), resetAcq(4), oneShot(5), oneShotBurst(6) }
enum ComponentType { none, bjt, mosfet, igbt, scr, triac, diode, short, jfet, vreg, lowBattery, usbVoltageFail }

// frame.dart
class Frame {            // 64 bytes, opcode at [0]; throws ProtocolPolicyError for forbidden opcodes / 0x5C
  Frame(Opcode op);
  Uint8List get bytes; ByteData get data;
  void setF32(int offset, double v); void setU16(int offset, int v); void setU8(int offset, int v);
}
class Response {         // wraps received 64 bytes; typed getters; `opcode` echo check
  int get opcode; double f32(int off); int u16(int off); int u8(int off); String hex();
}

// commands.dart — pure builders (no I/O):
Frame buildState(int ackVal);  Frame buildCalRead();  Frame buildTest(int subcmd /*1 initiate, 2 read*/);
Frame buildAdcs({int direct, int muxed, int burst}); Frame buildBoost(double volts); Frame buildBoosted();
Frame buildBoostOff(); Frame buildLeadsSafe(); Frame buildRGate(RGateIdx); Frame buildDacVolts(double v, Dac ch);
Frame buildDacAllVolts(double mt1, double mt2, double gate); Frame buildMatrixRgb(Drive r, Drive g, Drive b);
Frame buildMatrixPlus(int cfg, int ton); Frame buildBridgeGate(Lead); Frame buildMode(DeviceMode);
Frame buildCcGate(CxMode, {double mA = 0, int timeoutMs = 0}); Frame buildCvGate(CxMode, {int cfg = 0, double volts = 0, int timeoutMs = 0});

// parsers.dart
class StateInfo { DeviceState state; String hardwareRev; String firmwareRev; String serial; double? rMt2; }
StateInfo parseState(Response r);
class Calibration { double r1k0, r8k2, r68k, r470k, rMt2; }
Calibration parseCal(Response r);
class AdcSnapshot { double? batt, bTest, v12, prereg, vRef; double setGate, gate, setMt1, setMt2, mt2, red, green, blue; }
AdcSnapshot parseAdcs(Response r, {required bool direct});

// result.dart — decodeResult port
class IdentifyResult {
  ComponentType type; int config; int flags; String name; List<String> flagLabels;
  List<PinAssignment>? pins;                 // (lead colour, terminal label)
  List<Param> params;                        // (key, label, value (SI base units), unit, displayString)
  Map<String, double> headline;              // hfe, vbe_5ma, vgs_th, vf, idss, vgs_off, vout ...
  Uint8List raw;                             // 64 bytes
}
IdentifyResult decodeResult(Response r);

// tables.dart
Map<int, LeadMap> cfgLeads;  Map<int, (String,String)> vceTab, vbeTab;
List<PinAssignment>? pinsFor(int cfg, List<String> terms); List<PinAssignment>? diodePins(int cfg);
int configFrom12G(Lead cathode, Lead anode); const revM1M2 = {1:3,2:5,3:1,4:6,5:2,6:4};

// measure.dart — DeviceMirror + Determine* formulas
class DeviceMirror { AdcSnapshot v; double rGate = 1e7; double rMt2 = 620;
  double vce(int cfg); double vbe(int cfg); double ib(int cfg); double ic(int cfg); }

// units.dart
String eng(double v, String unit, {int digits = 3});
```

## Tasks

1. **Constants & enums** — straight transcription. Include the `TYPE_NAME` list and the
   flag bit meanings per type as documented constants (BJT: 2 digital, 4 C‑E diode, 8 darlington,
   16 NPN, 32 germanium, 64 silicon; MOSFET/IGBT: 2 N‑ch, 4 depletion, 8 body diode, 16 gate
   protected; JFET: 2 symmetric, 4 N‑ch, 8 normally off).

2. **Frame / Response** — `Frame` constructor throws `ProtocolPolicyError` for 0x87/0x88;
   `Frame.bytes` getter (or a `validate()` called by the transport) throws if byte 1 == 0x5C.
   All multi‑byte writes little‑endian (`Endian.little`).

3. **Command builders** — one function per opcode with the exact byte offsets from the
   reference (`STATE` ack at [2]; `TEST` subcmd at [1]; `ADCS` direct/muxed/burst at [2..4];
   `BOOST` f32 at [2]; `RGATE` idx at [2]; `VOLTS` f32 at [2], ch at [6]; `ALLVOLTS` f32 at
   [2],[6],[10]; `MATRIXRGB` at [2..4]; `MATRIXPLUS` cfg [2], ton [3]; `BRIDGEGATE` [2];
   `MODE` [2]; `CCGATE` mode [2], f32 mA [3], u16 timeout [7]; `CVGATE` mode [2], cfg [3],
   f32 V [4], u16 timeout [8]).

4. **Parsers** — `parseState` (state [2], hw u16 [3], fw u16 [5], serial = 6 × u16 chars from
   [7], rMt2 f32 [19] accepted only if 0 < r < 1e5), `parseCal` (five f32 from [2]),
   `parseAdcs` (direct block f32 [5..21], always block f32 [25..53]). CCGATE READ status at
   u8 [9], CVGATE READ status at u8 [10] — expose as `ccStatus(Response)` / `cvStatus(Response)`
   with the `0x4C` (done/abort) and `0x48` (fault) masks as named constants.

5. **Result decoder** — port `decodeResult` verbatim, but return structured `Param`s with
   machine keys and SI values in addition to display strings (reference only produced display
   strings). Keys to define, per family:
   - BJT: `ic_leak, vbe_5ma, vbe_1ma, ib_5ma, ib_1ma, hfe, ic_test, vce_sat, ic_sat, ib_sat, r_shunt, r_input`
     (digital variants: `vi_on, vi_off, ic_on, ic_off`).
   - MOSFET/IGBT: `vgs_th, id_on, ig_on, id_on2, vg_off, id_off, gm, vds_sat, id_sat, vg_sat, rds_on, vsd`.
   - JFET: `vgs_off, id_off, vgs_on, id_on, id_on2, gfs, idss, vgs_zero, vds_zero, vgs_sat, ig_sat, rds, id_rds`.
   - SCR/TRIAC: `leak, v_hold, igt, vgt, ..., v_on` (10 floats; keep index names for the unlabeled ones).
   - Diode: `n_junctions, pattern, d1_kind, d1_cfg, d1_vf, d1_if, d1_vr, d1_ir, d1_rp, d1_vrp, d1_it`, and `d2_*` from [36]/[37].
   - Short: `shorted_mask`. VREG: `vout, iout, iq, vdo, dvout`.
   Currents are mA in the frame; store SI amps in `value`, keep the display string using `eng()`.
   `headline` picks the bin‑statistics candidates (hfe, vbe_5ma, ic_leak, vgs_th, rds_on, vgs_off, idss, d1_vf, vout).

6. **Tables & routing** — `cfgLeads`, `vceTab`, `vbeTab` (copy exactly; note `VBE_TAB` sits
   right after `VCE_TAB` in the reference file — copy the full table, do not reconstruct it),
   `pinsFor`, `diodePins`, `configFrom12G`, `revM1M2`.

7. **Measurements** — `DeviceMirror` with `vce/vbe/ib/ic` including the Ic zero‑floor
   `(1000/rMt2) * 0.0009155832231044769` and the sign flip for cfg > 6.

8. **Tests** (`test/`)
   - Port every assertion from the reference `selfTest()` (ccgate opcode, float LE, frame
     length, BOOTL blocked, STATE rMt2 parse, cfg tables, diode cfg fwd R/G == 3).
   - Builder byte‑layout tests: each builder compared against a hand‑written expected 64‑byte
     hex string.
   - Policy tests: constructing 0x87/0x88 throws; any frame with [1] == 0x5C fails `validate()`.
   - Decoder tests with **golden frames** in `test/golden/*.hex` (one per component type).
     Until real captures exist, synthesise frames from known values and assert round‑trip; replace
     with real captures in Phase 2 (the reference client shows the raw hex under “details”, so
     they can also be captured today from Chrome).
   - Property test: `eng()` formatting across magnitudes.

## Acceptance criteria
- `dart test` green; ≥ 90 % line coverage on `commands.dart`, `parsers.dart`, `result.dart`, `tables.dart`.
- Package has no dependency other than `meta`/`collection`.
- A `tools/dca75_cli decode <hex>` subcommand prints the decoded result for any 64‑byte hex frame.
