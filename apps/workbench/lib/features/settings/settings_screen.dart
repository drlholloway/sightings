import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/providers.dart';
import '../../services/settings.dart';

/// Tip link shown in About.
const tipUrl = 'https://buymeacoffee.com/drlholloway';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final dbPath = ref.watch(databasePathProvider);
    final info = ref.watch(appInfoProvider);
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text('Settings', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Connect automatically'),
          subtitle: const Text('When exactly one DCA75 is plugged in.'),
          value: s.autoConnect,
          onChanged: (v) => n.update(s.copyWith(autoConnect: v)),
        ),
        SwitchListTile(
          title: const Text('Unit-button results land as drafts'),
          subtitle: const Text(
            'Off: results from the unit\'s own button are saved immediately, like app tests.',
          ),
          value: s.unitButtonAsDraft,
          onChanged: (v) => n.update(s.copyWith(unitButtonAsDraft: v)),
        ),
        SwitchListTile(
          title: const Text('Also measure at DCA55 conditions'),
          subtitle: const Text(
            'After each saved BJT identify, hold Vce at 2.5 V, servo Ic to 2.50 mA and report hFE the DCA55 way (plus Vbe at Ib ≈ 4.5 mA). Adds a few seconds per test.',
          ),
          value: s.dca55Auto,
          onChanged: (v) => n.update(s.copyWith(dca55Auto: v)),
        ),
        SwitchListTile(
          title: const Text('Also measure reverse leakage'),
          subtitle: const Text(
            'After each saved diode or transistor identify, reverse-bias the junction (collector–base for transistors, emitter open) through the 470 kΩ gate path at 5 V and 10 V and report the leakage with nA resolution.',
          ),
          value: s.leakAuto,
          onChanged: (v) => n.update(s.copyWith(leakAuto: v)),
        ),
        ListTile(
          title: const Text('Theme'),
          trailing: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'system', label: Text('System')),
              ButtonSegment(value: 'light', label: Text('Light')),
              ButtonSegment(value: 'dark', label: Text('Dark')),
            ],
            selected: {s.themeMode},
            onSelectionChanged: (v) => n.update(s.copyWith(themeMode: v.first)),
          ),
        ),
        const Divider(height: 32),
        Text(
          'DATABASE',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        ListTile(
          title: const Text('Location'),
          subtitle: Text(dbPath.value ?? '…'),
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => _backup(context, ref),
              icon: const Icon(Icons.save_alt),
              label: const Text('Backup…'),
            ),
            OutlinedButton.icon(
              onPressed: () => _restore(context, ref),
              icon: const Icon(Icons.restore),
              label: const Text('Restore…'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                final repo = await ref.read(repositoryProvider.future);
                final n = await repo.reDecodeAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Re-decoded $n readings')),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Re-decode all readings'),
            ),
          ],
        ),
        const Divider(height: 32),
        Text(
          'ABOUT',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        ListTile(
          title: const Text('Sightings — DCA75 Workbench'),
          subtitle: Text(
            'version ${info.value?.version ?? '…'} · ${Platform.operatingSystem}\n'
            '© 2026 Cryptid Effects. Source available under PolyForm Shield 1.0.0. '
            'Not affiliated with Peak Electronic Design Ltd. Never writes to the unit\'s firmware or calibration.',
          ),
          isThreeLine: true,
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('End User Licence Agreement'),
          subtitle: Text(
            'Free to use on every platform; not for redistribution.',
          ),
          onTap: () => _showEula(context),
        ),
        ListTile(
          leading: const Icon(Icons.coffee_outlined),
          title: const Text('Buy me a coffee'),
          subtitle: const Text(
            'Sightings is free. If it saved you time, a tip keeps the DCA75 fed.',
          ),
          trailing: const Icon(Icons.open_in_new, size: 18),
          onTap: () => launchUrl(
            Uri.parse(tipUrl),
            mode: LaunchMode.externalApplication,
          ),
        ),
        if (Platform.isLinux)
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Linux USB access'),
            subtitle: Text(
              'Install packaging/linux/60-dca75.rules into /etc/udev/rules.d/ and replug the unit.',
            ),
          ),
        if (Platform.isAndroid)
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Android'),
            subtitle: Text(
              'Use a USB OTG cable. Accept the permission dialog when the unit is plugged in. If the unit does not power up, use a powered OTG hub.',
            ),
          ),
      ],
    );
  }

  Future<void> _showEula(BuildContext context) async {
    final text = await rootBundle.loadString('assets/EULA.md');
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('End User Licence Agreement'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(child: SelectableText(text)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _backup(BuildContext context, WidgetRef ref) async {
    final db = await ref.read(databaseProvider.future);
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .substring(0, 19);
    final name = 'dca75-backup-$stamp.sqlite';
    String? path;
    if (Platform.isAndroid) {
      final dir = Directory.systemTemp;
      path = '${dir.path}/$name';
    } else {
      path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup',
        fileName: name,
      );
      if (path == null) return;
    }
    final f = File(path);
    if (await f.exists()) await f.delete();
    await db.backupTo(path);
    if (Platform.isAndroid) {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(path, mimeType: 'application/vnd.sqlite3')]),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Backup written to $path')));
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Restore from backup?'),
        content: const Text(
          'The current database is replaced by the chosen file (a copy of the current one is kept next to it as .bak). The app restarts its database afterwards.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Choose file…'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: 'Choose backup',
    );
    final src = picked?.files.single.path;
    if (src == null) return;
    final target = await ref.read(databasePathProvider.future);
    final db = await ref.read(databaseProvider.future);
    await db.close();
    final t = File(target);
    if (await t.exists()) await t.copy('$target.bak');
    for (final suffix in ['-wal', '-shm']) {
      final w = File('$target$suffix');
      if (await w.exists()) await w.delete();
    }
    await File(src).copy(target);
    ref.invalidate(databaseProvider);
    ref.invalidate(repositoryProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Database restored')));
    }
  }
}
