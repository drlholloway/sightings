/// Engineering-notation formatter, identical in behavior to the reference
/// client's `eng()`: `212 mA`, `4.70 kΩ`, `1.23e-13 A`.
String eng(double? v, String unit, {int digits = 3}) {
  if (v == null || v.isNaN) return '—';
  if (v == 0) return '0 $unit';
  final a = v.abs();
  const pre = <(double, String)>[
    (1e9, 'G'),
    (1e6, 'M'),
    (1e3, 'k'),
    (1, ''),
    (1e-3, 'm'),
    (1e-6, 'µ'),
    (1e-9, 'n'),
    (1e-12, 'p'),
  ];
  for (final (m, p) in pre) {
    if (a >= m) return '${(v / m).toStringAsPrecision(digits)} $p$unit';
  }
  return '${v.toStringAsExponential(2)} $unit';
}

/// Fixed significant digits without a unit; used for hFE and similar ratios.
String sig(double v, [int digits = 4]) => v.toStringAsPrecision(digits);

/// Shortest representation with at most `digits` significant figures
/// (`+t.toPrecision(6)` in JavaScript). Used for axis ticks.
String tick(double v, [int digits = 6]) {
  if (v == 0) return '0';
  final s = v.toStringAsPrecision(digits);
  if (s.contains('e')) return double.parse(s).toString();
  if (!s.contains('.')) return s;
  var t = s;
  while (t.endsWith('0')) {
    t = t.substring(0, t.length - 1);
  }
  if (t.endsWith('.')) t = t.substring(0, t.length - 1);
  return t;
}
