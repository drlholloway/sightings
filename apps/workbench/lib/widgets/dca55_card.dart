import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/dca55.dart';
import 'section_card.dart';

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

    String v(String key, String unit) {
      final e = data?[key];
      return e == null ? '—' : (unit.isEmpty ? sig(e.$1) : eng(e.$1, unit));
    }

    return SectionCard(
      title: 'DCA55‑EQUIVALENT',
      action: MeasureAction(
        running: running,
        measured: data != null,
        icon: Icons.speed,
        onMeasure: canMeasure
            ? () => ref.read(dca55Provider.notifier).measure(readingId, result)
            : null,
      ),
      children: [
        const CardNote(
          'hFE at Ic = 2.50 mA, Vce = 2.5 V, as the Peak DCA55 tests it; Vbe at a forced base current.',
        ),
        const SizedBox(height: 8),
        if (live?.error != null)
          Text(live!.error!, style: TextStyle(color: theme.colorScheme.error))
        else if (data == null && !running)
          Text('Not measured yet.', style: theme.textTheme.bodySmall)
        else ...[
          ValueRow('hFE (DCA55)', v('hfe_dca55', '')),
          ValueRow(
            'at Ic / Ib',
            '${v('ic_dca55', 'A')} / ${v('ib_dca55', 'A')}',
          ),
          ValueRow('Vce held', v('vce_dca55', 'V')),
          ValueRow('Vbe at that point', v('vbe_point_dca55', 'V')),
          ValueRow('Vbe @ Ib ${v('ib_vbe_dca55', 'A')}', v('vbe_dca55', 'V')),
          ValueRow('Ic leakage (Ib = 0)', v('ic_leak_dca55', 'A')),
          if (!converged)
            const CardNote(
              'Ic did not settle on 2.50 mA; figures are the last point reached.',
              gap: true,
              error: true,
            ),
          if (data?['hfe_dca55'] != null && result.hfe != null)
            CardNote(
              'DCA75 identify: hFE ${sig(result.hfe!)} at Ic 5 mA.',
              gap: true,
            ),
        ],
      ],
    );
  }
}
