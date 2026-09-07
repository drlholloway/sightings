import 'package:dca75_protocol/dca75_protocol.dart';

export 'package:dca75_protocol/dca75_protocol.dart' show eng, sig, tick;

String fmtDateTime(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)} ${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
}

String fmtTime(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(l.hour)}:${two(l.minute)}:${two(l.second)}';
}

String fmtDate(DateTime t) {
  final l = t.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${l.year}-${two(l.month)}-${two(l.day)}';
}

/// Unit for a headline key, for axis / table labels.
String unitFor(String key) => switch (key) {
  'hfe' || 'hfe_dca55' => '',
  'gm' || 'gfs' => 'S',
  'rds_on' => 'Ω',
  'ic_leak' || 'idss' || 'igt' || 'id_off' => 'A',
  _ => 'V',
};

String labelFor(String key) => switch (key) {
  'hfe' => 'hFE',
  'hfe_dca55' => 'hFE (DCA55)',
  'vbe_dca55' => 'Vbe (DCA55)',
  'vbe_5ma' => 'Vbe @ 5 mA',
  'ic_leak' => 'Ic leakage',
  'vce_sat' => 'Vce(sat)',
  'vgs_th' => 'Vgs(th)',
  'rds_on' => 'Rds(on)',
  'gm' => 'gm',
  'vgs_off' => 'Vgs(off)',
  'idss' => 'Idss',
  'gfs' => 'gfs',
  'vf' => 'Vf',
  'vz' => 'Vz',
  'vout' => 'Vout',
  'vdo' => 'Dropout',
  'igt' => 'Igt',
  'vgt' => 'Vgt',
  'v_hold' => 'V hold',
  _ => key,
};

String fmtValue(String key, double v) =>
    key.startsWith('hfe') ? sig(v) : eng(v, unitFor(key));

/// Headline keys that make sense for a component type, in display order.
List<String> headlineKeysFor(ComponentType t) => switch (t) {
  ComponentType.bjt => const [
    'hfe',
    'hfe_dca55',
    'vbe_5ma',
    'vbe_dca55',
    'ic_leak',
    'vce_sat',
  ],
  ComponentType.mosfet ||
  ComponentType.igbt => const ['vgs_th', 'rds_on', 'gm', 'id_off'],
  ComponentType.jfet => const ['vgs_off', 'idss', 'gfs'],
  ComponentType.diode => const ['vf', 'vz'],
  ComponentType.vreg => const ['vout', 'vdo'],
  ComponentType.scr => const ['igt', 'vgt'],
  ComponentType.triac => const ['v_hold'],
  _ => const [],
};
