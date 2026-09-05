import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/format.dart';
import '../../services/providers.dart';
import '../history/history_screen.dart';
import 'bin_screen.dart';

class PartScreen extends ConsumerStatefulWidget {
  const PartScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<PartScreen> createState() => _PartScreenState();
}

class _PartScreenState extends ConsumerState<PartScreen> {
  PartRow? _part;
  List<BinRow> _bins = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(repositoryProvider.future);
    final parts = await repo.listParts();
    final bins = await repo.listBins(partId: widget.id);
    if (!mounted) return;
    setState(() {
      _part = parts.where((p) => p.id == widget.id).firstOrNull;
      _bins = bins;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = _part;
    if (p == null) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/parts'),
            ),
            Expanded(
              child: Text(p.displayName, style: theme.textTheme.titleLarge),
            ),
            TextButton.icon(
              onPressed: () {
                ref.read(historyFilterProvider.notifier).state = ReadingFilter(
                  partId: p.id,
                );
                context.go('/history');
              },
              icon: const Icon(Icons.history),
              label: Text('${p.readingCount} readings'),
            ),
          ],
        ),
        if (p.description != null)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Text(p.description!),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'BINS',
              style: theme.textTheme.labelMedium?.copyWith(
                letterSpacing: 1,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _newBin,
              icon: const Icon(Icons.add),
              label: const Text('New bin'),
            ),
          ],
        ),
        for (final b in _bins)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(b.name),
            subtitle: Text(
              '${b.readingCount} readings · created ${fmtDate(b.createdAt)}${b.notes != null ? ' · ${b.notes}' : ''}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/bins/${b.id}'),
          ),
        const SizedBox(height: 16),
        Text(
          'ALL READINGS OF THIS PART',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        BinStatsPanel(partId: p.id, family: p.family),
      ],
    );
  }

  Future<void> _newBin() async {
    final ctl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New bin'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, ctl.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final repo = await ref.read(repositoryProvider.future);
    await repo.createBin(widget.id, name);
    await _load();
  }
}
