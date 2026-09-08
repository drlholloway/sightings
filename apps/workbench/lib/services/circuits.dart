import 'dart:convert';

import 'package:dca75_circuits/dca75_circuits.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings.dart';

/// Marker stored in `activeCircuits` once the user has touched the set, so
/// that an empty set means "none" rather than "all".
const _touched = '__touched__';

Map<String, Object?> _overrides(Settings s) {
  try {
    return (jsonDecode(s.circuitOverridesJson) as Map).cast<String, Object?>();
  } catch (_) {
    return {};
  }
}

/// Built-in circuits with the user's edits applied.
List<CircuitProfile> circuitsOf(Settings s) {
  final o = _overrides(s);
  return [
    for (final c in defaultCircuits)
      o[c.id] is Map
          ? CircuitProfile.fromJson((o[c.id] as Map).cast<String, Object?>())
          : c,
  ];
}

final circuitsProvider = Provider<List<CircuitProfile>>((ref) {
  final json = ref.watch(
    settingsProvider.select((s) => s.circuitOverridesJson),
  );
  return circuitsOf(Settings(circuitOverridesJson: json));
});

bool isCircuitActive(Settings s, String id) =>
    s.activeCircuits.contains(_touched) ? s.activeCircuits.contains(id) : true;

/// Circuits evaluated on readings.
final activeCircuitsProvider = Provider<List<CircuitProfile>>((ref) {
  final s = ref.watch(settingsProvider);
  return [
    for (final c in ref.watch(circuitsProvider))
      if (isCircuitActive(s, c.id)) c,
  ];
});

bool circuitIsEdited(CircuitProfile c) {
  final d = defaultCircuit(c.id);
  return d != null && jsonEncode(d.toJson()) != jsonEncode(c.toJson());
}

Settings withCircuitActive(Settings s, String id, bool active) {
  final all = defaultCircuits.map((c) => c.id).toSet();
  final current = s.activeCircuits.contains(_touched)
      ? s.activeCircuits.where((x) => x != _touched).toSet()
      : all;
  active ? current.add(id) : current.remove(id);
  return s.copyWith(activeCircuits: {_touched, ...current});
}

Settings withCircuit(Settings s, CircuitProfile c) {
  final m = _overrides(s);
  final d = defaultCircuit(c.id);
  if (d != null && jsonEncode(d.toJson()) == jsonEncode(c.toJson())) {
    m.remove(c.id);
  } else {
    m[c.id] = c.toJson();
  }
  return s.copyWith(circuitOverridesJson: jsonEncode(m));
}

Settings withCircuitReset(Settings s, String id) =>
    s.copyWith(circuitOverridesJson: jsonEncode(_overrides(s)..remove(id)));

Settings withAllCircuitsReset(Settings s) =>
    s.copyWith(circuitOverridesJson: '{}', activeCircuits: const {});
