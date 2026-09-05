import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'services/providers.dart';
import 'services/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: WorkbenchApp()));
}

class WorkbenchApp extends ConsumerStatefulWidget {
  const WorkbenchApp({super.key});

  @override
  ConsumerState<WorkbenchApp> createState() => _WorkbenchAppState();
}

class _WorkbenchAppState extends ConsumerState<WorkbenchApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Eagerly create the long-lived services.
    ref.read(intakeProvider);
    ref.read(sessionProvider);
    ref.read(autoConnectorProvider);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Leaving the app with the unit driving current is unsafe: shut down.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final c = ref.read(controllerProvider);
      if (c.status.isConnected) c.disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'DCA75 Workbench',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: switch (settings.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      routerConfig: router,
    );
  }
}
