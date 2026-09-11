import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';

/// Kind of physical model behind a demo part.
enum DemoModelKind { bjt, jfet, diode }

/// A demo part: a real identify frame captured from a DCA75 plus the few
/// model parameters needed to produce believable curves and follow-up
/// measurements.
class DemoPart {
  const DemoPart({
    required this.name,
    required this.frameHex,
    required this.kind,
    this.hfe = 100,
    this.vbeOn = 0.65,
    this.icLeakMa = 0,
    this.earlyV = 80,
    this.icboA = 0,
    this.idssMa = 1,
    this.vp = -1,
    this.lambda = 0.02,
    this.vf = 0.65,
    this.n = 1.6,
    this.irA = 5e-9,
    this.vz = 0,
  });

  final String name;
  final String frameHex;
  final DemoModelKind kind;

  // BJT
  final double hfe, vbeOn, icLeakMa, earlyV, icboA;
  // JFET
  final double idssMa, vp, lambda;
  // Diode
  final double vf, n, irA, vz;

  Uint8List get frame => Response.fromHex(frameHex).bytes;
  IdentifyResult get identify => decodeResult(Response(frame));
}

/// Parts captured from a real unit (s/n 225000, fw 0023) on 2026‑09‑05/07.
const demoParts = <DemoPart>[
  DemoPart(
    name: '2N5088 (NPN silicon)',
    kind: DemoModelKind.bjt,
    frameHex:
        '850201045100000000BA5A443F47F9323F4D2CA040EA58803F36BFCA43CF1CA0400029C13C5BE09F403E38803F000000008BBA79420300000000000000000000',
    hfe: 405,
    vbeOn: 0.68,
    icLeakMa: 0,
    earlyV: 100,
    icboA: 3e-9,
  ),
  DemoPart(
    name: 'MP40A (PNP germanium)',
    kind: DemoModelKind.bjt,
    frameHex:
        '8502010B213E3BFF3C6A0CAA3E6C34563EBCFF9F40E958803F5517EA413505A14000FD653DE3F99F40EE117F3F00000000ECE778420200000000000000000000',
    hfe: 29,
    vbeOn: 0.22,
    icLeakMa: 0.031,
    earlyV: 60,
    icboA: 2.9e-6,
  ),
  DemoPart(
    name: 'J201 (N-channel JFET)',
    kind: DemoModelKind.jfet,
    frameHex:
        '850208010721E63BBFB7619D3B200EE83E3F8E933FE53F333F98D0C73FF1ACF73E0080F03A3CC63F406D0C2A3F1CB5233C482128443F8E933F00000000000000',
    idssMa: 0.484,
    vp: -0.734,
    lambda: 0.02,
  ),
  DemoPart(
    name: 'Silicon diode',
    kind: DemoModelKind.diode,
    frameHex:
        '850206012001066254313FBA33A040000000000000000010C7B94800A0B03E0000A0400000000040410000000000000000000000000000000000000000000000',
    vf: 0.693,
    n: 1.6,
    irA: 5e-9,
  ),
  DemoPart(
    name: 'D9B (germanium diode)',
    kind: DemoModelKind.diode,
    frameHex:
        '85020601020102A4FEE83E4FF89F400000000000000000A3C8C1448849073E0000A040C33C00004041BF6A803F000000003F526B420300000000000000000000',
    vf: 0.455,
    n: 1.4,
    irA: 3e-6,
  ),
];

/// Simulated DCA75: answers every frame the app sends, with identify results
/// taken from captured frames and analog behaviour from simple device models
/// solved against the unit's drive network (MT1 stiff, MT2 through the
/// 560 Ω sense resistor, gate through the selected gate resistor or the
/// constant-current gate controller).
class DemoUnit {
  DemoUnit({int seed = 7, List<DemoPart>? parts, this.testPolls = 20})
      : parts = parts ?? demoParts,
        _rnd = math.Random(seed);

  final List<DemoPart> parts;
  final math.Random _rnd;

  /// STATE polls after TEST(1) before the result is ready (the real unit is
  /// silent for ~3 s).
  final int testPolls;

