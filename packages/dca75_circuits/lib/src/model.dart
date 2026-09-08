/// Which kind of part a position takes.
enum PartKind { bjt, diode, jfet }

enum Polarity { any, npn, pnp }

enum PartMaterial { any, germanium, silicon, led }

/// A numeric acceptance rule on a stored reading parameter (SI units).
/// [key] is a `reading_params` key such as `hfe`, `ic_leak`, `vf`,
/// `leak_icbo_5v`; either bound may be null.
class Rule {
  const Rule({required this.key, this.min, this.max});
  final String key;
  final double? min;
  final double? max;

  Map<String, Object?> toJson() => {'key': key, 'min': min, 'max': max};
  factory Rule.fromJson(Map<String, Object?> j) => Rule(
        key: j['key'] as String,
        min: (j['min'] as num?)?.toDouble(),
        max: (j['max'] as num?)?.toDouble(),
      );

  Rule copyWith(
          {double? min,
          double? max,
          bool clearMin = false,
          bool clearMax = false}) =>
      Rule(
        key: key,
        min: clearMin ? null : (min ?? this.min),
        max: clearMax ? null : (max ?? this.max),
      );
}

/// One slot in a circuit: Q1, D2, ...
class CircuitPosition {
  const CircuitPosition({
    required this.id,
    required this.label,
    required this.role,
    required this.kind,
    this.polarity = Polarity.any,
    this.material = PartMaterial.any,
    this.rules = const [],
    this.notes,
  });

  final String id;
  final String label;
  final String role;
  final PartKind kind;
  final Polarity polarity;
  final PartMaterial material;
  final List<Rule> rules;
  final String? notes;

  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
        'role': role,
        'kind': kind.name,
        'polarity': polarity.name,
        'material': material.name,
        'rules': rules.map((r) => r.toJson()).toList(),
        'notes': notes,
      };
  factory CircuitPosition.fromJson(Map<String, Object?> j) => CircuitPosition(
        id: j['id'] as String,
        label: j['label'] as String,
        role: j['role'] as String,
        kind: PartKind.values.byName(j['kind'] as String),
        polarity: Polarity.values.byName(j['polarity'] as String? ?? 'any'),
        material: PartMaterial.values.byName(j['material'] as String? ?? 'any'),
        rules: [
          for (final r in (j['rules'] as List? ?? const []))
            Rule.fromJson((r as Map).cast())
        ],
        notes: j['notes'] as String?,
      );

  CircuitPosition copyWith({List<Rule>? rules}) => CircuitPosition(
        id: id,
        label: label,
        role: role,
        kind: kind,
        polarity: polarity,
        material: material,
        rules: rules ?? this.rules,
        notes: notes,
      );
}

/// A circuit with its positions. `hfeKey` says which gain figure the rules
/// on `hfe` should read: the DCA75's own (`hfe`) or the DCA55-equivalent
/// (`hfe_dca55`), which most builder lore for germanium is based on.
class CircuitProfile {
  const CircuitProfile({
    required this.id,
    required this.name,
    required this.family,
    required this.positions,
    this.hfeKey = 'hfe_dca55',
    this.source,
    this.notes,
  });

  final String id;
  final String name;
  final String family;
  final List<CircuitPosition> positions;
  final String hfeKey;
  final String? source;
  final String? notes;

  Map<String, Object?> toJson() => {
        'id': id,
        'name': name,
        'family': family,
        'hfeKey': hfeKey,
        'source': source,
        'notes': notes,
        'positions': positions.map((p) => p.toJson()).toList(),
      };
  factory CircuitProfile.fromJson(Map<String, Object?> j) => CircuitProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        family: j['family'] as String,
        hfeKey: j['hfeKey'] as String? ?? 'hfe_dca55',
        source: j['source'] as String?,
        notes: j['notes'] as String?,
        positions: [
          for (final p in (j['positions'] as List))
            CircuitPosition.fromJson((p as Map).cast())
        ],
      );

  CircuitProfile copyWith({List<CircuitPosition>? positions, String? hfeKey}) =>
      CircuitProfile(
        id: id,
        name: name,
        family: family,
        positions: positions ?? this.positions,
        hfeKey: hfeKey ?? this.hfeKey,
        source: source,
        notes: notes,
      );
}
