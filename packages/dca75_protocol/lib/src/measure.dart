import 'constants.dart';
import 'frame.dart';
import 'parsers.dart';
import 'tables.dart';

/// Mirror of the unit's analog state, updated from ADCS / RGATE / STATE
/// responses, plus the `Determine*` formulas from the vendor app.
///
/// One instance lives for the life of a connection. It is deliberately
/// mutable: the sweep algorithms read `ic(cfg)` etc. right after a burst
/// read, exactly like the reference client.
class DeviceMirror {
  double setGate = 0, gate = 0, setMt1 = 0, setMt2 = 0, mt2 = 0;
  double red = 0, green = 0, blue = 0;
  double batt = 0, bTest = 0, v12 = 0, prereg = 0, vRef = 0;

  /// Currently selected gate resistor (ohms). 10 MΩ until RGATE is set.
  double rGate = 1e7;

  /// Calibrated MT2 sense resistor (ohms). Default until STATE reports it.
  double rMt2 = 620;

  void applyState(StateInfo s) {
    final r = s.rMt2;
    if (r != null) rMt2 = r;
  }

  void applyAdcs(AdcSnapshot a) {
    final v = a.always;
    setGate = v.setGate;
    gate = v.gate;
    setMt1 = v.setMt1;
    setMt2 = v.setMt2;
    mt2 = v.mt2;
    red = v.red;
    green = v.green;
    blue = v.blue;
    final rails = a.rails;
    if (rails != null) {
      batt = rails.batt;
      bTest = rails.bTest;
      v12 = rails.v12;
      prereg = rails.prereg;
      vRef = rails.vRef;
    }
  }

  void applyAdcsResponse(Response r, {required bool direct}) =>
      applyAdcs(parseAdcs(r, direct: direct));

  void applyRGate(double? ohms) {
    if (ohms != null && ohms > 0) rGate = ohms;
  }

  double leadVolts(Lead l) => switch (l) {
        Lead.red => red,
        Lead.green => green,
        Lead.blue => blue,
        Lead.none => 0,
      };

  /// Collector–emitter (or drain–source) voltage for a configuration.
  double vce(int cfg) {
    final (p, n) = vceTab[cfg]!;
    return leadVolts(p) - leadVolts(n);
  }

  /// Base–emitter (or gate–source) voltage for a configuration.
  double vbe(int cfg) {
    final (p, n) = vbeTab[cfg]!;
    return leadVolts(p) - leadVolts(n);
  }

  /// Base current in mA.
  double ib(int cfg) {
    final v = 1000 * (setGate - gate) / rGate;
    return isPConfig(cfg) ? -v : v;
  }

  /// Collector / drain current in mA, with the reference's zero floor.
  double ic(int cfg) {
    var v = (setMt2 - mt2) * (1000 / rMt2);
    if (isPConfig(cfg)) v = -v;
    if (v <= (1000 / rMt2) * icZeroFloorFactor) v = 0;
    return v;
  }
}