  int index = 0;
  DemoPart get part => parts[index];
  void nextPart() => index = (index + 1) % parts.length;
  void selectPart(int i) => index = i.clamp(0, parts.length - 1);

  /// Simulate a press of the button on the unit: the next STATE poll reports
  /// TESTED, as when the user runs a test from the unit itself.
  void pressButton() {
    _rollSpread();
    _tested = true;
  }

  /// Part-to-part variation: each identify of a BJT scales its hFE (in the
  /// result frame and in the sweep model) by a random factor within
  /// ±[spread]. Zero, the default, replays the captured frame exactly.
  double spread = 0;
  double _factor = 1;
  void _rollSpread() =>
      _factor = spread == 0 ? 1 : 1 + spread * (_rnd.nextDouble() * 2 - 1);

  static const double rMt2 = 559.5;
  static const double vRef = 1.243;
  static const double vt = 0.02585;

  // ---- drive state ----
  double dacMt1 = 0.5, dacMt2 = 0.5, dacGate = 0.5;
  double rGate = 470000;
  double boostV = 0;
  bool boosted = false;
  final drives = <Lead, Drive>{
    Lead.red: Drive.none,
    Lead.green: Drive.none,
    Lead.blue: Drive.none,
  };
  int ccMode = 0;
  double ccMa = 0;
  int cvMode = 0;
  double cvVolts = 0;
  int mode = 0;

  // ---- test state ----
  int _pollsSinceTest = -1;
  bool _tested = false;

  // Last solved lead voltages (for ADCS).
  final _leadV = <Lead, double>{Lead.red: 0, Lead.green: 0, Lead.blue: 0};
  double _gateNodeV = 0, _mt2NodeV = 0, _ibMa = 0;
  final _adc = List<double>.filled(8, 0);

  double _noise(double v, [double frac = 0.003]) =>
      v * (1 + frac * (_rnd.nextDouble() * 2 - 1));

