import 'package:dca75_circuits/dca75_circuits.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/circuits.dart';
import '../services/dca55.dart';
import '../services/leakage.dart';
import '../services/settings.dart';

/// "Valid for" card: which active circuit positions this reading fits.
class CircuitFitCard extends ConsumerWidget {
  const CircuitFitCard({
    super.key,
    required this.readingId,
    required this.result,
    required this.stored,
  });
  final int readingId;
  final IdentifyResult result;

  /// Extras stored with the reading (`*_dca55`, `leak_*`).
  final Map<String, (double, String)> stored;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(settingsProvider.select((s) => s.pedalBuilder))) {
      return const SizedBox.shrink();
    }
    if (kindOf(result) == null || result.type == ComponentType.jfet) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final circuits = ref.watch(activeCircuitsProvider);
    // Values: headline + stored extras + live follow-up results for this reading.
    final values = <String, double>{...result.headline};
    for (final e in stored.entries) {
      values[e.key] = e.value.$1;
    }
    for (final st in [ref.watch(dca55Provider), ref.watch(leakageProvider)]) {
      if (st.readingId == readingId && st.result != null) {
        for (final e in st.result!.entries) {
          values[e.key] = e.value.$1;
        }
      }
    }
    final fits = evaluate(result, values, circuits);
    final good = fits.where((f) => f.fits).toList();
    final near = fits.where((f) => !f.fits && f.typeMatches).toList();
    final chip = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'PEDAL CIRCUITS',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/circuits'),
                  child: const Text('Edit circuits'),
                ),
              ],
            ),
            if (circuits.isEmpty)
              Text(
                'No circuits are active. Turn some on under Circuits.',
                style: theme.textTheme.bodySmall,
              )
            else if (good.isEmpty && near.isEmpty)
              Text(
                'No active circuit uses this kind of part.',
                style: theme.textTheme.bodySmall,
              )
            else ...[
              if (good.isNotEmpty) ...[
                Text(
                  'Valid for',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final f in good)
                      Tooltip(
                        message: f.results.map((r) => r.text).join('\n'),
                        child: Chip(
                          avatar: Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
                          label: Text(
                            '${f.circuit.name} · ${f.position.label}',
                            style: chip,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ],
              if (near.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Not for',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                for (final f in near)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '${f.circuit.name} · ${f.position.label}: ${f.firstFailure}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
