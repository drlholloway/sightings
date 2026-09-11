import 'package:dca75_circuits/dca75_circuits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/circuits.dart';
import '../../services/settings.dart';

/// Pedal Builder: the circuit profiles, which are active, and their rules.
class CircuitsScreen extends ConsumerWidget {
  const CircuitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final circuits = ref.watch(circuitsProvider);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Circuits', style: theme.textTheme.titleLarge),
            ),
            TextButton.icon(
              onPressed: () => n.update(withAllCircuitsReset(s)),
              icon: const Icon(Icons.restore),
              label: const Text('Reset all to defaults'),
            ),
          ],
        ),
        Text(
          'Active circuits are checked against every transistor and diode you measure; the reading shows which positions the part is valid for. '
          'Edit any range (press Enter) and it is remembered; Reset restores the built-in values.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final c in circuits)
          _CircuitTile(circuit: c, active: isCircuitActive(s, c.id)),
      ],
    );
  }
}

class _CircuitTile extends ConsumerWidget {
  const _CircuitTile({required this.circuit, required this.active});
  final CircuitProfile circuit;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final edited = circuitIsEdited(circuit);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Switch(
          value: active,
          onChanged: (v) => n.update(withCircuitActive(s, circuit.id, v)),
        ),
        title: Text(circuit.name + (edited ? '  (edited)' : '')),
        subtitle: Text(
          '${circuit.family} · ${circuit.positions.length} position${circuit.positions.length == 1 ? '' : 's'}'
          '${circuit.hfeKey == 'hfe_dca55' && circuit.positions.any((p) => p.kind == PartKind.bjt) ? ' · gain judged by the DCA55-equivalent hFE when measured' : ''}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          if (circuit.notes != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(circuit.notes!, style: theme.textTheme.bodySmall),
              ),
            ),
          for (final p in circuit.positions)
            _PositionEditor(circuit: circuit, position: p),
          Row(
            children: [
              if (circuit.source != null)
                Expanded(
                  child: Text(
                    'Source: ${circuit.source}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              TextButton(
                onPressed: edited
                    ? () => n.update(withCircuitReset(s, circuit.id))
                    : null,
                child: const Text('Reset to default'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Unit shown/edited for a rule key: hFE plain, currents in µA, volts in V.
({String unit, double scale}) _unitFor(String key) => key == 'hfe'
    ? (unit: '', scale: 1)
    : key.startsWith('v')
    ? (unit: 'V', scale: 1)
    : (unit: 'µA', scale: 1e6);

class _PositionEditor extends ConsumerWidget {
  const _PositionEditor({required this.circuit, required this.position});
  final CircuitProfile circuit;
  final CircuitPosition position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final kind = switch (position.kind) {
      PartKind.bjt => 'BJT',
      PartKind.diode => 'diode',
      PartKind.jfet => 'JFET',
    };
    final pol = position.polarity == Polarity.any
        ? ''
        : ' ${position.polarity.name.toUpperCase()}';
    final mat = position.material == PartMaterial.any
        ? ''
        : ' ${position.material.name}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${position.label} — ${position.role}',
            style: theme.textTheme.titleSmall,
          ),
          Text(
            '$mat$pol $kind'.trim(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              for (final (i, r) in position.rules.indexed)
                _RuleFields(
                  rule: r,
                  onChanged: (nr) {
                    final rules = [...position.rules]..[i] = nr;
                    n.update(
                      withCircuit(
                        s,
                        circuit.copyWith(
                          positions: [
                            for (final p in circuit.positions)
                              p.id == position.id
                                  ? p.copyWith(rules: rules)
                                  : p,
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuleFields extends StatelessWidget {
  const _RuleFields({required this.rule, required this.onChanged});
  final Rule rule;
  final ValueChanged<Rule> onChanged;

  @override
  Widget build(BuildContext context) {
    final u = _unitFor(rule.key);
    String show(double? v) =>
        v == null ? '' : _trim((v * u.scale).toStringAsPrecision(4));
    Widget field(String label, double? value, void Function(double?) set) =>
        SizedBox(
          width: 110,
          child: TextFormField(
            key: ValueKey('${rule.key}-$label-$value'),
            initialValue: show(value),
            decoration: InputDecoration(
              labelText: '$label${u.unit.isEmpty ? '' : ' (${u.unit})'}',
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onFieldSubmitted: (t) {
              final v = double.tryParse(t.trim());
              set(v == null ? null : v / u.scale);
            },
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            ruleLabel(rule.key),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        field(
          'min',
          rule.min,
          (v) => onChanged(
            v == null ? rule.copyWith(clearMin: true) : rule.copyWith(min: v),
          ),
        ),
        const SizedBox(width: 8),
        field(
          'max',
          rule.max,
          (v) => onChanged(
            v == null ? rule.copyWith(clearMax: true) : rule.copyWith(max: v),
          ),
        ),
      ],
    );
  }
}

String _trim(String s) {
  if (!s.contains('.') || s.contains('e')) return s;
  var t = s;
  while (t.endsWith('0')) {
    t = t.substring(0, t.length - 1);
  }
  return t.endsWith('.') ? t.substring(0, t.length - 1) : t;
}