  /// Handle one outgoing frame; returns the 64-byte reply.
  Uint8List handle(Uint8List out) {
    final op = out[0];
    final b = Uint8List(frameLength)..[0] = op;
    final d = ByteData.sublistView(b);
    final od = ByteData.sublistView(out);
    switch (op) {
      case 0x86: // STATE
        var state = 0;
        if (_pollsSinceTest >= 0) {
          _pollsSinceTest++;
          if (_pollsSinceTest >= testPolls) {
            _tested = true;
            _pollsSinceTest = -1;
          } else {
            state = 1;
          }
        }
        if (_tested) state = 2;
        if (out[2] == 130 && _tested) _tested = false;
        d.setUint8(2, state);
        d.setUint16(3, 0x0001, Endian.little);
        d.setUint16(5, 0x0023, Endian.little);
        const sn = 'DEMO01';
        for (var i = 0; i < 6; i++) {
          d.setUint16(7 + 2 * i, sn.codeUnitAt(i), Endian.little);
        }
        d.setFloat32(19, rMt2, Endian.little);
      case 0x84: // CAL
        for (final (i, v)
            in [1011.98, 8110.18, 59408.7, 470261.1, rMt2].indexed) {
          d.setFloat32(2 + 4 * i, v, Endian.little);
        }
      case 0x85: // TEST
        if (out[1] == 1) {
          _rollSpread();
          _pollsSinceTest = 0;
        } else {
          b.setAll(0, part.frame);
          if (part.kind == DemoModelKind.bjt && _factor != 1) {
            // hFE is the sixth float of the BJT payload (byte 25).
            final hfe = d.getFloat32(25, Endian.little);
            d.setFloat32(25, hfe * _factor, Endian.little);
          }
        }
      case 0x83: // ADCS
        _solve();
        for (final (i, v)
            in [1.45, 1.2, boosted ? boostV : 2.99, 4.54, vRef].indexed) {
          d.setFloat32(5 + 4 * i, v, Endian.little);
        }
        final setGate = _ccActive ? _gateNodeV + _ibMa * rGate / 1000 : dacGate;
        final fresh = [
          setGate,
          _gateNodeV,
          dacMt1,
          dacMt2,
          _mt2NodeV,
          _leadV[Lead.red]!,
          _leadV[Lead.green]!,
          _leadV[Lead.blue]!,
        ];
        // Like the unit, a burst read refreshes only the channels in the
        // mask (bit0 SetGate … bit7 Blue) and reports the rest as last read.
        final mask = out[4] == 0 ? 0xFF : out[4];
        for (var i = 0; i < 8; i++) {
          if ((mask >> i) & 1 == 1) _adc[i] = fresh[i];
        }
        for (final (i, v) in _adc.indexed) {
          d.setFloat32(25 + 4 * i, v, Endian.little);
        }
      case 0x8A: // BOOST
        boostV = od.getFloat32(2, Endian.little);
        boosted = true;
      case 0x8B: // BOOSTED
        d.setUint8(1, boosted ? 1 : 0);
      case 0x8C:
        boosted = false;
      case 0x8D: // LEADSAFE
        drives.updateAll((_, __) => Drive.none);
        ccMode = 0;
        ccMa = 0;
        cvMode = 0;
      case 0x8E: // RGATE
        rGate = switch (out[2]) {
          1 => 1011.98,
          2 => 8110.18,
          3 => 59408.7,
          _ => 470261.1
        };
        d.setFloat32(3, rGate, Endian.little);
      case 0x8F: // VOLTS
        final v = od.getFloat32(2, Endian.little);
        switch (out[6]) {
          case 0:
            dacMt1 = v;
          case 1:
            dacMt2 = v;
          default:
            dacGate = v;
            if (ccMode == 7) ccMode = 0; // DAC takes the gate back
        }
      case 0x90: // ALLVOLTS
        dacMt1 = od.getFloat32(2, Endian.little);
        dacMt2 = od.getFloat32(6, Endian.little);
        dacGate = od.getFloat32(10, Endian.little);
      case 0x91: // MATRIXRGB
        drives[Lead.red] = Drive.values[out[2].clamp(0, 3)];
        drives[Lead.green] = Drive.values[out[3].clamp(0, 3)];
        drives[Lead.blue] = Drive.values[out[4].clamp(0, 3)];
      case 0x92: // MATRIXPLUS cfg -> MT1/MT2/GATE leads
        final m = cfgLeads[baseConfig(out[2])];
        if (m != null) {
          drives.updateAll((_, __) => Drive.none);
          drives[m.mt1] = Drive.mt1;
          drives[m.mt2] = Drive.mt2;
          drives[m.gate] = Drive.gate;
        }
      case 0x93:
        mode = out[2];
      case 0x94: // CCGATE
        final m = out[2];
        if (m == 3) {
          d.setUint8(9, 0x04); // done
          // A finished one-shot leaves the current in place until the DAC
          // gate is written again (the leakage-floor read relies on that).
          if (ccMode == 5 || ccMode == 6) ccMode = 7;
        } else {
          // ON carries the set-point; the one-shot frames only arm the
          // acquisition and must not disturb it.
          ccMode = m;
          if (m == 1) ccMa = od.getFloat32(3, Endian.little);
          if (m == 0) ccMa = 0;
        }
      case 0x95: // CVGATE
        final m = out[2];
        if (m == 3) {
          d.setUint8(10, 0x04);
        } else {
          cvMode = m;
          if (m == 1) cvVolts = od.getFloat32(4, Endian.little);
        }
      case 0x97: // BRIDGEGATE
        break;
      default:
        break;
    }
    return b;
  }

  bool get _ccActive =>
      ccMode == 1 || ccMode == 5 || ccMode == 6 || ccMode == 7;

  /// Solve the network for the current part and drive state.
  void _solve() {
    _leadV.updateAll((_, __) => 0);
    _gateNodeV = dacGate;
    _mt2NodeV = dacMt2;
    _ibMa = 0;
    final p = part;
    switch (p.kind) {
      case DemoModelKind.bjt:
        _solveBjt(p);
      case DemoModelKind.jfet:
        _solveJfet(p);
      case DemoModelKind.diode:
        _solveDiode(p);
    }
  }

  Drive _driveOf(Lead l) => drives[l] ?? Drive.none;

