import 'dart:math' as math;

import 'package:dca75_protocol/dca75_protocol.dart';

import '../client.dart';
import '../timing.dart';
import 'sweep.dart';

/// Runs the five curve sweeps. Port of `SWEEPS.*` in the reference client;
/// every constant, delay and guard is preserved. The caller must hold
/// exclusive access to the unit (see `DeviceController.exclusive`).
///
/// `run` yields events; on completion (normal or cancelled) the unit has
/// been returned to leads-safe / mode NONE. On error, `safeShutdown()` is
/// run before the error propagates.
class SweepEngine {
  SweepEngine(this.client);

  final DcaClient client;

  static const double _span = 12;

  Stream<SweepEvent> run(
    SweepParams params, {
    IdentifyResult? last,
    CancelToken? cancel,
  }) async* {
    final tok = cancel ?? CancelToken();
    final cfg = _cfgFor(params, last);
    _validate(params);
    final inner = switch (params) {
      IcVceParams p => _icvce(p, cfg, tok),
      HfeIcParams p => _hfeic(p, cfg, tok),
      IdVdsParams p => _idvds(p, cfg, tok),
      IdVgsParams p => _idvgs(p, cfg, tok),
      PnIvParams p => _pniv(p, tok),
    };
    try {
      // `yield*` would forward errors to the listener without running the
      // catch below; iterate explicitly so a failure shuts the unit down.
      await for (final e in inner) {
        yield e;
      }
    } catch (_) {
      await client.safeShutdown();
      rethrow;
    }
  }

  int _cfgFor(SweepParams p, IdentifyResult? last) {
    if (p.kind.need == SweepNeed.none) return 0;
    if (!p.kind.canRun(last)) {
      throw ArgumentError(
          '${p.kind.title} needs a ${p.kind.need.name.toUpperCase()} identify result');
    }
    final cfg = last!.config;
    if (cfg < 1 || cfg > 12) throw ArgumentError('bad config $cfg');
    return cfg;
  }

  /// Parameter checks that must fail before any frame is sent.
  void _validate(SweepParams p) {
    if (p is PnIvParams) {
      if (p.anode == p.cathode ||
          p.anode == Lead.none ||
          p.cathode == Lead.none) {
        throw ArgumentError('anode and cathode must be two different leads');
      }
    }
  }

  double _lerp(double a, double b, int i, int n) =>
      n <= 1 ? a : a + i * (b - a) / (n - 1);

  // ------------------------------------------------------------------ BJT

  Stream<SweepEvent> _icvce(IcVceParams p, int cfg, CancelToken tok) async* {
    final nTr = math.max(1, p.traces), nPt = math.max(1, p.points);
    final ibMax = p.ibMaxUa / 1000, ibMin = p.ibMinUa / 1000; // mA
    final c = client;
    await c.setMode(DeviceMode.analogUsb);
    await c.leadsSafe();
    for (var i = 0; i < nTr && !tok.isCancelled; i++) {
      final ib = nTr <= 1 ? ibMax : ibMax - i * (ibMax - ibMin) / (nTr - 1);
      await c.pickRGateBelow(10200 / ib);
      await c.trnPowerOn(cfg, 7, _span);
      await c.trnSetVc(cfg, p.vcMin, _span);
      await c.boostWait();
      await c.setGateCurrent(cfg < 7 ? ib : -ib);
      await c.sleep(const Duration(milliseconds: 24));
      yield SweepTraceStarted(i, 'Ib=${(ib * 1000).toStringAsPrecision(3)} µA');
      for (var j = 0; j < nPt && !tok.isCancelled; j++) {
        final vc = _lerp(p.vcMin, p.vcMax, j, nPt);
        await c.trnSetVc(cfg, vc, _span);
        await c.boostWait();
        if (!await c.waitForCcOneShot(200, true)) break;
        final ic = c.ic(cfg);
        if (ic > sweepCurrentLimitMa) break;
        yield SweepPoint(i, c.vce(cfg), ic);
        yield SweepProgress(100 * (j + 1 + i * nPt) / (nPt * nTr));
      }
      await c.leadsSafe();
    }
    await c.setMode(DeviceMode.none);
  }

