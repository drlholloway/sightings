import 'dart:typed_data';

import 'constants.dart';
import 'frame.dart';
import 'tables.dart';
import 'units.dart';

/// One measured parameter. `value` is always in SI base units (A, V, Ω, S)
/// or dimensionless; `display` is the human string the reference client
/// showed (mA, µA, …).
class Param {
  const Param({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.display,
  });
  final String key;
  final String label;
  final double value;
  final String unit;
  final String display;

  @override
  String toString() => '$label: $display';
}

/// Decoded TEST(2) result.
class IdentifyResult {
  IdentifyResult({
    required this.typeCode,
    required this.config,
    required this.flags,
    required this.name,
    required this.flagLabels,
    required this.pins,
    required this.params,
    required this.headline,
    required this.raw,
  });

  final int typeCode;
  ComponentType get type => ComponentType.fromCode(typeCode);

  /// Lead configuration 1..12 (0 when not applicable).
  final int config;
  final int flags;

  /// Human name, e.g. "NPN BJT", "N-ch JFET", "Zener".
  final String name;
  final List<String> flagLabels;
  final List<PinAssignment>? pins;
  final List<Param> params;

  /// Parameters chosen for bin statistics and sweep defaults, keyed by
  /// `Param.key`, in SI units.
  final Map<String, double> headline;

  /// The 64-byte frame, verbatim.
  final Uint8List raw;

  /// Convenience accessors used by sweep defaults.
  double? get hfe => headline['hfe'];
  double? get vgsOff => headline['vgs_off'];

  Param? param(String key) {
    for (final p in params) {
      if (p.key == key) return p;
    }
    return null;
  }

  String get rawHex => hexDump(raw);
}

/// Version of the decoder; stored with each reading so a later fix can
/// re-decode raw frames.
const int decoderVersion = 1;

/// Decode a TEST(2) response. Port of `decodeResult` in the reference client.
IdentifyResult decodeResult(Response r) {
  if (r.opcode != Opcode.test.code) {
    throw ProtocolFormatException(
        'expected TEST response, got 0x${r.opcode.toRadixString(16)}');
  }
  final b = _Builder(r);
  final type = r.u8(2);
  final cfg = r.u8(3);
  final fl = r.u8(4);

  switch (type) {
    case 1:
      _bjt(b, r, cfg, fl);
    case 2:
    case 3:
      _mosfetIgbt(b, r, type, cfg, fl);
    case 8:
      _jfet(b, r, cfg, fl);
    case 4:
    case 5:
      _scrTriac(b, r, type, cfg);
    case 6:
      _diode(b, r);
    case 7:
      _short(b, r);
    case 9:
      _vreg(b, r, cfg);
    case 10:
      b.name = 'Low battery';
    case 11:
      b.name = 'USB voltage fail';
    default:
      b.name = 'No component detected';
  }

  return IdentifyResult(
    typeCode: type,
    config: b.cfg,
    flags: fl,
    name: b.name,
    flagLabels: b.flags,
    pins: b.pins,
    params: b.params,
    headline: b.headline,
    raw: Uint8List.fromList(r.bytes),
  );
}

class _Builder {
  _Builder(this.r);
  final Response r;
  String name = '';
  int cfg = 0;
  final flags = <String>[];
  List<PinAssignment>? pins;
  final params = <Param>[];
  final headline = <String, double>{};

  void volts(String key, String label, double v) => params.add(
      Param(key: key, label: label, value: v, unit: 'V', display: eng(v, 'V')));

  /// Frame currents are in mA; store amps.
  void milliamps(String key, String label, double mA) => params.add(Param(
      key: key,
      label: label,
      value: mA / 1000,
      unit: 'A',
      display: eng(mA / 1000, 'A')));

  void ohms(String key, String label, double v) => params.add(
      Param(key: key, label: label, value: v, unit: 'Ω', display: eng(v, 'Ω')));

  void siemens(String key, String label, double v) => params.add(
      Param(key: key, label: label, value: v, unit: 'S', display: eng(v, 'S')));

  void plain(String key, String label, double v, String display) => params
      .add(Param(key: key, label: label, value: v, unit: '', display: display));

  void head(String key, double v) => headline[key] = v;
}

