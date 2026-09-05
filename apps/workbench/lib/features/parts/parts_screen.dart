import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/providers.dart';

final partsProvider = StreamProvider<List<PartRow>>((ref) async* {
  final repo = await ref.watch(repositoryProvider.future);
  yield* repo.watchParts();
});

class PartsScreen extends ConsumerWidget {
  const PartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parts = ref.watch(partsProvider);
    final theme = Theme.of(context);
    return parts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
            child: Row(
              children: [
                Text('Parts', style: theme.textTheme.titleLarge),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () => _newPart(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('New part'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'No parts yet. Tag a reading with a part number to create one.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, i) => ListTile(
                      title: Text(list[i].displayName),
                      subtitle: Text(
                        [
                          if (list[i].family != null)
                            list[i].family!.toUpperCase(),
                          if (list[i].description != null) list[i].description!,
                          '${list[i].readingCount} readings',
                          '${list[i].binCount} bins',
                        ].join(' · '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/parts/${list[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _newPart(BuildContext context, WidgetRef ref) async {
    final pn = TextEditingController(),
        mf = TextEditingController(),
        ds = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New part'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pn,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Part number'),
            ),
            TextField(
              controller: mf,
              decoration: const InputDecoration(
                labelText: 'Manufacturer (optional)',
              ),
            ),
            TextField(
              controller: ds,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (ok != true || pn.text.trim().isEmpty) return;
    final repo = await ref.read(repositoryProvider.future);
    await repo.upsertPart(
      partNumber: pn.text,
      manufacturer: mf.text.trim().isEmpty ? null : mf.text.trim(),
      description: ds.text.trim().isEmpty ? null : ds.text.trim(),
    );
  }
}