  void _solveBjt(DemoPart p) {
    final r = p.identify;
    final pins = r.pins!;
    Lead lead(String t) => pins.firstWhere((x) => x.terminal == t).lead;
    final e = lead('E'), c = lead('C'), bb = lead('B');
    final npn = (r.flags & bjtFlagNpn) != 0;
    final pol = npn ? 1.0 : -1.0;
    final de = _driveOf(e), dc = _driveOf(c), db = _driveOf(bb);

    if (de == Drive.none && dc != Drive.none && db != Drive.none) {
      // Emitter open: collector-base junction only (Icbo measurement).
      final anode = npn ? bb : c, cathode = npn ? c : bb;
      _solveJunction(anode, cathode,
          vf: p.vbeOn + 0.05, n: 1.5, irA: p.icboA, vz: 0);
      return;
    }
    if (de != Drive.mt1) {
      // Unsupported topology: leave everything at the drive voltages.
      _leadV[e] = dacMt1;
      _leadV[c] = dacMt2;
      _leadV[bb] = dacGate;
      return;
    }
    final ve = dacMt1;
    // Base drive
    double ib; // mA into the base for NPN (out of it for PNP)
    double vb;
    if (db == Drive.gate && _ccActive) {
      ib = ccMa.abs();
      vb = ve + pol * p.vbeOn;
    } else if (db == Drive.gate) {
      final vDrive = pol * (dacGate - ve);
      ib = math.max(0, vDrive - p.vbeOn) / rGate * 1000;
      vb = ib > 0 ? ve + pol * p.vbeOn : dacGate;
    } else {
      ib = 0;
      vb = ve;
    }
    // Collector through R(MT2) (or stiff if on MT1-style drive; not used).
    var ic = 0.0;
    var vce = 0.0;
    if (dc == Drive.mt2) {
      final vAvail = pol * (dacMt2 - ve); // volts available across C-E
      for (var i = 0; i < 60; i++) {
        vce = vAvail - ic / 1000 * rMt2;
        final active =
            p.hfe * _factor * ib * (1 + math.max(0, vce) / p.earlyV) +
                p.icLeakMa;
        final sat = math.max(0, vce) / 25 * 1000; // ~25 Ω saturation
        final target = vce <= 0 ? 0.0 : math.min(active, sat);
        ic += (target - ic) * 0.5;
      }
      vce = vAvail - ic / 1000 * rMt2;
    }
    final vc = ve + pol * vce;
    _ibMa = _noise(ib, 0.002);
    _leadV[e] = ve;
    _leadV[c] = _noise(vc, 0.0002);
    _leadV[bb] = vb;
    _gateNodeV = vb;
    _mt2NodeV = dc == Drive.mt2 ? _leadV[c]! : dacMt2;
    if (dc == Drive.mt2) {
      // Encode Ic in the MT2 drop with a little noise.
      _mt2NodeV = dacMt2 - pol * _noise(ic, 0.0003) / 1000 * rMt2;
      _leadV[c] = _mt2NodeV;
    }
  }

  void _solveJfet(DemoPart p) {
    final r = p.identify;
    final pins = r.pins!;
    Lead lead(String t) => pins.firstWhere((x) => x.terminal == t).lead;
    final s = lead('S'), dd = lead('D'), g = lead('G');
    final nch = (r.flags & jfetFlagNChannel) != 0;
    final pol = nch ? 1.0 : -1.0;
    if (_driveOf(s) != Drive.mt1 || _driveOf(dd) != Drive.mt2) {
      _leadV[s] = dacMt1;
      _leadV[dd] = dacMt2;
      _leadV[g] = dacGate;
      return;
    }
    final vs = dacMt1;
    // The CV gate controller holds the gate at source + Vgs; otherwise the
    // gate sits at its DAC voltage (JFET gate current is negligible).
    final vg =
        (cvMode == 1 || cvMode == 5 || cvMode == 6) ? vs + cvVolts : dacGate;
    final vgs = pol * (vg - vs);
    final vAvail = pol * (dacMt2 - vs);
    var id = 0.0, vds = 0.0;
    final vpAbs = p.vp.abs();
    for (var i = 0; i < 60; i++) {
      vds = math.max(0, vAvail - id / 1000 * rMt2);
      final vov = math.min(vgs - p.vp, vpAbs * 1.15);
      double target;
      if (vov <= 0) {
        target = 0.0001;
      } else {
        final idsat = p.idssMa * (vov / vpAbs) * (vov / vpAbs);
        target = vds < vov
            ? idsat * (2 * vds / vov - (vds / vov) * (vds / vov))
            : idsat;
        target *= 1 + p.lambda * vds;
      }
      id += (target - id) * 0.5;
    }
    vds = math.max(0, vAvail - id / 1000 * rMt2);
    _leadV[s] = vs;
    _leadV[g] = vg;
    _mt2NodeV = dacMt2 - pol * _noise(id, 0.004) / 1000 * rMt2;
    _leadV[dd] = _mt2NodeV;
    _gateNodeV = vg;
  }