  Stream<SweepEvent> _hfeic(HfeIcParams p, int cfg, CancelToken tok) async* {
    final nPt = math.max(2, p.points);
    final ibMax = p.ibMaxUa / 1000, ibMin = p.ibMinUa / 1000; // mA
    final vceTarget = p.vce;
    final c = client;
    await c.setMode(DeviceMode.analogUsb);
    await c.leadsSafe();
    yield SweepTraceStarted(0, 'Vce=${vceTarget.toStringAsPrecision(3)} V');
    for (var j = 0; j < nPt && !tok.isCancelled; j++) {
      final ib = ibMin + j * (ibMax - ibMin) / (nPt - 1);
      final rgIdx = await c.pickRGateBelow(ib != 0 ? 8200 / ib : 1000);
      await c.trnPowerOn(cfg, 7, _span);
      var vcTry = vceTarget, ic = 0.0;
      var okPoint = false;
      for (var k = 0; k < 20 && !tok.isCancelled; k++) {
        await c.trnSetVc(cfg, vcTry, _span);
        await c.boostWait();
        await c.setGateCurrent(cfg < 7 ? ib : -ib);
        if (!await c.waitForCcOneShot(500, true)) break;
        final vceMeas = c.vce(cfg);
        ic = c.ic(cfg);
        if (ic > sweepCurrentLimitMa || vcTry > _span) break;
        final err = (vceTarget - vceMeas).abs();
        if (err < 0.003 || err < (0.001 * vceTarget).abs()) {
          okPoint = true;
          break;
        }
        vcTry += (vceTarget - vceMeas) * 0.9;
      }
      // leakage floor: base open through 470k at 0 V
      await c.setRGate(RGateIdx.r470k);
      await c.trnSetVgate(cfg, 0, _span);
      await c.sleep(const Duration(milliseconds: 20));
      await c.readAdcsBurst(24); // VR_MT2
      final icZero = c.ic(cfg);
      await c.setRGate(rgIdx);
      if (okPoint) {
        final ibMeas = c.ib(cfg);
        if (ibMeas != 0) yield SweepPoint(0, ic, (ic - icZero) / ibMeas);
      } else {
        break;
      }
      yield SweepProgress(100 * (j + 1) / nPt);
    }
    await c.leadsSafe();
    await c.setMode(DeviceMode.none);
  }

  // ------------------------------------------------------------------ FET

  Stream<SweepEvent> _idvds(IdVdsParams p, int cfg, CancelToken tok) async* {
    final nTr = math.max(1, p.traces), nPt = math.max(1, p.points);
    final c = client;
    await c.setMode(DeviceMode.analogUsb);
    await c.leadsSafe();
    await c.setRGate(RGateIdx.r8k2);
    for (var i = 0; i < nTr && !tok.isCancelled; i++) {
      final vgs = _lerp(p.vgsMin, p.vgsMax, i, nTr);
      await c.fetPowerOn(cfg, vgs, _span);
      await c.fetSetVdsVgs(cfg, p.vdsMin, vgs, _span);
      await c.setGateVoltage(cfg < 7 ? vgs : -vgs, cfg, CxMode.on);
      await c.sleep(const Duration(milliseconds: 24));
      yield SweepTraceStarted(i, 'Vgs=${vgs.toStringAsPrecision(3)} V');
      for (var j = 0; j < nPt && !tok.isCancelled; j++) {
        final vds = _lerp(p.vdsMin, p.vdsMax, j, nPt);
        var bad = !await c.fetSetVds(cfg, vds, vgs, _span);
        await c.setGateVoltage(cfg < 7 ? vgs : -vgs, cfg, CxMode.on);
        await c.boostWait();
        if (!await c.waitForCvOneShot(500, true)) bad = true;
        final id = c.ic(cfg);
        if (id > sweepCurrentLimitMa) bad = true;
        if (bad) break;
        yield SweepPoint(i, c.vce(cfg), id);
        yield SweepProgress(100 * (j + 1 + i * nPt) / (nPt * nTr));
      }
      await c.leadsSafe();
    }
    await c.setMode(DeviceMode.none);
  }

