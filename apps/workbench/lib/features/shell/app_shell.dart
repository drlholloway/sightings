import 'dart:io';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/drafts.dart';
import '../../services/providers.dart';

const _destinations = [
  (
    path: '/identify',
    icon: Icons.bolt_outlined,
    selected: Icons.bolt,
    label: 'Identify',
  ),
  (
    path: '/curves',
    icon: Icons.show_chart_outlined,
    selected: Icons.show_chart,
    label: 'Curves',
  ),
  (
    path: '/history',
    icon: Icons.history_outlined,
    selected: Icons.history,
    label: 'History',
  ),
  (
    path: '/parts',
    icon: Icons.inventory_2_outlined,
    selected: Icons.inventory_2,
    label: 'Parts',
  ),
  (
    path: '/settings',
    icon: Icons.settings_outlined,
    selected: Icons.settings,
    label: 'Settings',
  ),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/bins')) return 3;
    final i = _destinations.indexWhere((d) => loc.startsWith(d.path));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    final index = _index(context);
    final drafts = ref.watch(draftsProvider).length;
    void go(int i) => context.go(_destinations[i].path);

    Widget badge(Widget icon, int i) => i == 0 && drafts > 0
        ? Badge(label: Text('$drafts'), child: icon)
        : icon;

    final body = Column(
      children: [
        const _Header(),
        const _Banners(),
        Expanded(child: child),
        const _Footer(),
      ],
    );

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: go,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final (i, d) in _destinations.indexed)
                  NavigationRailDestination(
                    icon: badge(Icon(d.icon), i),
                    selectedIcon: badge(Icon(d.selected), i),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: go,
        destinations: [
          for (final (i, d) in _destinations.indexed)
            NavigationDestination(
              icon: badge(Icon(d.icon), i),
              selectedIcon: badge(Icon(d.selected), i),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusProvider);
    final c = ref.read(controllerProvider);
    final theme = Theme.of(context);
    final connected = status.isConnected;
    final busy = status.state == ConnectionState.connecting;

    final id = status.identity;
    final info = switch (status.state) {
      ConnectionState.disconnected => 'no device',
      ConnectionState.connecting => 'connecting…',
      _ =>
        '${id?.productName ?? 'DCA Pro'} · s/n ${id?.serial ?? '?'} · fw ${id?.firmwareRev ?? '?'}',
    };

    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'SIGHTINGS',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                    ),
                  ),
                  TextSpan(
                    text: '  DCA75 Workbench',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                info,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            _StatusDot(state: status.state),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: busy
                  ? null
                  : () async {
                      if (connected) {
                        await c.disconnect();
                      } else {
                        try {
                          await c.connect();
                        } catch (_) {
                          /* shown in status */
                        }
                      }
                    },
              child: Text(connected ? 'Disconnect' : 'Connect'),
            ),
            IconButton(
              tooltip: 'Log',
              icon: const Icon(Icons.terminal_outlined),
              onPressed: () => context.go('/log'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.state});
  final ConnectionState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      ConnectionState.disconnected => Colors.red.shade700,
      ConnectionState.connecting => Colors.orange,
      ConnectionState.idle => Colors.green.shade700,
      _ => Colors.blue,
    };
    return Semantics(
      label: 'device ${state.name}',
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _Banners extends ConsumerWidget {
  const _Banners();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusProvider);
    final banner = ref.watch(bannerProvider);
    final theme = Theme.of(context);
    final items = <Widget>[];

    Widget bar(String text, {bool error = false, VoidCallback? onClose}) =>
        Material(
          color: error
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.tertiaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Icon(
                  error ? Icons.error_outline : Icons.info_outline,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
        );

    final demo = ref.watch(demoUnitProvider);
    if (demo != null) {
      items.add(
        Material(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.science_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo device — readings are simulated. Clipped in: ${demo.part.name}',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                TextButton(
                  onPressed: status.state == ConnectionState.idle
                      ? demo.pressButton
                      : null,
                  child: const Text('Press unit button'),
                ),
                TextButton(
                  onPressed: () {
                    demo.nextPart();
                    ref.read(bannerProvider.notifier).state = null;
                    // Re-read so the banner text updates.
                    ref.invalidate(demoUnitProvider);
                  },
                  child: const Text('Next part'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (status.lastError != null && !status.isConnected) {
      var text = status.lastError!;
      if (Platform.isLinux && text.toLowerCase().contains('access')) {
        text =
            '$text — install the udev rule: sudo cp packaging/linux/60-dca75.rules /etc/udev/rules.d/ && sudo udevadm control --reload && sudo udevadm trigger';
      }
      if (Platform.isAndroid && text.toLowerCase().contains('permission')) {
        text =
            '$text — unplug and replug the DCA75 and accept the USB permission dialog.';
      }
      items.add(bar(text, error: true));
    } else if (status.lastError != null) {
      items.add(bar(status.lastError!, error: true));
    }
    if (banner != null) {
      items.add(
        bar(
          banner,
          error: true,
          onClose: () => ref.read(bannerProvider.notifier).state = null,
        ),
      );
    }
    final rails = status.rails;
    if (rails != null && rails.batt < 1.1 && rails.batt > 0.2) {
      items.add(
        bar(
          'Battery low (${rails.batt.toStringAsFixed(2)} V). The unit runs from USB while connected.',
        ),
      );
    }
    return Column(children: items);
  }
}

class _Footer extends ConsumerWidget {
  const _Footer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(statusProvider);
    final theme = Theme.of(context);
    final r = status.rails;
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final bold = style?.copyWith(
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w600,
    );
    Widget kv(String k, String v) => Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$k ', style: style),
            TextSpan(text: v, style: bold),
          ],
        ),
      ),
    );
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              kv(
                'State',
                status.isConnected ? status.state.name : 'disconnected',
              ),
              kv('Battery', r == null ? '—' : '${r.batt.toStringAsFixed(2)} V'),
              kv(
                '12 V rail',
                r == null ? '—' : '${r.v12.toStringAsFixed(2)} V',
              ),
              kv('Vref', r == null ? '—' : '${r.vRef.toStringAsFixed(3)} V'),
              kv('R(MT2)', r == null ? '—' : '${r.rMt2.toStringAsFixed(1)} Ω'),
              if (status.device?.accessError != null)
                kv('Access', status.device!.accessError!),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small helper used by several screens.
String describeTransportError(Object e) =>
    e is TransportException ? e.message : e.toString();
