import 'dart:io';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  late ReadingsRepository repo;
  late int session;

  const identity = DeviceIdentity(
      serial: 'ABC123',
      hardwareRev: '00a5',
      firmwareRev: '0112',
      productName: 'DCA Pro');

  setUp(() async {
    db = memDb();
    repo = ReadingsRepository(db);
    session = await repo.startSession(
        identity: identity,
        calibration: const Calibration(
            r1k0: 1000, r8k2: 8200, r68k: 68000, r470k: 470000, rMt2: 618.5),
        rMt2: 618.5,
        platform: 'test',
        appVersion: '0.0.1');
  });
  tearDown(() => db.close());

  test('schema creates tables, indexes, view and meta', () async {
    final names = (await db
            .customSelect(
                "SELECT name FROM sqlite_master WHERE type IN ('table','view','index') ORDER BY name")
            .get())
        .map((r) => r.read<String>('name'))
        .toSet();
    expect(
        names,
        containsAll([
          'devices',
          'sessions',
          'readings',
          'reading_params',
          'parts',
          'bins',
          'reading_tags',
          'sweeps',
          'sweep_traces',
          'schema_meta',
          'reading_headlines',
          'ix_readings_taken',
          'ix_params_key_val',
        ]));
    expect(await db.meta('db_uuid'), matches(RegExp(r'^[0-9a-f-]{36}$')));
    final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
    expect(fk.read<int>('foreign_keys'), 1);
  });

  test('session records the device; repeated sessions keep first_seen',
      () async {
    final dev = await (db.select(db.devices)).getSingle();
    expect(dev.serial, 'ABC123');
    expect(dev.calR8k2, 8200);
    expect(dev.firstSeenMs, dev.lastSeenMs);
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final s2 = await repo.startSession(
        identity: identity, platform: 'test', appVersion: '0.0.1');
    expect(s2, session + 1);
    final dev2 = await (db.select(db.devices)).getSingle();
    expect(dev2.firstSeenMs, dev.firstSeenMs);
    expect(dev2.lastSeenMs, greaterThan(dev.lastSeenMs));
    await repo.endSession(s2);
    final row = await (db.select(db.sessions)..where((s) => s.id.equals(s2)))
        .getSingle();
    expect(row.endedAtMs, isNotNull);
  });

  test('saveReading stores raw frame, params and headline; loadReading decodes',
      () async {
    final id = await repo.saveReading(session, bjt(cfg: 3, hfe: 212.4),
        source: ReadingSource.app,
        rails: Rails(
            batt: 1.5, v12: 12.1, vRef: 2.5, rMt2: 618.5, at: DateTime.now()));
    final d = (await repo.loadReading(id))!;
    expect(d.result.name, 'NPN BJT');
    expect(d.result.raw, bjtFrame(cfg: 3, hfe: 212.4));
    expect(d.row.headline['hfe'], closeTo(212.4, 1e-3));
    expect(d.row.headline['vbe_5ma'], closeTo(0.71, 1e-6));
    expect(d.row.source, ReadingSource.app);
    expect(d.v12V, closeTo(12.1, 1e-6));
    expect(d.deviceSerial, 'ABC123');
    expect(d.tag.partId, isNull);
    final params = await (db.select(db.readingParams)
          ..where((p) => p.readingId.equals(id)))
        .get();
    expect(params.map((p) => p.key),
        containsAll(['hfe', 'vbe_5ma', 'ic_vbe_hi', 'ic_leak', 'vce_sat']));
    expect(params.firstWhere((p) => p.key == 'ic_vbe_hi').unit, 'A');
    expect(await repo.countReadings(), 1);
    expect(await repo.loadReading(999), isNull);
  });

  test('tagging with parts and bins, then filtering', () async {
    final a = await repo.saveReading(session, bjt(hfe: 150),
        source: ReadingSource.app);
    final b = await repo.saveReading(session, bjt(hfe: 250),
        source: ReadingSource.unitButton);
    final c =
        await repo.saveReading(session, diode(), source: ReadingSource.app);
    final part =
        await repo.upsertPart(partNumber: '2N3904', manufacturer: 'ON');
    expect(
        await repo.upsertPart(partNumber: '2N3904', manufacturer: 'ON'), part,
        reason: 'idempotent');
    final other = await repo.upsertPart(partNumber: '2N3904');
    expect(other, isNot(part), reason: 'manufacturer is part of the key');
    final bin = await repo.createBin(part, 'lot A');
    expect(await repo.createBin(part, 'lot A'), bin);
    await repo.tagReading(a, partId: part, binId: bin, label: 'first');
    await repo.tagReading(b, partId: part, starred: true);
    await repo.tagReading(b, notes: 'keeps part'); // partial update keeps part
    final all = await repo.listReadings(const ReadingFilter());
    expect(all.map((r) => r.id), [c, b, a], reason: 'newest first');
    expect(all.first.name, 'PN junction');
    final inBin = await repo.listReadings(ReadingFilter(binId: bin));
    expect(inBin.map((r) => r.id), [a]);
    expect(inBin.single.partNumber, '2N3904');
    expect(inBin.single.binName, 'lot A');
    final starred =
        await repo.listReadings(const ReadingFilter(starredOnly: true));
    expect(starred.map((r) => r.id), [b]);
    expect(starred.single.partId, part);
    final untagged =
        await repo.listReadings(const ReadingFilter(untaggedOnly: true));
    expect(untagged.map((r) => r.id), [c]);
    final bjts = await repo
        .listReadings(const ReadingFilter(types: {ComponentType.bjt}));
    expect(bjts.length, 2);
    final text = await repo.listReadings(const ReadingFilter(text: 'lot'));
    expect(text.map((r) => r.id), [a]);
    final parts = await repo.listParts();
    expect(parts.length, 2);
    expect(parts.firstWhere((p) => p.id == part).readingCount, 2);
    expect(parts.firstWhere((p) => p.id == part).binCount, 1);
    final bins = await repo.listBins(partId: part);
    expect(bins.single.readingCount, 1);
    await repo.tagReading(a, clearBin: true);
    expect((await repo.listReadings(ReadingFilter(binId: bin))), isEmpty);
    expect((await repo.loadReading(a))!.tag.label, 'first');
  });

  test('watchReadings emits on changes', () async {
    final seen = <int>[];
    final sub = repo
        .watchReadings(const ReadingFilter())
        .listen((rows) => seen.add(rows.length));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await repo.saveReading(session, bjt(), source: ReadingSource.app);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(seen.first, 0);
    expect(seen.last, 1);
  });

  test('bin statistics and percentile', () async {
    final part = await repo.upsertPart(partNumber: '2N3904');
    final bin = await repo.createBin(part, 'lot A');
    final ids = <int>[];
    for (final h in [
      100.0,
      120.0,
      140.0,
      160.0,
      180.0,
      200.0,
      220.0,
      240.0,
      260.0,
      280.0
    ]) {
      final id = await repo.saveReading(session, bjt(hfe: h),
          source: ReadingSource.app);
      await repo.tagReading(id, partId: part, binId: bin);
      ids.add(id);
    }
    // one untagged reading must not count
    await repo.saveReading(session, bjt(hfe: 9999), source: ReadingSource.app);
    final s = await repo.binStats('hfe', binId: bin);
    expect(s.n, 10);
    expect(s.min, 100);
    expect(s.max, 280);
    expect(s.mean, closeTo(190, 1e-6));
    expect(s.median, closeTo(190, 1e-6));
    expect(s.p25, closeTo(145, 1e-6));
    expect(s.p75, closeTo(235, 1e-6));
    expect(s.stddev, closeTo(60.55, 0.01));
    expect(s.histogram.fold(0, (n, b) => n + b.count), 10);
    expect(await repo.percentileOf('hfe', 200, binId: bin), closeTo(55, 1e-6));
    expect(await repo.percentileOf('hfe', 50, binId: bin), 0);
    expect(await repo.percentileOf('hfe', 1000, binId: bin), 100);
    final near = await repo.nearestReadings('hfe', ids[5], 2, binId: bin);
    expect(near.map((e) => e.$1), [ids[4], ids[6]]);
    final byPart = await repo.binStats('hfe', partId: part);
    expect(byPart.n, 10);
    expect((await repo.binStats('vgs_th', binId: bin)).n, 0);
  });

  test('sweeps round-trip with packed points', () async {
    final rid =
        await repo.saveReading(session, bjt(), source: ReadingSource.app);
    final t0 = SweepTrace(0, 'Ib=10.0 µA')
      ..points.addAll([(x: 0.0, y: 0.0), (x: 1.5, y: 2.25)]);
    final t1 = SweepTrace(1, 'Ib=20.0 µA')..points.add((x: 3.0, y: 9.0));
    const params = IcVceParams(traces: 2, points: 2, vcMax: 3);
    final sid = await repo.saveSweep(session,
        readingId: rid,
        params: params,
        traces: [t0, t1],
        startedAt: DateTime(2026, 9, 5, 12),
        duration: const Duration(seconds: 4));
    final list = await repo.listSweeps(readingId: rid);
    expect(list.single.id, sid);
    expect(list.single.kind, SweepKind.icvce);
    expect(list.single.traceCount, 2);
    expect(list.single.pointCount, 3);
    final d = (await repo.loadSweep(sid))!;
    expect(d.params.toJson(), params.toJson());
    expect(d.traces.length, 2);
    expect(d.traces[0].points, [(x: 0.0, y: 0.0), (x: 1.5, y: 2.25)]);
    expect(d.traces[1].label, 'Ib=20.0 µA');
    expect(sweepCsv(d.traces),
        'trace,x,y\nIb=10.0 µA,0.0,0.0\nIb=10.0 µA,1.5,2.25\nIb=20.0 µA,3.0,9.0\n');
    expect((await repo.loadReading(rid))!.sweeps.length, 1);
    await repo.deleteReadings([rid]);
    expect((await repo.listSweeps(sessionId: session)).single.readingId, isNull,
        reason: 'SET NULL');
    await repo.deleteSweep(sid);
    expect(await (db.select(db.sweepTraces)).get(), isEmpty, reason: 'CASCADE');
  });

  test('deleting a reading cascades params and tags', () async {
    final id =
        await repo.saveReading(session, bjt(), source: ReadingSource.app);
    await repo.tagReading(id, label: 'x');
    await repo.deleteReadings([id]);
    expect(await (db.select(db.readingParams)).get(), isEmpty);
    expect(await (db.select(db.readingTags)).get(), isEmpty);
  });

  test('extra params survive re-decode and appear in detail and headlines',
      () async {
    final id = await repo.saveReading(session, bjt(hfe: 150),
        source: ReadingSource.app);
    await repo.saveExtraParams(
        id, {'hfe_dca55': (140.5, ''), 'vbe_dca55': (0.68, 'V')});
    var d = (await repo.loadReading(id))!;
    expect(d.extras['hfe_dca55']!.$1, closeTo(140.5, 1e-6));
    expect(d.extras['vbe_dca55']!.$2, 'V');
    expect(d.row.headline['hfe_dca55'], closeTo(140.5, 1e-6));
    await db.customStatement('UPDATE readings SET decoder_version = 0');
    expect(await repo.reDecodeAll(), 1);
    d = (await repo.loadReading(id))!;
    expect(d.extras['hfe_dca55']!.$1, closeTo(140.5, 1e-6),
        reason: 'kept by re-decode');
    expect(d.row.headline['hfe'], closeTo(150, 1e-3),
        reason: 'decoder params rewritten');
    final part = await repo.upsertPart(partNumber: 'X');
    final bin = await repo.createBin(part, 'b');
    await repo.tagReading(id, partId: part, binId: bin);
    expect((await repo.binStats('hfe_dca55', binId: bin)).n, 1);
  });

  test('reDecodeAll refreshes params for old decoder versions', () async {
    final id = await repo.saveReading(session, bjt(hfe: 123),
        source: ReadingSource.app);
    await repo.tagReading(id, label: 'keep me');
    await db.customStatement('UPDATE readings SET decoder_version = 0');
    await db.customStatement("DELETE FROM reading_params WHERE key = 'hfe'");
    expect(await repo.reDecodeAll(), 1);
    final d = (await repo.loadReading(id))!;
    expect(d.row.headline['hfe'], closeTo(123, 1e-3));
    expect(d.tag.label, 'keep me');
    expect(await repo.reDecodeAll(), 0);
  });

  test('readings CSV', () async {
    final id = await repo.saveReading(session, bjt(hfe: 150),
        source: ReadingSource.app);
    await repo.tagReading(id, label: 'a "quoted", label');
    final csv = readingsCsv(await repo.listReadings(const ReadingFilter()));
    final lines = csv.trim().split('\n');
    expect(
        lines.first.startsWith(
            'id,taken_at,source,type,name,config,flags,part_number,bin,label,starred,hfe'),
        isTrue);
    expect(lines[1], contains('"a ""quoted"", label"'));
    expect(lines[1], contains(',150.0,'));
  });

  test('backup via VACUUM INTO produces an openable copy', () async {
    await repo.saveReading(session, bjt(hfe: 77), source: ReadingSource.app);
    final dir = await Directory.systemTemp.createTemp('dca75_store_test');
    final path = '${dir.path}/backup.sqlite';
    await db.backupTo(path);
    final copy = AppDatabase(NativeDatabase(File(path)));
    final repo2 = ReadingsRepository(copy);
    expect(await repo2.countReadings(), 1);
    expect(
        (await repo2.listReadings(const ReadingFilter()))
            .single
            .headline['hfe'],
        closeTo(77, 1e-3));
    expect(await copy.meta('db_uuid'), await db.meta('db_uuid'));
    await copy.close();
    await dir.delete(recursive: true);
  });

  test('packPoints/unpackPoints', () {
    final pts = [(x: 1.0, y: -2.5), (x: 1e-9, y: 12.0)];
    final b = packPoints(pts);
    expect(b.length, 32);
    expect(unpackPoints(b), pts);
    expect(unpackPoints(packPoints([])), isEmpty);
  });
}
