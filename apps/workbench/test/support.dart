// Shared by the screen tests: frames for seeding, an app wired to an
// in-memory database, and a pump that waits for a finder.
import 'dart:typed_data';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbench/app/router.dart';
import 'package:workbench/main.dart';
import 'package:workbench/services/providers.dart';

/// A TEST(2) frame for an NPN silicon BJT.
Uint8List bjtFrame({int cfg = 3, double hfe = 212.4, double vbe = 0.71}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 1;
  b[3] = cfg;
  b[4] = bjtFlagNpn | bjtFlagSilicon;
  final f = [0.001, vbe, 0.65, 0.024, 0.005, hfe, 5.0, 0.09, 10, 1, 0, 0];
  for (var i = 0; i < f.length; i++) {
    d.setFloat32(5 + 4 * i, f[i].toDouble(), Endian.little);
  }
  return b;
}

/// A TEST(2) frame for a single PN diode.
Uint8List diodeFrame({double vf = 0.62}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 6;
  b[3] = 1;
  b[5] = 1;
  b[6] = 4;
  d.setFloat32(7, vf, Endian.little);
  d.setFloat32(11, 5, Endian.little);
  return b;
}

IdentifyResult bjt({double hfe = 212.4, double vbe = 0.71}) =>
    decodeResult(Response(bjtFrame(hfe: hfe, vbe: vbe)));

IdentifyResult diode({double vf = 0.62}) =>
    decodeResult(Response(diodeFrame(vf: vf)));

/// Pumps in 50 ms steps until [finder] matches, or fails after 10 s.
Future<void> pumpUntil(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 200; i++) {
    await tester.pump(const Duration(milliseconds: 50));
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

/// Pumps a few frames so loads from the in-memory database land.
Future<void> settle(WidgetTester tester, [int frames = 6]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Goes to [location] and waits for the screen to load.
Future<void> goTo(WidgetTester tester, String location) async {
  router.go(location);
  await settle(tester);
}

/// What [seed] put in the database.
class Seeded {
  Seeded({
    required this.session,
    required this.partId,
    required this.binId,
    required this.bjtIds,
    required this.diodeId,
    required this.sweepId,
  });
  final int session, partId, binId, diodeId, sweepId;

  /// Seven 2N5088s in bin "Lot A"; the last has a far higher hFE than the
  /// rest, the third is starred and labeled "FF Q2".
  final List<int> bjtIds;
}

/// Seven tagged BJTs (one an outlier), an untagged diode from the unit's
/// button, and a saved Ic/Vce sweep linked to the first BJT.
Future<Seeded> seed(AppDatabase db) async {
  final repo = ReadingsRepository(db);
  final session = await repo.startSession(platform: 'test', appVersion: '0');
  final partId = await repo.upsertPart(
    partNumber: '2N5088',
    manufacturer: 'Fairchild',
    description: 'low-noise NPN',
  );
  final binId = await repo.createBin(partId, 'Lot A');
  final ids = <int>[];
  final gains = [200.0, 205.0, 210.0, 215.0, 220.0, 225.0, 900.0];
  for (final (i, hfe) in gains.indexed) {
    final id = await repo.saveReading(
      session,
      bjt(hfe: hfe, vbe: 0.70 + i * 0.002),
      source: ReadingSource.app,
      rails: null,
      takenAt: DateTime(2026, 11, 1, 12, i),
    );
    await repo.tagReading(
      id,
      partId: partId,
      binId: binId,
      label: i == 2 ? 'FF Q2' : null,
      starred: i == 2,
    );
    ids.add(id);
  }
  final diodeId = await repo.saveReading(
    session,
    diode(),
    source: ReadingSource.unitButton,
    takenAt: DateTime(2026, 11, 1, 13),
  );
  final trace = SweepTrace(0, 'Ib 10 µA')
    ..points.addAll([(x: 0.0, y: 0.0), (x: 1.0, y: 2.0), (x: 2.0, y: 2.1)]);
  final sweepId = await repo.saveSweep(
    session,
    readingId: ids.first,
    params: const IcVceParams(),
    traces: [trace],
    startedAt: DateTime(2026, 11, 1, 12, 30),
    duration: const Duration(seconds: 2),
  );
  return Seeded(
    session: session,
    partId: partId,
    binId: binId,
    bjtIds: ids,
    diodeId: diodeId,
    sweepId: sweepId,
  );
}

/// The app on a 1400 × 900 window (or [size]) with an in-memory database.
///
/// Without [demo] the app has a scripted unit it never connects to, so no
/// timers run. With [demo] it connects to the simulated unit; the test must
/// tap Disconnect before it ends. [prefs] adds to the stored settings.
Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  AppDatabase? database,
  bool demo = false,
  Size size = const Size(1400, 900),
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues({
    'demoMode': demo,
    'autoConnect': demo,
    'dca55Auto': false,
    'leakAuto': false,
    ...prefs,
  });
  final db = database ?? AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  router.go('/identify');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (!demo)
          transportProvider.overrideWithValue(
            ScriptedDca(result: bjtFrame()).transport,
          ),
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
    ),
  );
  await settle(tester);
  return db;
}

/// The app's provider container, for reading state the screen does not show.
ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(WorkbenchApp)));
