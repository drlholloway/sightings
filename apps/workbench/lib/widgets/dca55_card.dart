import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/dca55.dart';

/// DCA55-equivalent figures for a saved BJT reading, with a button to
/// measure (or re-measure) them.
class Dca55Card extends ConsumerWidget {
  const Dca55Card({
    super.key,
    required this.readingId,
    required this.result,
    required this.stored,
    this.canMeasure = true,
  });

  final int readingId;
  final IdentifyResult result;

  /// Extras already stored with the reading (`*_dca55` keys).
  final Map<String, (double, String)> stored;
  final bool canMeasure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final st = ref.watch(dca55Provider);
    final live = st.readingId == readingId ? st : null;
    final data = live?.result ?? (stored.isEmpty ? null : stored);
    final running = live?.running ?? false;
    final converged = (data?['converged_dca55']?.$1 ?? 1) != 0;

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
    String v(String key, String unit) {
      final e = data?[key];
      return e == null ? '—' : (unit.isEmpty ? sig(e.$1) : eng(e.$1, unit));
    }

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
                    'DCA55‑EQUIVALENT',
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
                else if (canMeasure)
                  TextButton.icon(
                    onPressed: () => ref
                        .read(dca55Provider.notifier)
                        .measure(readingId, result),
                    icon: const Icon(Icons.speed, size: 18),
                    label: Text(data == null ? 'Measure' : 'Re‑measure'),
                  ),
              ],
            ),
            Text(
              'hFE at Ic = 2.50 mA, Vce = 2.5 V, as the Peak DCA55 tests it; Vbe at a forced base current.',
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
              row('hFE (DCA55)', v('hfe_dca55', '')),
              row(
                'at Ic / Ib',
                '${v('ic_dca55', 'A')} / ${v('ib_dca55', 'A')}',
              ),
              row('Vce held', v('vce_dca55', 'V')),
              row('Vbe at that point', v('vbe_point_dca55', 'V')),
              row('Vbe @ Ib ${v('ib_vbe_dca55', 'A')}', v('vbe_dca55', 'V')),
              row('Ic leakage (Ib = 0)', v('ic_leak_dca55', 'A')),
              if (!converged)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Ic did not settle on 2.50 mA; figures are the last point reached.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              if (data?['hfe_dca55'] != null && result.hfe != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'DCA75 identify: hFE ${sig(result.hfe!)} at Ic 5 mA.',
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
