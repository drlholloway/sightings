import 'package:dca75_protocol/dca75_protocol.dart';

import '../client.dart';
import '../timing.dart';

/// One reverse-leakage point.
class LeakPoint {
  const LeakPoint(
      {required this.vrRequested,
      required this.vrMeasured,
      required this.irAmps});
  final double vrRequested;

  /// Reverse voltage actually across the junction (cathode lead − anode lead).
  final double vrMeasured;

  /// Reverse current, baseline-corrected. Positive = leakage.
  final double irAmps;
}

/// Reverse-leakage measurement through the gate path.
///
/// Routing: cathode lead → GATE drive (through the 470 kΩ gate resistor),
/// anode lead → MT1 held at the 0.5 V reference, spare lead open. The gate
/// DAC is raised to 0.5 V + Vr, so the junction sees Vr reverse bias and the
/// current is (SetGate − Gate) / R_gate, the same path the unit uses for base
/// current, with a floor of a few nA. The 470 kΩ limits current to ~25 µA at
/// 12 V, so zeners and LEDs cannot be harmed.
///
/// A zero-volt baseline is taken first and subtracted to cancel the offset
/// between the two ADC channels.
class LeakageMeasurement {
  LeakageMeasurement(this.client,
      {this.settle = const Duration(milliseconds: 100)});

  final DcaClient client;
  final Duration settle;

  /// ADCS burst mask: SetGate, Gate and the three lead voltages.
  static const int _mask = 0xE3;

  /// Gate-path current in amps from the mirror (config 1: no sign flip).
  double _gateAmps() => client.ib(1) / 1000;

  Stream<LeakPoint> sweep(Lead anode, Lead cathode, List<double> volts,
      {CancelToken? cancel}) async* {
    if (anode == cathode || anode == Lead.none || cathode == Lead.none) {
      throw ArgumentError('anode and cathode must be two different leads');
    }
    final tok = cancel ?? CancelToken();
    final c = client;
    final vMax = volts.fold(0.0, (m, v) => v > m ? v : m);
    try {
      await c.setMode(DeviceMode.analogUsb);
      await c.leadsSafe();
      await c.setRGate(RGateIdx.r470k);
      await c.boostOn(vMax + 0.5);
      await c.setDacAllVolts(0.5, 0.5, 0.5);
      final drives = <Lead, Drive>{
        Lead.red: Drive.none,
        Lead.green: Drive.none,
        Lead.blue: Drive.none
      };
      drives[cathode] = Drive.gate;
      drives[anode] = Drive.mt1;
      await c.setMatrixRgb(
          drives[Lead.red]!, drives[Lead.green]!, drives[Lead.blue]!);

      // Baseline at zero reverse bias.
      await c.setDacVolts(0.5, Dac.gate);
      await c.sleep(settle);
      await c.readAdcsBurst(_mask);
      final i0 = _gateAmps();

      for (final vr in volts) {
        if (tok.isCancelled) break;
        await c.setDacVolts(DcaClient.clamp(0.5 + vr, 0.5, 12.5), Dac.gate);
        await c.boostWait();
        await c.sleep(settle);
        await c.readAdcsBurst(_mask);
        final ir = _gateAmps() - i0;
        final vrMeas = c.mirror.leadVolts(cathode) - c.mirror.leadVolts(anode);
        yield LeakPoint(vrRequested: vr, vrMeasured: vrMeas, irAmps: ir);
      }
      await c.leadsSafe();
      await c.setMode(DeviceMode.none);
    } catch (_) {
      await c.safeShutdown();
      rethrow;
    }
  }

  /// Fixed-voltage points for the Identify card, keyed for `reading_params`
  /// (`leak_ir_5v`, `leak_vr_5v`, ...). Keys start with `leak_` so re-decoding
  /// keeps them.
  Future<Map<String, (double, String)>> measurePoints(Lead anode, Lead cathode,
      {List<double> volts = const [5, 10], CancelToken? cancel}) async {
    final out = <String, (double, String)>{};
    await for (final p in sweep(anode, cathode, volts, cancel: cancel)) {
      final tag = '${p.vrRequested.round()}v';
      out['leak_ir_$tag'] = (p.irAmps, 'A');
      out['leak_vr_$tag'] = (p.vrMeasured, 'V');
    }
    return out;
  }
}
