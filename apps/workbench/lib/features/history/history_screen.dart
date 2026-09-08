import 'dart:convert';
import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/format.dart';
import '../../services/providers.dart';
import '../../widgets/pinout.dart';

final historyFilterProvider = StateProvider<ReadingFilter>(
  (ref) => const ReadingFilter(),
);

final historyRowsProvider = StreamProvider<List<ReadingRow>>((ref) async* {
  final repo = await ref.watch(repositoryProvider.future);
  yield* repo.watchReadings(ref.watch(historyFilterProvider));
});

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _selected = <int>{};
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = ref.watch(historyRowsProvider);
    final filter = ref.watch(historyFilterProvider);
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'label, notes, part, bin',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (t) =>
                      ref.read(historyFilterProvider.notifier).state = filter
                          .copyWith(text: t),
                ),
              ),
              for (final t in const [
                ComponentType.bjt,
                ComponentType.mosfet,
                ComponentType.jfet,
                ComponentType.diode,
                ComponentType.vreg,
              ])
                FilterChip(
                  label: Text(t.typeName),
                  selected: filter.types.contains(t),
                  onSelected: (on) {
                    final types = {...filter.types};
                    on ? types.add(t) : types.remove(t);
                    ref.read(historyFilterProvider.notifier).state = filter
                        .copyWith(types: types);
                  },
                ),
              FilterChip(
                label: const Text('Untagged'),
                selected: filter.untaggedOnly,
                onSelected: (on) =>
                    ref.read(historyFilterProvider.notifier).state = filter
                        .copyWith(untaggedOnly: on),
              ),
              FilterChip(
                label: const Icon(Icons.star, size: 16),
                selected: filter.starredOnly,
                onSelected: (on) =>
                    ref.read(historyFilterProvider.notifier).state = filter
                        .copyWith(starredOnly: on),
              ),
              if (filter.partId != null || filter.binId != null)
                InputChip(
                  label: const Text('part/bin filter'),
                  onDeleted: () =>
                      ref.read(historyFilterProvider.notifier).state = filter
                          .copyWith(clearPart: true, clearBin: true),
                ),
              if (_selected.isNotEmpty) ...[
                Text(
                  '${_selected.length} selected',
                  style: theme.textTheme.labelMedium,
                ),
                TextButton(onPressed: _tagSelected, child: const Text('Tag…')),
                TextButton(
                  onPressed: _deleteSelected,
                  child: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(_selected.clear),
                  child: const Text('Clear'),
                ),
              ],
              IconButton(
                tooltip: 'Export CSV',
                icon: const Icon(Icons.download_outlined),
                onPressed: rows.value == null || rows.value!.isEmpty
                    ? null
                    : () => _export(rows.value!),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: rows.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(
                    child: Text(
                      'No readings yet.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) => _ReadingTile(
                      row: list[i],
                      selected: _selected.contains(list[i].id),
                      onSelect: (on) => setState(
                        () => on
                            ? _selected.add(list[i].id)
                            : _selected.remove(list[i].id),
                      ),
                      onTap: () => context.go('/history/${list[i].id}'),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _export(List<ReadingRow> rows) async {
    final csv = readingsCsv(rows);
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            utf8.encode(csv),
            mimeType: 'text/csv',
            name: 'dca75-readings.csv',
          ),
        ],
        subject: 'DCA75 readings',
      ),
    );
  }

  Future<void> _deleteSelected() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Delete ${_selected.length} readings?'),
        content: const Text(
          'Their sweeps stay but lose the link. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final repo = await ref.read(repositoryProvider.future);
    await repo.deleteReadings(_selected.toList());
    setState(_selected.clear);
  }

  Future<void> _tagSelected() async {
    final repo = await ref.read(repositoryProvider.future);
    final parts = await repo.listParts();
    if (!mounted) return;
    int? partId;
    int? binId;
    List<BinRow> bins = const [];
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, set) => AlertDialog(
          title: Text('Tag ${_selected.length} readings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int?>(
                decoration: const InputDecoration(labelText: 'Part'),
                items: [
                  for (final p in parts)
                    DropdownMenuItem(value: p.id, child: Text(p.displayName)),
                ],
                onChanged: (v) async {
                  partId = v;
                  binId = null;
                  bins = v == null ? const [] : await repo.listBins(partId: v);
                  set(() {});
                },
              ),
              DropdownButtonFormField<int?>(
                key: ValueKey(partId),
                decoration: const InputDecoration(labelText: 'Bin'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('— none —'),
                  ),
                  for (final b in bins)
                    DropdownMenuItem(value: b.id, child: Text(b.name)),
                ],
                onChanged: (v) => binId = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if (ok != true || partId == null) return;
    await repo.tagMany(_selected.toList(), partId: partId, binId: binId);
    setState(_selected.clear);
  }
}

class _ReadingTile extends StatelessWidget {
  const _ReadingTile({
    required this.row,
    required this.selected,
    required this.onSelect,
    required this.onTap,
  });
  final ReadingRow row;
  final bool selected;
  final ValueChanged<bool> onSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = headlineKeysFor(row.type)
        .where(row.headline.containsKey)
        .take(3);
    final result = decodeResult(Response(minimalFrame(row)));
    return ListTile(
      leading: Checkbox(
        value: selected,
        onChanged: (v) => onSelect(v ?? false),
      ),
      title: Row(
        children: [
          Expanded(child: Text(row.name, style: theme.textTheme.titleSmall)),
          if (row.starred)
            Icon(Icons.star, size: 16, color: Colors.amber.shade700),
        ],
      ),
      subtitle: Text(
        [
          fmtDateTime(row.takenAt),
          if (row.partNumber != null) row.partNumber!,
          if (row.binName != null) 'bin ${row.binName}',
          if (row.label?.isNotEmpty ?? false) row.label!,
          for (final k in keys)
            '${labelFor(k)} ${fmtValue(k, row.headline[k]!)}',
        ].join(' · '),
      ),
      trailing: PinoutWidget(pins: result.pins, compact: true),
      onTap: onTap,
    );
  }
}

/// The list only needs pins, which depend on type/config; rebuild a minimal
/// frame rather than loading raw bytes for every row.
Uint8List minimalFrame(ReadingRow r) {
  final b = Uint8List(64)..[0] = 0x85;
  b[2] = r.typeCode;
  b[3] = r.config;
  b[4] = r.flags;
  if (r.typeCode == 6) {
    b[5] = 1;
    b[6] = r.config;
  }
  return b;
}
