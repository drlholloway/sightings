import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/format.dart';
import '../../services/providers.dart';
import '../../widgets/circuit_fit_card.dart';
import '../../widgets/dca55_card.dart';
import '../../widgets/leakage_card.dart';
import '../../widgets/result_card.dart';
import '../../widgets/tag_strip.dart';

class ReadingDetailScreen extends ConsumerStatefulWidget {
  const ReadingDetailScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<ReadingDetailScreen> createState() =>
      _ReadingDetailScreenState();
}

class _ReadingDetailScreenState extends ConsumerState<ReadingDetailScreen> {
  ReadingDetail? _d;
  bool _missing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(repositoryProvider.future);
    final d = await repo.loadReading(widget.id);
    if (!mounted) return;
    setState(() {
      _d = d;
      _missing = d == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = _d;
    if (_missing) return const Center(child: Text('Reading not found.'));
    if (d == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/history'),
            ),
            Text('Reading #${d.row.id}', style: theme.textTheme.titleLarge),
            const Spacer(),
            FilledButton.tonalIcon(
              onPressed: () {
                ref
                    .read(lastResultProvider.notifier)
                    .set(
                      LastResult(
                        event: IdentifyEvent(
                          result: d.result,
                          source: d.row.source,
                          at: d.row.takenAt,
                        ),
                        readingId: d.row.id,
                      ),
                    );
                context.go('/curves');
              },
              icon: const Icon(Icons.show_chart),
              label: const Text('Use for curves'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, c) {
            final card = Column(
              children: [
                ResultCard(result: d.result),
                if (d.result.type == ComponentType.bjt) ...[
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) => Dca55Card(
                      readingId: d.row.id,
                      result: d.result,
                      stored: d.extras,
                      canMeasure:
                          ref.watch(statusProvider).state ==
                          ConnectionState.idle,
                    ),
                  ),
                ],
                if ((d.result.type == ComponentType.diode ||
                    d.result.type == ComponentType.bjt)) ...[
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) => LeakageCard(
                      readingId: d.row.id,
                      result: d.result,
                      stored: d.extras,
                      canMeasure:
                          ref.watch(statusProvider).state ==
                          ConnectionState.idle,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                CircuitFitCard(
                  readingId: d.row.id,
                  result: d.result,
                  stored: d.extras,
                ),
              ],
            );
            final meta = _Meta(d: d, onChanged: _load);
            if (c.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 420, child: card),
                  const SizedBox(width: 18),
                  Expanded(child: meta),
                ],
              );
            }
            return Column(children: [card, const SizedBox(height: 18), meta]);
          },
        ),
      ],
    );
  }
}

class _Meta extends ConsumerWidget {
  const _Meta({required this.d, required this.onChanged});
  final ReadingDetail d;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    Widget kv(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              k,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(v, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SavedReadingTagStrip(
          readingId: d.row.id,
          family: d.result.type.name,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                kv('Taken', fmtDateTime(d.row.takenAt)),
                kv(
                  'Source',
                  d.row.source == ReadingSource.unitButton
                      ? 'unit button'
                      : d.row.source.name,
                ),
                kv('Device', d.deviceSerial ?? '—'),
                kv('Session', '#${d.row.sessionId}'),
                kv(
                  'Battery',
                  d.battV == null ? '—' : '${d.battV!.toStringAsFixed(2)} V',
                ),
                kv(
                  '12 V rail',
                  d.v12V == null ? '—' : '${d.v12V!.toStringAsFixed(2)} V',
                ),
                kv(
                  'Vref',
                  d.vrefV == null ? '—' : '${d.vrefV!.toStringAsFixed(3)} V',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SWEEPS',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        if (d.sweeps.isEmpty)
          Text('None yet.', style: theme.textTheme.bodySmall)
        else
          for (final s in d.sweeps)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.show_chart),
              title: Text(s.kind.title),
              subtitle: Text(
                '${fmtDateTime(s.startedAt)} · ${s.traceCount} traces · ${s.pointCount} points'
                '${s.cancelled ? ' · cancelled' : ''}${s.error != null ? ' · ${s.error}' : ''}',
              ),
              onTap: () => context.go('/curves?sweep=${s.id}'),
            ),
      ],
    );
  }
}
