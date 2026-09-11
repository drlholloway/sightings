import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'app/tour.dart';
import 'services/providers.dart';
import 'services/settings.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (tourEnabled) {
    // Screenshot tour: in-memory settings and a scratch database, so the
    // user's real preferences and readings are untouched.
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    runApp(
      ProviderScope(
        overrides: [
          databasePathProvider.overrideWith(
            (ref) async => '$tourDir/tour.sqlite',
          ),
        ],
        child: RepaintBoundary(
          key: tourBoundaryKey,
          child: const WorkbenchApp(),
        ),
      ),
    );
    return;
  }
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
    if (tourEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => Tour(ref).run());
    }
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
    // Keep the long-lived services alive; watching them means they follow
    // the transport when demo mode is toggled.
    ref.watch(intakeProvider);
    ref.watch(sessionProvider);
    ref.watch(autoConnectorProvider);
    return MaterialApp.router(
      title: 'Sightings',
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
