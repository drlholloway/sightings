import 'dart:convert';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/format.dart';
import '../../services/providers.dart';
import '../../widgets/histogram.dart';
import '../history/history_screen.dart' show historyFilterProvider;

class BinScreen extends ConsumerStatefulWidget {
  const BinScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<BinScreen> createState() => _BinScreenState();
}

class _BinScreenState extends ConsumerState<BinScreen> {
  BinRow? _bin;
  PartRow? _part;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(repositoryProvider.future);
    final bins = await repo.listBins();
    final bin = bins.where((b) => b.id == widget.id).firstOrNull;
    final parts = await repo.listParts();
    if (!mounted) return;
    setState(() {
      _bin = bin;
      _part = parts.where((p) => p.id == bin?.partId).firstOrNull;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = _bin;
    if (b == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/parts/${b.partId}'),
            ),
            Expanded(
              child: Text(
                '${_part?.displayName ?? ''} — bin “${b.name}”',
                style: theme.textTheme.titleLarge,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                ref.read(historyFilterProvider.notifier).state = ReadingFilter(
                  binId: b.id,
                );
                context.go('/history');
              },
              icon: const Icon(Icons.history),
              label: Text('${b.readingCount} readings'),
            ),
            IconButton(
              tooltip: 'Export bin CSV',
              icon: const Icon(Icons.download_outlined),
              onPressed: () async {
                final repo = await ref.read(repositoryProvider.future);
                final rows = await repo.listReadings(
                  ReadingFilter(binId: b.id, limit: 100000),
                );
                final csv = readingsCsv(rows);
                await SharePlus.instance.share(
                  ShareParams(
                    files: [
                      XFile.fromData(
                        utf8.encode(csv),
                        mimeType: 'text/csv',
                        name: 'bin-${b.name}.csv',
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        BinStatsPanel(binId: b.id, family: _part?.family),
      ],
    );
  }
}

/// Statistics table + histogram + nearest-match tool for a bin or a part.
class BinStatsPanel extends ConsumerStatefulWidget {
  const BinStatsPanel({super.key, this.binId, this.partId, this.family});
  final int? binId;
  final int? partId;
  final String? family;

  @override
  ConsumerState<BinStatsPanel> createState() => _BinStatsPanelState();
}

class _BinStatsPanelState extends ConsumerState<BinStatsPanel> {
  Map<String, BinStats> _stats = const {};
  String? _key;
  List<ReadingRow> _members = const [];
  int? _pick;
  List<(int, double, double)> _nearest = const [];

  List<String> get _keys {
    final t = ComponentType.values
        .where((t) => t.name == widget.family)
        .firstOrNull;
    return t == null ? headlineKeys : headlineKeysFor(t);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(BinStatsPanel old) {
    super.didUpdateWidget(old);
    if (old.binId != widget.binId || old.partId != widget.partId) _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(repositoryProvider.future);
    final out = <String, BinStats>{};
    for (final k in _keys) {
      final s = await repo.binStats(
        k,
        binId: widget.binId,
        partId: widget.binId == null ? widget.partId : null,
      );
      if (s.n > 0) out[k] = s;
    }
    final members = await repo.listReadings(
      ReadingFilter(
        binId: widget.binId,
        partId: widget.binId == null ? widget.partId : null,
        limit: 5000,
      ),
    );
    if (!mounted) return;
    setState(() {
      _stats = out;
      _key ??= out.keys.firstOrNull;
      if (_key != null && !out.containsKey(_key)) _key = out.keys.firstOrNull;
      _members = members;
    });
  }

  Future<void> _findNearest(int id) async {
    final repo = await ref.read(repositoryProvider.future);
    final n = await repo.nearestReadings(
      _key!,
      id,
      5,
      binId: widget.binId,
      partId: widget.binId == null ? widget.partId : null,
    );
    if (!mounted) return;
    setState(() {
      _pick = id;
      _nearest = n;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_stats.isEmpty) {
      return Text(
        'No measured values yet.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final key = _key!;
    final s = _stats[key]!;
    final sorted = [..._members]
      ..sort((a, b) => (a.headline[key] ?? 0).compareTo(b.headline[key] ?? 0));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 18,
            headingRowHeight: 32,
            dataRowMinHeight: 30,
            dataRowMaxHeight: 34,
            columns: const [
              DataColumn(label: Text('Parameter')),
              DataColumn(label: Text('n'), numeric: true),
              DataColumn(label: Text('min'), numeric: true),
              DataColumn(label: Text('p5'), numeric: true),
              DataColumn(label: Text('p25'), numeric: true),
              DataColumn(label: Text('median'), numeric: true),
              DataColumn(label: Text('p75'), numeric: true),
              DataColumn(label: Text('p95'), numeric: true),
              DataColumn(label: Text('max'), numeric: true),
              DataColumn(label: Text('mean'), numeric: true),
              DataColumn(label: Text('σ'), numeric: true),
            ],
            rows: [
              for (final e in _stats.entries)
                DataRow(
                  selected: e.key == key,
                  onSelectChanged: (_) => setState(() {
                    _key = e.key;
                    _nearest = const [];
                    _pick = null;
                  }),
                  cells: [
                    DataCell(
                      Text(
                        labelFor(e.key),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text('${e.value.n}')),
                    for (final v in [
                      e.value.min,
                      e.value.p5,
                      e.value.p25,
                      e.value.median,
                      e.value.p75,
                      e.value.p95,
                      e.value.max,
                      e.value.mean,
                      e.value.stddev,
                    ])
                      DataCell(Text(fmtValue(e.key, v))),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${labelFor(key)} distribution',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 4),
        HistogramChart(
          stats: s,
          marker: _pick == null
              ? null
              : _members.where((m) => m.id == _pick).firstOrNull?.headline[key],
          height: 140,
        ),
        const SizedBox(height: 16),
        Text(
          'MEMBERS BY ${labelFor(key).toUpperCase()} — tap one to find its closest matches',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 0.8,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final m in sorted)
              if (m.headline[key] != null)
                ChoiceChip(
                  label: Text(
                    '#${m.id} ${fmtValue(key, m.headline[key]!)}${m.label?.isNotEmpty ?? false ? ' ${m.label}' : ''}',
                  ),
                  selected: m.id == _pick,
                  onSelected: (_) => _findNearest(m.id),
                ),
          ],
        ),
        if (_nearest.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Closest to #$_pick by ${labelFor(key)}:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          for (final (id, v, d) in _nearest)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('#$id  ${fmtValue(key, v)}  (Δ ${fmtValue(key, d)})'),
              onTap: () => context.go('/history/$id'),
            ),
        ],
      ],
    );
  }
}
