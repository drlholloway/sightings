import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/leakage.dart';

/// Reverse-leakage figures for a saved diode reading.
class LeakageCard extends ConsumerWidget {
  const LeakageCard({
    super.key,
    required this.readingId,
    required this.result,
    required this.stored,
    this.canMeasure = true,
  });

  final int readingId;
  final IdentifyResult result;
  final Map<String, (double, String)> stored;
  final bool canMeasure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final st = ref.watch(leakageProvider);
    final live = st.readingId == readingId ? st : null;
    final data =
        live?.result ??
        (stored.keys.any((k) => k.startsWith('leak_')) ? stored : null);
    final running = live?.running ?? false;
    final ak = diodeLeadsOf(result);

    String amps(double a) => a.abs() < 5e-9 ? '< 5 nA' : eng(a, 'A');
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
                    'REVERSE LEAKAGE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (running)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (canMeasure && ak != null)
                  TextButton.icon(
                    onPressed: () => ref
                        .read(leakageProvider.notifier)
                        .measure(readingId, result),
                    icon: const Icon(Icons.water_drop_outlined, size: 18),
                    label: Text(data == null ? 'Measure' : 'Re‑measure'),
                  ),
              ],
            ),
            Text(
              ak == null
                  ? 'Needs a single-junction result with both leads known.'
                  : 'Cathode ${ak.$2.label} reverse-biased through 470 kΩ (max ~25 µA); resolution a few nA.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            if (live?.error != null)
              Text(
                live!.error!,
                style: TextStyle(color: theme.colorScheme.error),
              )
            else if (data == null && !running)
              Text('Not measured yet.', style: theme.textTheme.bodySmall)
            else ...[
              for (final v in const ['5v', '10v'])
                if (data?['leak_ir_$v'] != null)
                  row(
                    'Ir @ ${eng(data!['leak_vr_$v']?.$1 ?? 0, 'V')}',
                    amps(data['leak_ir_$v']!.$1),
                  ),
              if (result.param('d1_ir') != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'DCA75 identify reverse current: ${result.param('d1_ir')!.display}.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
