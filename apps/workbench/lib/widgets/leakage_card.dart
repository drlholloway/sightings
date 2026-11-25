import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/leakage.dart';
import 'section_card.dart';

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
    final plan = LeakageNotifier.planFor(result);
    final isBjt = result.type == ComponentType.bjt;
    final ip = plan?.prefix ?? 'ir';
    final vp = plan?.voltPrefix ?? 'vr';

    String amps(double a) => a.abs() < 5e-9 ? '< 5 nA' : eng(a, 'A');

    return SectionCard(
      title: 'REVERSE LEAKAGE',
      action: MeasureAction(
        running: running,
        measured: data != null,
        icon: Icons.water_drop_outlined,
        onMeasure: canMeasure && plan != null
            ? () =>
                  ref.read(leakageProvider.notifier).measure(readingId, result)
            : null,
      ),
      children: [
        CardNote(
          plan == null
              ? 'Needs a result with the junction leads known.'
              : isBjt
              ? 'Icbo: collector–base junction reverse-biased through 470 kΩ, emitter open (max ~25 µA); resolution a few nA.'
              : 'Cathode ${plan.cathode.label} reverse-biased through 470 kΩ (max ~25 µA); resolution a few nA.',
        ),
        const SizedBox(height: 8),
        if (live?.error != null)
          Text(live!.error!, style: TextStyle(color: theme.colorScheme.error))
        else if (data == null && !running)
          Text('Not measured yet.', style: theme.textTheme.bodySmall)
        else ...[
          for (final v in const ['5v', '10v'])
            if (data?['leak_${ip}_$v'] != null)
              ValueRow(
                '${isBjt ? 'Icbo' : 'Ir'} @ ${eng(data!['leak_${vp}_$v']?.$1 ?? 0, 'V')}',
                amps(data['leak_${ip}_$v']!.$1),
              ),
          if (isBjt && result.param('ic_leak') != null)
            CardNote(
              'DCA75 identify Ic leakage (Iceo, base open): ${result.param('ic_leak')!.display}.',
              gap: true,
            ),
          if (result.param('d1_ir') != null)
            CardNote(
              'DCA75 identify reverse current: ${result.param('d1_ir')!.display}.',
              gap: true,
            ),
        ],
      ],
    );
  }
}
