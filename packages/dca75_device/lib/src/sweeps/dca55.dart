import 'package:dca75_protocol/dca75_protocol.dart';

import '../client.dart';
import '../timing.dart';

/// Test conditions of the Peak Atlas DCA55 (Atlas DCA User Guide, Nov 2012
/// Rev 10): hFE at Ic = 2.50 mA with Vce between 2 V and 3 V, gain computed
/// as (Ic − leakage) / Ib; Vbe at a device-dependent base current (the guide's
/// example uses 4.52 mA).
class Dca55Conditions {
  const Dca55Conditions({
    this.icTargetMa = 2.50,
    this.vceTarget = 2.5,
    this.vbeIbMa = 4.5,
    this.icToleranceMa = 0.03,
    this.vceToleranceV = 0.03,
  });

  final double icTargetMa;
  final double vceTarget;

  /// Base current used for the Vbe reading (an approximation of the DCA55's
  /// device-dependent value).
  final double vbeIbMa;
  final double icToleranceMa;
  final double vceToleranceV;

  static const standard = Dca55Conditions();
}

/// Result of a DCA55-equivalent BJT measurement.
class Dca55Result {
  const Dca55Result({
    required this.hfe,
    required this.icMa,
    required this.ibMa,
    required this.vce,
    required this.vbeAtPoint,
    required this.icLeakMa,
    required this.vbe,
    required this.vbeIbMa,
    required this.converged,
    required this.iterations,
  });

  /// (Ic − leakage) / Ib at the operating point.
  final double hfe;
  final double icMa, ibMa, vce;

  /// Vbe measured at the hFE operating point.
  final double vbeAtPoint;

  /// Collector current with the base open (through 470 kΩ at 0 V).
  final double icLeakMa;

  /// Vbe with [vbeIbMa] forced into the base and the collector at the
  /// emitter potential.
  final double vbe;
  final double vbeIbMa;

  /// False when the servo hit its iteration cap before meeting tolerance;
  /// the values are still the last measured point.
  final bool converged;
  final int iterations;

  /// Stored `reading_params` keys (all end in `_dca55` so re-decoding keeps them).
  Map<String, (double, String)> toParams() => {
        'hfe_dca55': (hfe, ''),
        'ic_dca55': (icMa / 1000, 'A'),
        'ib_dca55': (ibMa / 1000, 'A'),
        'vce_dca55': (vce, 'V'),
        'vbe_point_dca55': (vbeAtPoint, 'V'),
        'ic_leak_dca55': (icLeakMa / 1000, 'A'),
        'vbe_dca55': (vbe, 'V'),
        'ib_vbe_dca55': (vbeIbMa / 1000, 'A'),
        'converged_dca55': (converged ? 1 : 0, ''),
      };
}

/// Single-point BJT measurement at the DCA55's conditions, built from the
/// same primitives as the hFE-vs-Ic sweep. The caller must hold exclusive
/// access to the unit; on error `safeShutdown` runs before rethrowing.
class Dca55Measurement {
  Dca55Measurement(this.client, {this.conditions = Dca55Conditions.standard});

  final DcaClient client;
  final Dca55Conditions conditions;

  static const double _span = 12;
  static const int _maxIbIterations = 12;
  static const int _maxVceIterations = 20;

  /// [cfg] is the BJT configuration 1..12 from the identify result and
  /// [hfeEstimate] its hFE, used as the starting guess for Ib.
  Future<Dca55Result> run(int cfg,
      {double? hfeEstimate, CancelToken? cancel}) async {
    if (cfg < 1 || cfg > 12) throw ArgumentError('bad config $cfg');
    final tok = cancel ?? CancelToken();
    try {
      return await _run(cfg, hfeEstimate ?? 100, tok);
    } catch (_) {
      await client.safeShutdown();
      rethrow;
    }
  }

  Future<Dca55Result> _run(int cfg, double hfeGuess, CancelToken tok) async {
    final c = client;
    final k = conditions;
    final p = cfg < 7;
    await c.setMode(DeviceMode.analogUsb);
    await c.leadsSafe();

    var ib = k.icTargetMa / (hfeGuess > 0 ? hfeGuess : 100); // mA
    var ic = 0.0, vce = 0.0, ibMeas = 0.0, vbePoint = 0.0;
    var converged = false;
    var iterations = 0;
    RGateIdx rg = RGateIdx.r470k;

    await c.trnPowerOn(cfg, 7, _span);
    for (var n = 0; n < _maxIbIterations && !tok.isCancelled; n++) {
      iterations = n + 1;
      rg = await c.pickRGateBelow(ib != 0 ? 8200 / ib : 1000);
      // Vce servo at this Ib (as in the hFE-vs-Ic sweep).
      var vcTry = k.vceTarget;
      var vceOk = false;
      for (var j = 0; j < _maxVceIterations && !tok.isCancelled; j++) {
        await c.trnSetVc(cfg, vcTry, _span);
        await c.boostWait();
        await c.setGateCurrent(p ? ib : -ib);
        if (!await c.waitForCcOneShot(500, true)) break;
        vce = c.vce(cfg);
        ic = c.ic(cfg);
        if (ic > sweepCurrentLimitMa || vcTry > _span) break;
        final err = (k.vceTarget - vce).abs();
        if (err < k.vceToleranceV) {
          vceOk = true;
          break;
        }
        vcTry += (k.vceTarget - vce) * 0.9;
      }
      if (!vceOk) break;
      ibMeas = c.ib(cfg).abs();
      vbePoint = c.vbe(cfg);
      if ((ic - k.icTargetMa).abs() <= k.icToleranceMa) {
        converged = true;
        break;
      }
      // Proportional correction: hFE is roughly constant over a small step.
      if (ic > 0) {
        ib *= k.icTargetMa / ic;
      } else {
        ib *= 4;
      }
      ib = DcaClient.clamp(ib, 0.0005, 5.0);
    }

    // Leakage floor: base open through 470 kΩ at 0 V, same Vce setting.
    await c.setRGate(RGateIdx.r470k);
    await c.trnSetVgate(cfg, 0, _span);
    await c.sleep(const Duration(milliseconds: 20));
    await c.readAdcsBurst(24);
    final icZero = c.ic(cfg);
    await c.setRGate(rg);

    final hfe = ibMeas != 0 ? (ic - icZero) / ibMeas : 0.0;

    // Vbe at a forced base current with the collector at the emitter potential.
    await c.trnSetVc(cfg, 0, _span);
    await c.setRGate(RGateIdx.r1k0);
    await c.boostWait();
    await c.setGateCurrent(p ? k.vbeIbMa : -k.vbeIbMa);
    var vbe = 0.0;
    if (await c.waitForCcOneShot(500, true)) vbe = c.vbe(cfg);
    final ibVbe = c.ib(cfg).abs();

    await c.leadsSafe();
    await c.setMode(DeviceMode.none);

    return Dca55Result(
      hfe: hfe,
      icMa: ic,
      ibMa: ibMeas,
      vce: vce,
      vbeAtPoint: vbePoint,
      icLeakMa: icZero,
      vbe: vbe,
      vbeIbMa: ibVbe > 0 ? ibVbe : k.vbeIbMa,
      converged: converged,
      iterations: iterations,
    );
  }
}