void _bjt(_Builder b, Response r, int cfg, int fl) {
  b.cfg = cfg;
  // IcLeak Vbe5 Vbe1 Ib5 Ib1 HFE Ic VceSat IcSat IbSat Rshunt Rinput
  final f = r.f32List(5, 12);
  final digital = (fl & bjtFlagDigital) != 0;
  final npn = (fl & bjtFlagNpn) != 0;
  final darlington = (fl & bjtFlagDarlington) != 0;

  b.flags.add(npn ? 'NPN' : 'PNP');
  if (fl & bjtFlagGermanium != 0) b.flags.add('GERMANIUM');
  if (fl & bjtFlagSilicon != 0) b.flags.add('SILICON');
  if (darlington) b.flags.add('DARLINGTON');
  if (digital) b.flags.add('DIGITAL');
  if (fl & bjtFlagCeDiode != 0) b.flags.add('C-E DIODE');
  b.name = '${npn ? 'NPN' : 'PNP'} ${darlington ? 'Darlington' : 'BJT'}';
  b.pins = pinsFor(cfg, const ['E', 'C', 'B']);

  b.plain('hfe', 'hFE (gain)', f[5], sig(f[5]));
  b.milliamps('ic_test', '@ Ic', f[6]);
  b.milliamps('ic_leak', 'Ic leakage', f[0]);
  if (digital) {
    b.volts('vi_on', 'Vi(on)', f[1]);
    b.volts('vi_off', 'Vi(off)', f[2]);
    b.milliamps('ic_on', 'Ic(on)', f[3]);
    b.milliamps('ic_off', 'Ic(off)', f[4]);
  } else {
    // f[3] / f[4] are the collector test currents at which the two Vbe
    // values were measured (5 mA and 1 mA on a 2N5088 capture), not base
    // currents as the reference client labelled them.
    b.volts('vbe_5ma', 'Vbe @ ${eng(f[3] / 1000, 'A')}', f[1]);
    b.volts('vbe_1ma', 'Vbe @ ${eng(f[4] / 1000, 'A')}', f[2]);
    b.milliamps('ic_vbe_hi', 'Ic for Vbe (hi)', f[3]);
    b.milliamps('ic_vbe_lo', 'Ic for Vbe (lo)', f[4]);
  }
  b.volts('vce_sat', 'Vce(sat)', f[7]);
  b.plain('ic_sat', 'Ic (sat test)', f[8] / 1000, eng(f[8] / 1000, 'A'));
  b.plain('ib_sat', 'Ib (sat test)', f[9] / 1000, eng(f[9] / 1000, 'A'));
  if (f[10] > 0 && f[10] < 56000) b.ohms('r_shunt', 'B-E shunt R', f[10]);
  if (digital) b.ohms('r_input', 'Input R', f[11]);

  b.head('hfe', f[5]);
  b.head('ic_leak', f[0] / 1000);
  if (!digital) b.head('vbe_5ma', f[1]);
  b.head('vce_sat', f[7]);
}

void _mosfetIgbt(_Builder b, Response r, int type, int cfg, int fl) {
  b.cfg = cfg;
  // Vgth IdOn IgOn IdOn2 VgOff IdOff gm VdsSat IdSat VgSat Rds Vsd
  final f = r.f32List(5, 12);
  final nch = (fl & fetFlagNChannel) != 0;
  final depletion = (fl & fetFlagDepletion) != 0;
  final bodyDiode = (fl & fetFlagBodyDiode) != 0;
  final isMosfet = type == 2;

  b.flags.add(nch ? 'N-CHANNEL' : 'P-CHANNEL');
  if (depletion) b.flags.add('DEPLETION');
  if (bodyDiode) b.flags.add('BODY DIODE');
  if (fl & fetFlagGateProtected != 0) b.flags.add('GATE PROTECTED');
  b.name =
      '${nch ? 'N-ch' : 'P-ch'} ${isMosfet ? (depletion ? 'depletion MOSFET' : 'MOSFET') : 'IGBT'}';
  b.pins =
      pinsFor(cfg, isMosfet ? const ['S', 'D', 'G'] : const ['E', 'C', 'G']);

  b.volts('vgs_th', 'Vgs(th)', f[0]);
  b.milliamps('id_on', 'Id(on)', f[1]);
  b.siemens('gm', 'gm / gfe', f[6]);
  b.volts('vds_sat', isMosfet ? 'Vds(sat)' : 'Vce(sat)', f[7]);
  b.milliamps('id_sat', '@ Id', f[8]);
  b.volts('vg_sat', '@ Vg', f[9]);
  b.ohms('rds_on', 'Rds(on) est', f[10]);
  if (bodyDiode) b.volts('vsd', 'Body diode Vf', f[11]);
  b.milliamps('id_off', 'Id leakage', f[5]);

  b.head('vgs_th', f[0]);
  b.head('rds_on', f[10]);
  b.head('gm', f[6]);
  b.head('id_off', f[5] / 1000);
}

