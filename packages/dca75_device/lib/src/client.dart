import 'dart:math' as math;

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';

import 'timing.dart';

/// Typed command layer over a [DcaTransport], mirroring the `DCA` class of
/// the reference client: every command, the analog mid-level helpers, and
/// the [DeviceMirror] that the derived measurements read from.
class DcaClient {
  DcaClient(this.transport, {Sleep? sleep}) : sleep = sleep ?? realSleep;

  final DcaTransport transport;
  final Sleep sleep;
  final DeviceMirror mirror = DeviceMirror();

  StateInfo? lastState;
  Calibration? calibration;

  /// Wall-clock used for the 300 ms boost wait and one-shot timeouts.
  Stopwatch newStopwatch() => Stopwatch()..start();

  // ---------------------------------------------------------------- commands

  Future<StateInfo> getState(DeviceState ack, {Duration? timeout}) async {
    final s =
        parseState(await transport.exchange(buildState(ack), timeout: timeout));
    lastState = s;
    mirror.applyState(s);
    return s;
  }

  Future<Calibration> readCal() async {
    final c = parseCal(await transport.exchange(buildCalRead()));
    calibration = c;
    return c;
  }

  Future<void> initiateTest() => transport.exchange(buildTestInitiate());

  Future<IdentifyResult> readTestResult() async =>
      decodeResult(await transport.exchange(buildTestRead()));

  Future<AdcSnapshot> readAdcs(
      {int direct = 0, int muxed = 0, int burst = 0}) async {
    final r = await transport
        .exchange(buildAdcs(direct: direct, muxed: muxed, burst: burst));
    final a = parseAdcs(r, direct: direct != 0);
    mirror.applyAdcs(a);
    return a;
  }

  Future<AdcSnapshot> readAdcsBurst(int mask) => readAdcs(burst: mask);

  /// Battery / rails (direct mask 0x1F).
  Future<AdcRails> readRails() async =>
      (await readAdcs(direct: adcsAllRails)).rails!;

  Future<void> boostOn(double volts) => transport.exchange(buildBoost(volts));
  Future<bool> boosted() async =>
      parseBoosted(await transport.exchange(buildBoosted()));
  Future<void> boostOff() => transport.exchange(buildBoostOff());
  Future<void> leadsSafe() => transport.exchange(buildLeadsSafe());

  Future<void> setRGate(RGateIdx idx) async {
    mirror.applyRGate(parseRGate(await transport.exchange(buildRGate(idx))));
  }

  Future<void> setDacVolts(double v, Dac ch) =>
      transport.exchange(buildDacVolts(v, ch));
  Future<void> setDacAllVolts(double mt1, double mt2, double gate) =>
      transport.exchange(buildDacAllVolts(mt1, mt2, gate));
  Future<void> setMatrixRgb(Drive r, Drive g, Drive b) =>
      transport.exchange(buildMatrixRgb(r, g, b));
  Future<void> setMatrixPlus(int cfg, int ton) =>
      transport.exchange(buildMatrixPlus(cfg, ton));
  Future<void> bridgeGate(Lead lead) =>
      transport.exchange(buildBridgeGate(lead));
  Future<void> setMode(DeviceMode m) => transport.exchange(buildMode(m));

  Future<Response> ccGate(CxMode mode,
          {double milliamps = 0, int timeoutMs = 0}) =>
      transport.exchange(
          buildCcGate(mode, milliamps: milliamps, timeoutMs: timeoutMs));
  Future<Response> cvGate(CxMode mode,
          {int cfg = 0, double volts = 0, int timeoutMs = 0}) =>
      transport.exchange(
          buildCvGate(mode, cfg: cfg, volts: volts, timeoutMs: timeoutMs));

  // ------------------------------------------------------- derived readings

  double vce(int cfg) => mirror.vce(cfg);
  double vbe(int cfg) => mirror.vbe(cfg);
  double ib(int cfg) => mirror.ib(cfg);
  double ic(int cfg) => mirror.ic(cfg);

  // ------------------------------------------------- analog helpers (DCAProUnit)

  /// Poll BOOSTED for up to 300 ms. Returns false on timeout.
  Future<bool> boostWait() async {
    final sw = newStopwatch();
    while (sw.elapsedMilliseconds < 300) {
      if (await boosted()) return true;
    }
    return false;
  }

  Future<void> trnPowerOn(int cfg, int ton, double span) async {
    await boostOn(span + 0.5);
    final hi = 0.5 + span;
    if (cfg < 7) {
      await setDacAllVolts(0.5, hi, 0.5);
    } else {
      await setDacAllVolts(hi, 0.5, hi);
    }
    await setMatrixPlus(cfg <= 6 ? cfg : cfg - 6, ton);
  }

  Future<void> trnSetVc(int cfg, double v, double span) =>
      setDacVolts(cfg < 7 ? 0.5 + v : 0.5 + span - v, Dac.mt2);

  Future<void> trnSetVgate(int cfg, double v, double span) =>
      setDacVolts(cfg < 7 ? 0.5 + v : 0.5 + span - v, Dac.gate);

  Future<void> fetPowerOn(int cfg, double vgs, double vmax) async {
    await boostOn(vmax + 0.5);
    await fetSetVgs(cfg, vgs, vmax);
    await setMatrixPlus(cfg, 7); // the vendor app sends the raw cfg here
  }

