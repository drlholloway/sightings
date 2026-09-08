import 'package:dca75_store/dca75_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbench/main.dart';
import 'package:workbench/services/providers.dart';

Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 200; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets, reason: 'timed out waiting for $finder');
}

void main() {
  testWidgets(
    'demo mode connects to the simulated unit and identifies a part',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'demoMode': true,
        'dca55Auto': false,
        'leakAuto': false,
      });
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWith((ref) async => db),
            databasePathProvider.overrideWith((ref) async => ':memory:'),
            appInfoProvider.overrideWith(
              (ref) async => PackageInfo(
                appName: 'w',
                packageName: 't',
                version: '0',
                buildNumber: '1',
              ),
            ),
          ],
          child: const WorkbenchApp(),
        ),
      );
      await pumpUntil(tester, find.textContaining('s/n DEMO01'));
      expect(find.textContaining('Demo device'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Test'));
      await pumpUntil(tester, find.textContaining('saved #1'));
      expect(find.text('NPN BJT'), findsOneWidget);
      final repo = ReadingsRepository(db);
      expect(await repo.countReadings(), 1);
      // demo sessions are tagged so they can be deleted in one go
      final sessions = await (db.select(db.sessions)).get();
      expect(sessions.single.platform, 'demo');
      // unit button -> draft
      await tester.tap(find.text('Press unit button'));
      await pumpUntil(tester, find.textContaining('DRAFT'));
      await tester.tap(find.text('Disconnect'));
      await pumpUntil(tester, find.text('Connect'));
    },
  );
}