void _jfet(_Builder b, Response r, int cfg, int fl) {
  b.cfg = cfg;
  // VgsOff IdOff VgsOn IdOn IdOn2 gfs Idzero Vgszero Vdszero VgsSat IgSat Rds IdRds
  final f = r.f32List(5, 13);
  final nch = (fl & jfetFlagNChannel) != 0;
  b.flags.add(nch ? 'N-CHANNEL' : 'P-CHANNEL');
  if (fl & jfetFlagSymmetric != 0) b.flags.add('SYMMETRIC D/S');
  if (fl & jfetFlagNormallyOff != 0) b.flags.add('NORMALLY OFF');
  b.name = '${nch ? 'N-ch' : 'P-ch'} JFET';
  b.pins = pinsFor(cfg, const ['S', 'D', 'G']);

  b.volts('vgs_off', 'Vgs(off) pinch-off', f[0]);
  b.milliamps('idss', 'Idss (Vgs=0)', f[6]);
  b.siemens('gfs', 'gfs', f[5]);
  b.milliamps('id_off', 'Id(off) leakage', f[1]);
  b.volts('vgs_on', 'Vgs @ on', f[2]);
  b.milliamps('id_on', 'Id @ on', f[3]);
  b.ohms('rds', 'Rds', f[11]);

  b.head('vgs_off', f[0]);
  b.head('idss', f[6] / 1000);
  b.head('gfs', f[5]);
}

void _scrTriac(_Builder b, Response r, int type, int cfg) {
  b.cfg = cfg;
  final isScr = type == 4;
  b.name = isScr ? 'Thyristor (SCR)' : 'Triac';
  b.pins =
      pinsFor(cfg, isScr ? const ['K', 'A', 'G'] : const ['MT1', 'MT2', 'G']);
  final f = r.f32List(5, 10);
  if (isScr) {
    b.milliamps('igt', 'Gate trigger Igt', f[2]);
    b.volts('vgt', 'Gate trigger Vgt', f[3]);
    b.milliamps('leak', 'Leakage', f[0]);
    b.volts('v_on', 'V(on) A-K', f[8]);
    b.head('igt', f[2] / 1000);
    b.head('vgt', f[3]);
  } else {
    b.milliamps('leak', 'Leakage', f[0]);
    b.volts('v_hold', 'V hold MT1-MT2', f[1]);
    b.head('v_hold', f[1]);
  }
}

void _diode(_Builder b, Response r) {
  final n = r.u8(3);
  final pattern = r.u8(4);
  final d1Kind = r.u8(5);
  final d1Cfg = r.u8(6);
  // Vf If Vr Ir Rp Vrp It
  final d1 = r.f32List(7, 7);
  b.name = n > 1
      ? '$n junctions'
      : (d1Kind < diodeKindNames.length && diodeKindNames[d1Kind].isNotEmpty
          ? diodeKindNames[d1Kind]
          : 'Diode');
  b.cfg = d1Cfg;
  b.pins = diodePins(d1Cfg);

  b.plain('n_junctions', 'Junctions found', n.toDouble(), '$n');
  b.plain('d1_kind', 'D1 kind', d1Kind.toDouble(),
      d1Kind < diodeKindNames.length ? diodeKindNames[d1Kind] : '$d1Kind');
  b.volts('d1_vf', 'Vf', d1[0]);
  b.milliamps('d1_if', '@ If', d1[1]);
  if (d1Kind == diodeKindZener) b.volts('d1_vz', 'Zener V', d1[2]);
  b.milliamps('d1_ir', 'Reverse I', d1[3]);
  b.head('vf', d1[0]);
  if (d1Kind == diodeKindZener) b.head('vz', d1[2]);

  if (n >= 2) {
    final d2Cfg = r.u8(36);
    // Only Vf and If fit before the end of the frame (37 + 2*4 = 45); the
    // reference client's read of seven floats here would overrun the buffer.
    final d2 = r.f32List(37, 2);
    b.plain('d2_cfg', 'D2 config', d2Cfg.toDouble(), '$d2Cfg');
    b.volts('d2_vf', 'D2 Vf', d2[0]);
    b.milliamps('d2_if', 'D2 @ If', d2[1]);
  }
  b.flags.add('pattern 0x${pattern.toRadixString(16)}');
}

void _short(_Builder b, Response r) {
  final s = r.u8(3);
  final shorted = <String>[
    if (s & shortMaskRed != 0) 'Red',
    if (s & shortMaskGreen != 0) 'Green',
    if (s & shortMaskBlue != 0) 'Blue',
  ];
  b.name = 'Short circuit';
  b.plain('shorted_mask', 'Shorted leads', s.toDouble(),
      shorted.isEmpty ? '—' : shorted.join(' + '));
}

void _vreg(_Builder b, Response r, int cfg) {
  b.cfg = cfg;
  // VReg IReg Iq Vdo dVOut
  final f = r.f32List(5, 5);
  b.name = 'Voltage regulator';
  b.pins = pinsFor(cfg, const ['In', 'Gnd', 'Out']);
  b.volts('vout', 'V out', f[0]);
  b.milliamps('iout', '@ I', f[1]);
  b.milliamps('iq', 'Quiescent I', f[2]);
  b.volts('vdo', 'Dropout V', f[3]);
  b.head('vout', f[0]);
  b.head('vdo', f[3]);
}
