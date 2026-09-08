import 'package:dca75_protocol/dca75_protocol.dart';

import 'model.dart';

/// Human labels for rule keys used in profiles.
String ruleLabel(String key) => switch (key) {
      'hfe' => 'hFE',
      'ic_leak' => 'Ic leakage',
      'leak_icbo_5v' => 'Icbo @ 5 V',
      'leak_ir_5v' => 'Ir @ 5 V',
      'vf' => 'Vf',
      'vz' => 'Vz',
      'vbe_5ma' => 'Vbe',
      _ => key,
    };

/// One rule's outcome.
class RuleResult {
  const RuleResult(
      {required this.rule,
      required this.value,
      required this.pass,
      required this.text});
  final Rule rule;
  final double? value;
  final bool pass;

  /// e.g. "hFE 78 in 70–85" or "leakage 310 µA above 100 µA"
  final String text;
}

/// How a reading fits one position.
class PositionFit {
  const PositionFit({
    required this.circuit,
    required this.position,
    required this.typeMatches,
    required this.results,
  });
  final CircuitProfile circuit;
  final CircuitPosition position;

  /// Component kind, polarity and material match; rules only evaluated then.
  final bool typeMatches;
  final List<RuleResult> results;

  bool get fits => typeMatches && results.every((r) => r.pass);
  String? get firstFailure =>
      results.where((r) => !r.pass).map((r) => r.text).firstOrNull;
}

/// Material of a measured part, from the identify flags for transistors and
/// from Vf for diodes (the unit does not report diode material).
PartMaterial materialOf(IdentifyResult r, Map<String, double> values) {
  if (r.type == ComponentType.bjt) {
    if ((r.flags & bjtFlagGermanium) != 0) return PartMaterial.germanium;
    if ((r.flags & bjtFlagSilicon) != 0) return PartMaterial.silicon;
    return PartMaterial.any;
  }
  if (r.type == ComponentType.diode) {
    final kind = r.param('d1_kind')?.value;
    if (kind == 2 || kind == 3) return PartMaterial.led;
    final vf = values['vf'] ?? r.headline['vf'];
    if (vf == null) return PartMaterial.any;
    if (vf >= 1.2) return PartMaterial.led;
    // Germanium (and Schottky) sit below ~0.5 V at 5 mA; silicon above 0.55 V.
    return vf < 0.52 ? PartMaterial.germanium : PartMaterial.silicon;
  }
  return PartMaterial.any;
}

Polarity polarityOf(IdentifyResult r) {
  if (r.type != ComponentType.bjt) return Polarity.any;
  return (r.flags & bjtFlagNpn) != 0 ? Polarity.npn : Polarity.pnp;
}

PartKind? kindOf(IdentifyResult r) => switch (r.type) {
      ComponentType.bjt => PartKind.bjt,
      ComponentType.diode => PartKind.diode,
      ComponentType.jfet => PartKind.jfet,
      _ => null,
    };

String _fmt(String key, double v) =>
    key == 'hfe' ? sig(v, 3) : eng(v, key.startsWith('v') ? 'V' : 'A');

/// Evaluate one reading against the given (active) circuits. [values] are
/// the reading's stored parameters by key, SI units: headline keys plus the
/// `*_dca55` and `leak_*` extras when measured.
List<PositionFit> evaluate(
  IdentifyResult r,
  Map<String, double> values,
  Iterable<CircuitProfile> circuits,
) {
  final kind = kindOf(r);
  final pol = polarityOf(r);
  final mat = materialOf(r, values);
  final out = <PositionFit>[];
  for (final c in circuits) {
    for (final p in c.positions) {
      final typeOk = kind == p.kind &&
          (p.polarity == Polarity.any || p.polarity == pol) &&
          (p.material == PartMaterial.any || p.material == mat);
      final results = <RuleResult>[];
      if (typeOk) {
        for (final rule in p.rules) {
          var key = rule.key;
          double? v;
          if (key == 'hfe') {
            v = values[c.hfeKey] ?? values['hfe'] ?? r.hfe;
            if (values[c.hfeKey] != null) key = c.hfeKey;
          } else {
            v = values[rule.key] ??
                r.headline[rule.key] ??
                r.param(rule.key)?.value;
          }
          final label =
              ruleLabel(rule.key) + (key == 'hfe_dca55' ? ' (DCA55)' : '');
          if (v == null) {
            results.add(RuleResult(
                rule: rule,
                value: null,
                pass: false,
                text: '$label not measured'));
            continue;
          }
          final lo = rule.min, hi = rule.max;
          final pass = (lo == null || v >= lo) && (hi == null || v <= hi);
          final String text;
          if (pass) {
            final range = lo != null && hi != null
                ? '${_fmt(rule.key, lo)}–${_fmt(rule.key, hi)}'
                : lo != null
                    ? '≥ ${_fmt(rule.key, lo)}'
                    : '≤ ${_fmt(rule.key, hi!)}';
            text = '$label ${_fmt(rule.key, v)} in $range';
          } else if (lo != null && v < lo) {
            text = '$label ${_fmt(rule.key, v)} below ${_fmt(rule.key, lo)}';
          } else {
            text = '$label ${_fmt(rule.key, v)} above ${_fmt(rule.key, hi!)}';
          }
          results.add(RuleResult(rule: rule, value: v, pass: pass, text: text));
        }
      }
      out.add(PositionFit(
          circuit: c, position: p, typeMatches: typeOk, results: results));
    }
  }
  return out;
}