  void _solveDiode(DemoPart p) {
    final r = p.identify;
    final pins = r.pins!;
    final a = pins.firstWhere((x) => x.terminal == 'A').lead;
    final k = pins.firstWhere((x) => x.terminal == 'K').lead;
    _solveJunction(a, k, vf: p.vf, n: p.n, irA: p.irA, vz: p.vz);
  }

  /// Two-terminal junction between [anode] and [cathode] leads, one of which
  /// is on the stiff MT1 drive and the other on MT2 (through 560 Ω) or the
  /// gate (through the gate resistor).
  void _solveJunction(Lead anode, Lead cathode,
      {required double vf,
      required double n,
      required double irA,
      required double vz}) {
    final da = _driveOf(anode), dk = _driveOf(cathode);
    final isSat = 5e-3 / math.exp(vf / (n * vt));
    double current(double v) {
      // amps, positive = forward
      if (v > 0) return isSat * (math.exp(math.min(v, 1.5) / (n * vt)) - 1);
      var i = -irA * (1 + 0.15 * (-v)); // gentle rise of leakage with bias
      if (vz > 0 && -v > vz) i -= ((-v) - vz) / 5.0; // breakdown, ~5 Ω
      return i;
    }

    double stiffV, driveV, rx;
    bool anodeOnResistor;
    if (da == Drive.mt1 && dk != Drive.none) {
      stiffV = dacMt1;
      anodeOnResistor = false;
      (driveV, rx) = dk == Drive.mt2 ? (dacMt2, rMt2) : (dacGate, rGate);
    } else if (dk == Drive.mt1 && da != Drive.none) {
      stiffV = dacMt1;
      anodeOnResistor = true;
      (driveV, rx) = da == Drive.mt2 ? (dacMt2, rMt2) : (dacGate, rGate);
    } else {
      _leadV[anode] = dacMt1;
      _leadV[cathode] = dacMt1;
      return;
    }
    // Unknown: v = Va - Vk. Node on resistor: Vnode = driveV - i*rx*(sign).
    // If anode on resistor: Va = driveV - i*rx, Vk = stiffV -> v = driveV - stiffV - i*rx
    // If cathode on resistor: Vk = driveV + i*rx, Va = stiffV -> v = stiffV - driveV - i*rx
    final open = anodeOnResistor ? driveV - stiffV : stiffV - driveV;
    double f(double v) => (open - v) / rx - current(v);
    var lo = -20.0, hi = 2.0;
    var v = open.clamp(lo, hi);
    for (var i = 0; i < 80; i++) {
      final fv = f(v);
      if (fv.abs() < 1e-12) break;
      if (fv > 0) {
        lo = v;
      } else {
        hi = v;
      }
      v = (lo + hi) / 2;
    }
    final i = _noise(current(v), 0.002);
    final va = anodeOnResistor ? driveV - i * rx : stiffV;
    final vk = anodeOnResistor ? stiffV : driveV + i * rx;
    _leadV[anode] = va;
    _leadV[cathode] = vk;
    final resistorLead = anodeOnResistor ? anode : cathode;
    if (_driveOf(resistorLead) == Drive.mt2) {
      _mt2NodeV = _leadV[resistorLead]!;
    } else {
      _gateNodeV = _leadV[resistorLead]!;
      _ibMa = i.abs() * 1000;
    }
  }
}
