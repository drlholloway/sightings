import 'dart:math' as math;

import 'constants.dart';
import 'frame.dart';

/// Pure command builders. Byte offsets are exactly those of the reference
/// client; see `docs/plans/01-protocol-core.md`.

/// STATE 0x86 — read state/identity; `ackVal` at [2].
Frame buildState(DeviceState ack) => Frame(Opcode.state)..setU8(2, ack.code);

/// CAL 0x84 read-only (status 0). There is intentionally no write variant.
Frame buildCalRead() => Frame(Opcode.cal);

/// TEST 0x85 — sub-command at [1]: 1 = initiate, 2 = read result.
Frame buildTestInitiate() => Frame(Opcode.test)..setU8(1, 1);
Frame buildTestRead() => Frame(Opcode.test)..setU8(1, 2);

/// ADCS 0x83 — direct/muxed/burst masks at [2..4].
Frame buildAdcs({int direct = 0, int muxed = 0, int burst = 0}) =>
    Frame(Opcode.adcs)
      ..setU8(2, direct)
      ..setU8(3, muxed)
      ..setU8(4, burst);

/// Direct-rail mask that reads battery, BTest, 12 V, prereg and Vref.
const int adcsAllRails = 0x1F;

/// BOOST 0x8A — target volts (f32 at [2]); clamped to 15 V like the reference.
Frame buildBoost(double volts) =>
    Frame(Opcode.boost)..setF32(2, math.min(volts, maxBoostVolts));

Frame buildBoosted() => Frame(Opcode.boosted);
Frame buildBoostOff() => Frame(Opcode.boostOff);
Frame buildLeadsSafe() => Frame(Opcode.leadsSafe);

/// RGATE 0x8E — resistor index at [2].
Frame buildRGate(RGateIdx idx) => Frame(Opcode.rGate)..setU8(2, idx.code);

/// VOLTS 0x8F — f32 volts at [2], DAC channel at [6].
Frame buildDacVolts(double volts, Dac ch) => Frame(Opcode.volts)
  ..setF32(2, volts)
  ..setU8(6, ch.code);

/// ALLVOLTS 0x90 — MT1 [2], MT2 [6], GATE [10].
Frame buildDacAllVolts(double mt1, double mt2, double gate) =>
    Frame(Opcode.allVolts)
      ..setF32(2, mt1)
      ..setF32(6, mt2)
      ..setF32(10, gate);

/// MATRIXRGB 0x91 — drive per lead color at [2..4].
Frame buildMatrixRgb(Drive red, Drive green, Drive blue) =>
    Frame(Opcode.matrixRgb)
      ..setU8(2, red.code)
      ..setU8(3, green.code)
      ..setU8(4, blue.code);

/// MATRIXPLUS 0x92 — config at [2], ton at [3].
Frame buildMatrixPlus(int cfg, int ton) => Frame(Opcode.matrixPlus)
  ..setU8(2, cfg)
  ..setU8(3, ton);

/// BRIDGEGATE 0x97 — lead at [2].
Frame buildBridgeGate(Lead lead) =>
    Frame(Opcode.bridgeGate)..setU8(2, lead.code);

/// MODE 0x93 — mode at [2].
Frame buildMode(DeviceMode mode) => Frame(Opcode.mode)..setU8(2, mode.code);

/// CCGATE 0x94 — mode [2], f32 mA [3], u16 timeout ms [7].
Frame buildCcGate(CxMode mode, {double milliamps = 0, int timeoutMs = 0}) =>
    Frame(Opcode.ccGate)
      ..setU8(2, mode.code)
      ..setF32(3, milliamps)
      ..setU16(7, timeoutMs);

/// CVGATE 0x95 — mode [2], cfg [3], f32 volts [4], u16 timeout ms [8].
Frame buildCvGate(CxMode mode,
        {int cfg = 0, double volts = 0, int timeoutMs = 0}) =>
    Frame(Opcode.cvGate)
      ..setU8(2, mode.code)
      ..setU8(3, cfg)
      ..setF32(4, volts)
      ..setU16(8, timeoutMs);
