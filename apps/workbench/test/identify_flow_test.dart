import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbench/main.dart';
import 'package:workbench/services/providers.dart';

Uint8List bjtFrame({int cfg = 3, double hfe = 212.4}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 1;
  b[3] = cfg;
  b[4] = bjtFlagNpn | bjtFlagSilicon;
  final f = [0.001, 0.71, 0.65, 0.024, 0.005, hfe, 5.0, 0.09, 10, 1, 0, 0];
  for (var i = 0; i < f.length; i++) {
    d.setFloat32(5 + 4 * i, f[i].toDouble(), Endian.little);
  }
  return b;
}

/// Pump in 50 ms steps until [finder] matches (or 5 s pass).
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration step = const Duration(milliseconds: 50),
}) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
  final texts = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? t.textSpan?.toPlainText() ?? '')
      .where((s) => s.isNotEmpty)
      .toList();
  expect(
    finder,
    findsWidgets,
    reason: 'timed out waiting for $finder; texts on screen: $texts',
  );
}

void main() {
  // The fake device and database must be created inside the test body so
  // their futures and timers belong to the test's fake-async zone.
  late ScriptedDca dca;
  late AppDatabase db;

  Widget app() => ProviderScope(
    overrides: [
      transportProvider.overrideWithValue(dca.transport),
      databaseProvider.overrideWith((ref) async => db),
      databasePathProvider.overrideWith((ref) async => ':memory:'),
      appInfoProvider.overrideWith(
        (ref) async => PackageInfo(
          appName: 'workbench',
          packageName: 'test',
          version: '0.0.0',
          buildNumber: '1',
        ),
      ),
    ],
    child: const WorkbenchApp(),
  );

  testWidgets(
    'auto-connects, tests from the app, drafts from the unit button',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      dca = ScriptedDca(result: bjtFrame());
      db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(app());
      // auto-connect fires after 300 ms
      await pumpUntil(tester, find.textContaining('s/n ABC123'));
      expect(find.text('Connect'), findsNothing);
      expect(find.text('Disconnect'), findsOneWidget);

      // App-initiated test: saved immediately.
      await tester.tap(find.widgetWithText(FilledButton, 'Test'));
      await pumpUntil(tester, find.textContaining('saved #1'));
      expect(find.text('NPN BJT'), findsOneWidget);
      final repo = ReadingsRepository(db);
      expect(await repo.countReadings(), 1);

      // Unit-button test: arrives as a draft on the next idle poll.
      dca.unitButtonPress = true;
      await pumpUntil(tester, find.textContaining('DRAFT'));
      expect(await repo.countReadings(), 1, reason: 'draft is not saved yet');

      // Save it.
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await pumpUntil(tester, find.textContaining('saved #2'));
      expect(await repo.countReadings(), 2);
      expect(find.textContaining('DRAFT'), findsNothing);

      // Another unit-button test, discarded.
      dca.unitButtonPress = true;
      await pumpUntil(tester, find.textContaining('DRAFT'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Discard'));
      await tester.pump();
      expect(find.textContaining('DRAFT'), findsNothing);
      expect(await repo.countReadings(), 2);

      // Tagging: keyboard input must reach the text fields despite the
      // screen shortcuts (Enter = Save, Space = Test, Backspace = Discard).
      final part = find.widgetWithText(TextField, 'Part number');
      await pumpUntil(tester, part); // the strip loads the saved tag first
      await tester.enterText(part, '2N5088');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pumpUntil(tester, find.text('— none —')); // bin picker enabled
      final parts = await repo.listParts();
      expect(parts.single.partNumber, '2N5088');
      final label = find.widgetWithText(TextField, 'Label');
      await pumpUntil(tester, label);
      await tester.enterText(label, 'lot ab'); // backspace below trims the b
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.widget<TextField>(label).controller!.text, 'lot a');
      expect(
        await repo.countReadings(),
        2,
        reason: 'Backspace must not discard, Space must not test',
      );
      final detail = await repo.loadReading(2);
      expect(detail!.tag.partId, parts.single.id);
      expect(detail.tag.label, 'lot a');

      // Stop timers cleanly.
      await tester.tap(find.text('Disconnect'));
      await pumpUntil(tester, find.text('Connect'));
    },
  );
}