  Future<void> fetSetVgs(int cfg, double vgs, double vmax) async {
    final double g, s;
    if (vgs > 0) {
      g = vgs;
      s = 0;
    } else {
      g = 0;
      s = -vgs;
    }
    if (cfg < 7) {
      await setDacAllVolts(0.5 + s, 0.5 + vmax, 0.5 + g);
    } else {
      await setDacAllVolts(0.5 + vmax - s, 0.5, 0.5 + vmax - g);
    }
  }

  ({double mt1, double mt2, double gate})? _fetNodes(
      double vds, double vgs, double vmax) {
    final double mt1, mt2, gate;
    if (vgs < 0) {
      mt2 = vmax;
      mt1 = vmax - vds;
      gate = mt1 + vgs;
    } else {
      mt1 = 0;
      mt2 = vds;
      gate = vgs;
    }
    if (mt2 > vmax + 0.5 ||
        mt2 < -0.5 ||
        mt1 > vmax + 0.5 ||
        mt1 < -0.5 ||
        gate > vmax + 0.5 ||
        gate < -0.5) {
      return null;
    }
    return (mt1: mt1, mt2: mt2, gate: gate);
  }

  Future<bool> fetSetVdsVgs(
      int cfg, double vds, double vgs, double vmax) async {
    final n = _fetNodes(vds, vgs, vmax);
    if (n == null) return false;
    if (cfg < 7) {
      await setDacAllVolts(0.5 + n.mt1, 0.5 + n.mt2, 0.5 + n.gate);
    } else {
      await setDacAllVolts(
          0.5 + (vmax - n.mt1), 0.5 + (vmax - n.mt2), 0.5 + (vmax - n.gate));
    }
    return true;
  }

  Future<bool> fetSetVds(int cfg, double vds, double vgs, double vmax) async {
    final n = _fetNodes(vds, vgs, vmax);
    if (n == null) return false;
    if (cfg < 7) {
      await setDacVolts(0.5 + n.mt1, Dac.mt1);
      await setDacVolts(0.5 + n.mt2, Dac.mt2);
    } else {
      await setDacVolts(0.5 + (vmax - n.mt1), Dac.mt1);
      await setDacVolts(0.5 + (vmax - n.mt2), Dac.mt2);
    }
    return true;
  }

  Future<void> setGateCurrent(double milliamps) =>
      ccGate(CxMode.on, milliamps: milliamps);
  Future<void> stopGateCurrent() => ccGate(CxMode.off);

  /// Arm a constant-current one-shot and wait for it to complete. On success
  /// the mirror holds a fresh ADCS read.
  Future<bool> waitForCcOneShot(int timeoutMs, bool burst) async {
    await ccGate(burst ? CxMode.oneShotBurst : CxMode.oneShot,
        timeoutMs: timeoutMs);
    final sw = newStopwatch();
    final limit = timeoutMs + 10;
    var st = 0;
    do {
      await sleep(const Duration(milliseconds: 3));
      st = ccStatus(await ccGate(CxMode.read));
    } while (!cxDone(st) && sw.elapsedMilliseconds < limit);
    if (sw.elapsedMilliseconds > limit || cxFault(st)) {
      await stopGateCurrent();
      return false;
    }
    await readAdcs();
    return true;
  }

  Future<void> setGateVoltage(double volts, int cfg, CxMode mode) =>
      cvGate(mode, cfg: cfg, volts: volts);
  Future<void> stopGateVoltage() => cvGate(CxMode.off);

  Future<bool> waitForCvOneShot(int timeoutMs, bool burst) async {
    await cvGate(burst ? CxMode.oneShotBurst : CxMode.oneShot,
        timeoutMs: timeoutMs);
    final sw = newStopwatch();
    final limit = timeoutMs + 10;
    var st = 0;
    do {
      await sleep(const Duration(milliseconds: 3));
      st = cvStatus(await cvGate(CxMode.read));
    } while (!cxDone(st) && sw.elapsedMilliseconds < limit);
    if (sw.elapsedMilliseconds > limit || cxFault(st)) {
      await stopGateVoltage();
      return false;
    }
    await readAdcs();
    return true;
  }

  /// Walk 470k → 1k0 and leave the unit on the largest resistor below
  /// [targetOhms].
  Future<RGateIdx> pickRGateBelow(double targetOhms) async {
    for (final idx in [
      RGateIdx.r470k,
      RGateIdx.r68k,
      RGateIdx.r8k2,
      RGateIdx.r1k0
    ]) {
      await setRGate(idx);
      if (mirror.rGate < targetOhms) return idx;
    }
    return RGateIdx.r1k0;
  }

  /// Put the unit in a safe state. Each step is independent; errors are
  /// swallowed so that every step is attempted.
  Future<void> safeShutdown() async {
    for (final step in [
      leadsSafe,
      () => ccGate(CxMode.off),
      () => cvGate(CxMode.off),
      () => setMode(DeviceMode.none),
    ]) {
      try {
        await step();
      } catch (_) {}
    }
  }

  static double clamp(double v, double lo, double hi) =>
      math.min(math.max(v, lo), hi);
}