  Stream<SweepEvent> _idvgs(IdVgsParams p, int cfg, CancelToken tok) async* {
    final nPt = math.max(2, p.points);
    final vdsTarget = p.vds;
    const lsb = dacLsbVolts;
    final c = client;
    await c.setMode(DeviceMode.analogUsb);
    await c.leadsSafe();
    await c.setRGate(RGateIdx.r8k2);
    await c.fetPowerOn(cfg, p.vgsMin, _span);
    await c.fetSetVdsVgs(cfg, vdsTarget, p.vgsMin, _span);
    await c.sleep(const Duration(milliseconds: 50));
    yield SweepTraceStarted(0, 'Vds=${vdsTarget.toStringAsPrecision(3)} V');
    for (var j = 0; j < nPt && !tok.isCancelled; j++) {
      final vgs = p.vgsMin + j * (p.vgsMax - p.vgsMin) / (nPt - 1);
      var vds = vdsTarget, step = vds / 2;
      var phase = vds == 0 ? 2 : 0, dir = 0, iter = 0;
      var bad = false, seeking = true;
      do {
        if (!await c.fetSetVds(cfg, vds, vgs, _span)) {
          bad = true;
          break;
        }
        await c.boostWait();
        await c.setGateVoltage(cfg < 7 ? vgs : -vgs, cfg, CxMode.on);
        if (!await c.waitForCvOneShot(500, false)) {
          bad = true;
          break;
        }
        final meas = c.vce(cfg);
        if (phase == 0) {
          if (meas < vdsTarget) {
            if (vds < 3) {
              vds *= 2;
            } else {
              vds = 6;
              step = vds / 2;
              phase++;
            }
          } else if (meas > vdsTarget) {
            step = vds / 2;
            phase++;
          } else {
            seeking = false;
          }
        } else if (phase == 1) {
          if (meas < vdsTarget) {
            vds += step;
          } else if (meas > vdsTarget) {
            vds -= step;
          } else {
            seeking = false;
          }
          step /= 2;
          if (step < lsb * 2) phase++;
        } else {
          step = lsb * 0.99;
          if (meas >= vdsTarget) {
            if (dir == -1) {
              seeking = false;
            } else {
              vds -= step;
            }
            dir = 1;
          } else {
            dir = -1;
            vds += step;
          }
        }
        vds = DcaClient.clamp(vds, 0, _span);
        if (++iter > 64) {
          bad = true;
          seeking = false;
        }
      } while (phase < 3 && seeking && !tok.isCancelled);
      await c.readAdcsBurst(248);
      final id = c.ic(cfg);
      if (id >= sweepCurrentLimitMa || bad || seeking) break;
      yield SweepPoint(0, c.vbe(cfg), id);
      yield SweepProgress(100 * (j + 1) / nPt);
    }
    await c.leadsSafe();
    await c.setMode(DeviceMode.none);
  }

  // ---------------------------------------------------------------- diode

  Stream<SweepEvent> _pniv(PnIvParams p, CancelToken tok) async* {
    final nPt = math.max(1, p.points);
    final anode = p.anode, cath = p.cathode;
    final fwd = p.forward;
    var cfg = configFrom12G(cath, anode);
    if (!fwd) cfg = revM1M2[cfg]!;

    // lead drives: anode -> MT2, cathode -> MT1 when forward (swapped when reverse)
    final drives = <Lead, Drive>{
      Lead.red: Drive.none,
      Lead.green: Drive.none,
      Lead.blue: Drive.none,
    };
    drives[anode] = fwd ? Drive.mt2 : Drive.mt1;
    drives[cath] = fwd ? Drive.mt1 : Drive.mt2;
    final spare = [Lead.red, Lead.green, Lead.blue]
        .firstWhere((l) => l != anode && l != cath);
    var bridge = Lead.none;
    if (p.thirdLead != ThirdLead.open) drives[spare] = Drive.gate;
    if (p.thirdLead == ThirdLead.lowToAnode) bridge = anode;
    if (p.thirdLead == ThirdLead.lowToCathode) bridge = cath;

    final c = client;
    await c.setMode(DeviceMode.analogUsb);
    await c.leadsSafe();
    await c.boostOn(0.5 + math.max(p.vMax, p.vMin));
    await c.setDacAllVolts(0.5, 0.5, 0.5);
    await c.setRGate(RGateIdx.r470k);
    await c.setMatrixRgb(
        drives[Lead.red]!, drives[Lead.green]!, drives[Lead.blue]!);
    if (bridge != Lead.none) await c.bridgeGate(bridge);
    yield SweepTraceStarted(
        0,
        fwd
            ? '${anode.label}→${cath.label}'
            : '${cath.label}→${anode.label} (rev)');
    for (var i = 0; i < nPt && !tok.isCancelled; i++) {
      final vs =
          0.5 + (nPt > 1 ? p.vMin + (p.vMax - p.vMin) * i / (nPt - 1) : p.vMin);
      await c.setDacVolts(vs, Dac.mt2);
      if (p.thirdLead == ThirdLead.r470kToVs) await c.setDacVolts(vs, Dac.gate);
      if (p.thirdLead == ThirdLead.r470kToGnd) await c.setDacVolts(0, Dac.gate);
      await c.sleep(const Duration(milliseconds: 20));
      await c.boostWait();
      await c.readAdcsBurst(248);
      final cur = c.ic(cfg);
      if (cur > sweepCurrentLimitMa) break;
      yield SweepPoint(0, c.vce(cfg), cur);
      yield SweepProgress(100 * (i + 1) / nPt);
    }
    await c.leadsSafe();
    await c.setMode(DeviceMode.none);
  }
}
