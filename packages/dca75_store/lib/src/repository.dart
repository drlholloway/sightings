import 'dart:convert';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:drift/drift.dart';

import 'database.dart';
import 'models.dart';
import 'stats.dart';

/// All reads and writes the app performs. Wraps [AppDatabase].
class ReadingsRepository {
  ReadingsRepository(this.db);

  final AppDatabase db;

  static int _ms(DateTime t) => t.toUtc().millisecondsSinceEpoch;
  static DateTime _dt(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();

  // --------------------------------------------------------------- sessions

  Future<int> startSession({
    DeviceIdentity? identity,
    Calibration? calibration,
    double? rMt2,
    required String platform,
    required String appVersion,
    DateTime? at,
  }) async {
    final now = _ms(at ?? DateTime.now());
    if (identity != null) {
      final fields = DevicesCompanion(
        productName: Value(identity.productName),
        hardwareRev: Value(identity.hardwareRev),
        firmwareRev: Value(identity.firmwareRev),
        rMt2: Value(rMt2),
        calR1k0: Value(calibration?.r1k0),
        calR8k2: Value(calibration?.r8k2),
        calR68k: Value(calibration?.r68k),
        calR470k: Value(calibration?.r470k),
        lastSeenMs: Value(now),
      );
      final existing = await (db.select(db.devices)
            ..where((d) => d.serial.equals(identity.serial)))
          .getSingleOrNull();
      if (existing == null) {
        await db.into(db.devices).insert(fields.copyWith(
            serial: Value(identity.serial), firstSeenMs: Value(now)));
      } else {
        await (db.update(db.devices)
              ..where((d) => d.serial.equals(identity.serial)))
            .write(fields);
      }
    }
    return db.into(db.sessions).insert(SessionsCompanion.insert(
          deviceSerial: Value(identity?.serial),
          startedAtMs: now,
          platform: platform,
          appVersion: appVersion,
        ));
  }

  Future<void> endSession(int sessionId, {DateTime? at}) =>
      (db.update(db.sessions)..where((s) => s.id.equals(sessionId))).write(
          SessionsCompanion(endedAtMs: Value(_ms(at ?? DateTime.now()))));

  // --------------------------------------------------------------- readings

  Future<int> saveReading(
    int sessionId,
    IdentifyResult r, {
    required ReadingSource source,
    Rails? rails,
    DateTime? takenAt,
  }) =>
      db.transaction(() async {
        final id = await db.into(db.readings).insert(ReadingsCompanion.insert(
              sessionId: sessionId,
              takenAtMs: _ms(takenAt ?? DateTime.now()),
              source: sourceToDb(source),
              type: r.typeCode,
              config: r.config,
              flags: r.flags,
              rawFrame: r.raw,
              decoderVersion: decoderVersion,
              battV: Value(rails?.batt),
              v12V: Value(rails?.v12),
              vrefV: Value(rails?.vRef),
            ));
        await _writeParams(id, r);
        return id;
      });

  Future<void> _writeParams(int id, IdentifyResult r) async {
    final rows = <String, ReadingParamsCompanion>{};
    for (final p in r.params) {
      rows[p.key] = ReadingParamsCompanion.insert(
          readingId: id, key: p.key, value: p.value, unit: p.unit);
    }
    for (final e in r.headline.entries) {
      rows.putIfAbsent(
          e.key,
          () => ReadingParamsCompanion.insert(
              readingId: id, key: e.key, value: e.value, unit: ''));
    }
    await db.batch((b) => b.insertAll(db.readingParams, rows.values.toList(),
        mode: InsertMode.insertOrReplace));
  }

  /// Re-run the decoder on stored raw frames written by an older decoder.
  Future<int> reDecodeAll({int? olderThan}) async {
    final rows = await (db.select(db.readings)
          ..where((r) =>
              r.decoderVersion.isSmallerThanValue(olderThan ?? decoderVersion)))
        .get();
    for (final row in rows) {
      final r = decodeResult(Response(row.rawFrame));
      await db.transaction(() async {
        await (db.delete(db.readingParams)
              ..where((p) => p.readingId.equals(row.id)))
            .go();
        await _writeParams(row.id, r);
        await (db.update(db.readings)..where((x) => x.id.equals(row.id))).write(
            ReadingsCompanion(
                decoderVersion: const Value(decoderVersion),
                type: Value(r.typeCode),
                config: Value(r.config),
                flags: Value(r.flags)));
      });
    }
    return rows.length;
  }

  Future<void> deleteReadings(Iterable<int> ids) =>
      (db.delete(db.readings)..where((r) => r.id.isIn(ids))).go();

  // ------------------------------------------------------------------- tags

  Future<void> tagReading(
    int readingId, {
    int? partId,
    int? binId,
    String? label,
    String? notes,
    bool? starred,
    bool clearPart = false,
    bool clearBin = false,
  }) async {
    final existing = await (db.select(db.readingTags)
          ..where((t) => t.readingId.equals(readingId)))
        .getSingleOrNull();
    final now = _ms(DateTime.now());
    final c = ReadingTagsCompanion(
      readingId: Value(readingId),
      partId: clearPart
          ? const Value(null)
          : (partId != null ? Value(partId) : Value(existing?.partId)),
      binId: clearBin
          ? const Value(null)
          : (binId != null ? Value(binId) : Value(existing?.binId)),
      label: label != null ? Value(label) : Value(existing?.label),
      notes: notes != null ? Value(notes) : Value(existing?.notes),
      starred: Value(starred ?? existing?.starred ?? false),
      updatedAtMs: Value(now),
    );
    await db.into(db.readingTags).insertOnConflictUpdate(c);
  }

  Future<void> tagMany(Iterable<int> readingIds,
      {int? partId, int? binId, String? label}) async {
    for (final id in readingIds) {
      await tagReading(id, partId: partId, binId: binId, label: label);
    }
  }

  // ------------------------------------------------------------------ query

  Future<List<ReadingRow>> listReadings(ReadingFilter f) async {
    final where = <String>[];
    final args = <Object>[];
    if (f.types.isNotEmpty) {
      where.add('r.type IN (${f.types.map((_) => '?').join(',')})');
      args.addAll(f.types.map((t) => t.code));
    }
    if (f.partId != null) {
      where.add('t.part_id = ?');
      args.add(f.partId!);
    }
    if (f.binId != null) {
      where.add('t.bin_id = ?');
      args.add(f.binId!);
    }
    if (f.sessionId != null) {
      where.add('r.session_id = ?');
      args.add(f.sessionId!);
    }
    if (f.from != null) {
      where.add('r.taken_at_ms >= ?');
      args.add(_ms(f.from!));
    }
    if (f.to != null) {
      where.add('r.taken_at_ms < ?');
      args.add(_ms(f.to!));
    }
    if (f.untaggedOnly) {
      where.add(
          "(t.reading_id IS NULL OR (t.part_id IS NULL AND t.bin_id IS NULL AND IFNULL(t.label,'') = ''))");
    }
    if (f.starredOnly) where.add('t.starred = 1');
    if (f.text != null && f.text!.trim().isNotEmpty) {
      where.add(
          '(t.label LIKE ? OR t.notes LIKE ? OR p.part_number LIKE ? OR b.name LIKE ?)');
      final like = '%${f.text!.trim()}%';
      args.addAll([like, like, like, like]);
    }
    final sql = '''
SELECT r.id, r.session_id, r.taken_at_ms, r.source, r.type, r.config, r.flags, r.raw_frame,
       t.part_id, p.part_number, t.bin_id, b.name AS bin_name, t.label, IFNULL(t.starred, 0) AS starred
FROM readings r
LEFT JOIN reading_tags t ON t.reading_id = r.id
LEFT JOIN parts p ON p.id = t.part_id
LEFT JOIN bins b ON b.id = t.bin_id
${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
ORDER BY r.taken_at_ms ${f.newestFirst ? 'DESC' : 'ASC'}, r.id ${f.newestFirst ? 'DESC' : 'ASC'}
LIMIT ? OFFSET ?''';
    args.addAll([f.limit, f.offset]);
    final rows = await db.customSelect(sql,
        variables: args.map(Variable.new).toList(),
        readsFrom: {db.readings, db.readingTags, db.parts, db.bins}).get();
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.read<int>('id')).toList();
    final heads = await _headlines(ids);
    return rows.map((r) {
      final id = r.read<int>('id');
      final raw = r.read<Uint8List>('raw_frame');
      return ReadingRow(
        id: id,
        sessionId: r.read<int>('session_id'),
        takenAt: _dt(r.read<int>('taken_at_ms')),
        source: sourceFromDb(r.read<String>('source')),
        typeCode: r.read<int>('type'),
        config: r.read<int>('config'),
        flags: r.read<int>('flags'),
        name: decodeResult(Response(raw)).name,
        partId: r.readNullable<int>('part_id'),
        partNumber: r.readNullable<String>('part_number'),
        binId: r.readNullable<int>('bin_id'),
        binName: r.readNullable<String>('bin_name'),
        label: r.readNullable<String>('label'),
        starred: r.read<int>('starred') != 0,
        headline: heads[id] ?? const {},
      );
    }).toList();
  }

  /// Reactive variant: re-queries whenever the involved tables change.
  Stream<List<ReadingRow>> watchReadings(ReadingFilter f) {
    final tables = <ResultSetImplementation<dynamic, dynamic>>[
      db.readings,
      db.readingTags,
      db.readingParams,
      db.parts,
      db.bins,
    ];
    return db
        .tableUpdates(TableUpdateQuery.onAllTables(tables))
        .asyncMap((_) => listReadings(f))
        .startWithFuture(listReadings(f));
  }

  Future<Map<int, Map<String, double>>> _headlines(List<int> ids) async {
    if (ids.isEmpty) return const {};
    final q = db.select(db.readingParams)
      ..where((p) => p.readingId.isIn(ids) & p.key.isIn(headlineKeys));
    final out = <int, Map<String, double>>{};
    for (final p in await q.get()) {
      out.putIfAbsent(p.readingId, () => {})[p.key] = p.value;
    }
    return out;
  }

  Future<ReadingDetail?> loadReading(int id) async {
    final r = await (db.select(db.readings)..where((x) => x.id.equals(id)))
        .getSingleOrNull();
    if (r == null) return null;
    final list = await db.customSelect('''
SELECT r.id, r.session_id, r.taken_at_ms, r.source, r.type, r.config, r.flags, r.raw_frame,
       t.part_id, p.part_number, t.bin_id, b.name AS bin_name, t.label, IFNULL(t.starred, 0) AS starred,
       t.notes, t.updated_at_ms, s.device_serial
FROM readings r
LEFT JOIN reading_tags t ON t.reading_id = r.id
LEFT JOIN parts p ON p.id = t.part_id
LEFT JOIN bins b ON b.id = t.bin_id
LEFT JOIN sessions s ON s.id = r.session_id
WHERE r.id = ?''', variables: [Variable(id)]).get();
    final x = list.single;
    final result = decodeResult(Response(r.rawFrame));
    final heads = await _headlines([id]);
    final row = ReadingRow(
      id: id,
      sessionId: r.sessionId,
      takenAt: _dt(r.takenAtMs),
      source: sourceFromDb(r.source),
      typeCode: r.type,
      config: r.config,
      flags: r.flags,
      name: result.name,
      partId: x.readNullable<int>('part_id'),
      partNumber: x.readNullable<String>('part_number'),
      binId: x.readNullable<int>('bin_id'),
      binName: x.readNullable<String>('bin_name'),
      label: x.readNullable<String>('label'),
      starred: x.read<int>('starred') != 0,
      headline: heads[id] ?? const {},
    );
    final updated = x.readNullable<int>('updated_at_ms');
    return ReadingDetail(
      row: row,
      result: result,
      tag: ReadingTag(
        partId: row.partId,
        binId: row.binId,
        label: row.label,
        notes: x.readNullable<String>('notes'),
        starred: row.starred,
        updatedAt: updated == null ? null : _dt(updated),
      ),
      sweeps: await listSweeps(readingId: id),
      battV: r.battV,
      v12V: r.v12V,
      vrefV: r.vrefV,
      deviceSerial: x.readNullable<String>('device_serial'),
    );
  }

  Future<int> countReadings() async {
    final row =
        await db.customSelect('SELECT COUNT(*) AS n FROM readings').getSingle();
    return row.read<int>('n');
  }

  // ------------------------------------------------------------- parts/bins

  Future<int> upsertPart({
    required String partNumber,
    String? manufacturer,
    String? description,
    String? family,
  }) async {
    final existing = await (db.select(db.parts)
          ..where((p) =>
              p.partNumber.equals(partNumber.trim()) &
              (manufacturer == null
                  ? p.manufacturer.isNull()
                  : p.manufacturer.equals(manufacturer))))
        .getSingleOrNull();
    if (existing != null) {
      if (description != null || family != null) {
        await (db.update(db.parts)..where((p) => p.id.equals(existing.id)))
            .write(PartsCompanion(
                description: description != null
                    ? Value(description)
                    : const Value.absent(),
                family: family != null ? Value(family) : const Value.absent()));
      }
      return existing.id;
    }
    return db.into(db.parts).insert(PartsCompanion.insert(
          partNumber: partNumber.trim(),
          manufacturer: Value(manufacturer),
          description: Value(description),
          family: Value(family),
        ));
  }

  Future<List<PartRow>> listParts({String? search}) async {
    final rows = await db
        .customSelect(
            '''
SELECT p.id, p.part_number, p.manufacturer, p.description, p.family,
  (SELECT COUNT(*) FROM reading_tags t WHERE t.part_id = p.id) AS reading_count,
  (SELECT COUNT(*) FROM bins b WHERE b.part_id = p.id) AS bin_count
FROM parts p
${search == null || search.trim().isEmpty ? '' : 'WHERE p.part_number LIKE ? OR p.description LIKE ?'}
ORDER BY p.part_number COLLATE NOCASE''',
            variables: search == null || search.trim().isEmpty
                ? const []
                : [
                    Variable('%${search.trim()}%'),
                    Variable('%${search.trim()}%')
                  ],
            readsFrom: {db.parts, db.readingTags, db.bins})
        .get();
    return rows
        .map((r) => PartRow(
              id: r.read<int>('id'),
              partNumber: r.read<String>('part_number'),
              manufacturer: r.readNullable<String>('manufacturer'),
              description: r.readNullable<String>('description'),
              family: r.readNullable<String>('family'),
              readingCount: r.read<int>('reading_count'),
              binCount: r.read<int>('bin_count'),
            ))
        .toList();
  }

  Stream<List<PartRow>> watchParts() => db
      .tableUpdates(
          TableUpdateQuery.onAllTables([db.parts, db.readingTags, db.bins]))
      .asyncMap((_) => listParts())
      .startWithFuture(listParts());

  Future<int> createBin(int partId, String name, {String? notes}) async {
    final existing = await (db.select(db.bins)
          ..where((b) => b.partId.equals(partId) & b.name.equals(name.trim())))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return db.into(db.bins).insert(BinsCompanion.insert(
          partId: partId,
          name: name.trim(),
          createdAtMs: _ms(DateTime.now()),
          notes: Value(notes),
        ));
  }

  Future<List<BinRow>> listBins({int? partId}) async {
    final rows = await db
        .customSelect(
            '''
SELECT b.id, b.part_id, b.name, b.created_at_ms, b.notes,
  (SELECT COUNT(*) FROM reading_tags t WHERE t.bin_id = b.id) AS reading_count
FROM bins b ${partId == null ? '' : 'WHERE b.part_id = ?'}
ORDER BY b.created_at_ms DESC''',
            variables: partId == null ? const [] : [Variable(partId)],
            readsFrom: {db.bins, db.readingTags})
        .get();
    return rows
        .map((r) => BinRow(
              id: r.read<int>('id'),
              partId: r.read<int>('part_id'),
              name: r.read<String>('name'),
              createdAt: _dt(r.read<int>('created_at_ms')),
              notes: r.readNullable<String>('notes'),
              readingCount: r.read<int>('reading_count'),
            ))
        .toList();
  }

  Stream<List<BinRow>> watchBins({int? partId}) => db
      .tableUpdates(TableUpdateQuery.onAllTables([db.bins, db.readingTags]))
      .asyncMap((_) => listBins(partId: partId))
      .startWithFuture(listBins(partId: partId));

  // ------------------------------------------------------------------ stats

  /// Values of [key] for every reading in the bin (or the part when
  /// [binId] is null and [partId] given), keyed by reading id.
  Future<Map<int, double>> valuesFor(String key,
      {int? binId, int? partId}) async {
    assert(binId != null || partId != null);
    final rows = await db.customSelect('''
SELECT p.reading_id, p.value FROM reading_params p
JOIN reading_tags t ON t.reading_id = p.reading_id
WHERE p.key = ? AND ${binId != null ? 't.bin_id = ?' : 't.part_id = ?'}''',
        variables: [Variable(key), Variable(binId ?? partId!)],
        readsFrom: {db.readingParams, db.readingTags}).get();
    return {
      for (final r in rows) r.read<int>('reading_id'): r.read<double>('value')
    };
  }

  Future<BinStats> binStats(String key,
          {int? binId, int? partId, int buckets = 12}) async =>
      BinStats.compute(
          key, (await valuesFor(key, binId: binId, partId: partId)).values,
          buckets: buckets);

  /// Where a value falls (0..100) among its bin.
  Future<double> percentileOf(String key, double value,
          {int? binId, int? partId}) async =>
      (await binStats(key, binId: binId, partId: partId)).percentileOf(value);

  Future<List<(int id, double value, double distance)>> nearestReadings(
      String key, int readingId, int k,
      {int? binId, int? partId}) async {
    final vals = await valuesFor(key, binId: binId, partId: partId);
    final target = vals[readingId];
    if (target == null) return const [];
    return nearest(vals, target, k, excludeId: readingId);
  }

  // ----------------------------------------------------------------- sweeps

  Future<int> saveSweep(
    int sessionId, {
    int? readingId,
    required SweepParams params,
    required List<SweepTrace> traces,
    required DateTime startedAt,
    Duration? duration,
    bool cancelled = false,
    String? error,
  }) =>
      db.transaction(() async {
        final id = await db.into(db.sweeps).insert(SweepsCompanion.insert(
              sessionId: sessionId,
              readingId: Value(readingId),
              kind: params.kind.name,
              paramsJson: jsonEncode(params.toJson()),
              xLabel: params.kind.xLabel,
              yLabel: params.kind.yLabel,
              startedAtMs: _ms(startedAt),
              durationMs: Value(duration?.inMilliseconds),
              cancelled: Value(cancelled),
              error: Value(error),
            ));
        await db.batch((b) => b.insertAll(
            db.sweepTraces,
            traces
                .map((t) => SweepTracesCompanion.insert(
                      sweepId: id,
                      idx: t.index,
                      label: t.label,
                      nPoints: t.points.length,
                      points: packPoints(t.points),
                    ))
                .toList()));
        return id;
      });

  Future<List<SweepRow>> listSweeps(
      {int? readingId, int? sessionId, int limit = 200}) async {
    final where = <String>[];
    final args = <Object>[];
    if (readingId != null) {
      where.add('s.reading_id = ?');
      args.add(readingId);
    }
    if (sessionId != null) {
      where.add('s.session_id = ?');
      args.add(sessionId);
    }
    args.add(limit);
    final rows = await db
        .customSelect(
            '''
SELECT s.id, s.session_id, s.reading_id, s.kind, s.started_at_ms, s.duration_ms, s.cancelled, s.error,
  (SELECT COUNT(*) FROM sweep_traces t WHERE t.sweep_id = s.id) AS trace_count,
  (SELECT IFNULL(SUM(n_points),0) FROM sweep_traces t WHERE t.sweep_id = s.id) AS point_count
FROM sweeps s ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
ORDER BY s.started_at_ms DESC LIMIT ?''',
            variables: args.map(Variable.new).toList(),
            readsFrom: {db.sweeps, db.sweepTraces})
        .get();
    return rows.map(_sweepRow).toList();
  }

  SweepRow _sweepRow(QueryRow r) => SweepRow(
        id: r.read<int>('id'),
        sessionId: r.read<int>('session_id'),
        readingId: r.readNullable<int>('reading_id'),
        kind: SweepKind.fromName(r.read<String>('kind')),
        startedAt: _dt(r.read<int>('started_at_ms')),
        durationMs: r.readNullable<int>('duration_ms'),
        cancelled: r.read<int>('cancelled') != 0,
        error: r.readNullable<String>('error'),
        traceCount: r.read<int>('trace_count'),
        pointCount: r.read<int>('point_count'),
      );

  Future<SweepDetail?> loadSweep(int id) async {
    final rows = await listSweeps(limit: 1 << 30);
    final row = rows.where((s) => s.id == id).firstOrNull;
    if (row == null) return null;
    final s =
        await (db.select(db.sweeps)..where((x) => x.id.equals(id))).getSingle();
    final ts = await (db.select(db.sweepTraces)
          ..where((t) => t.sweepId.equals(id))
          ..orderBy([(t) => OrderingTerm.asc(t.idx)]))
        .get();
    final traces = ts.map((t) {
      final tr = SweepTrace(t.idx, t.label);
      tr.points.addAll(unpackPoints(t.points));
      return tr;
    }).toList();
    return SweepDetail(
      row: row,
      params: SweepParams.fromJson(
          jsonDecode(s.paramsJson) as Map<String, Object?>),
      traces: traces,
    );
  }

  Future<void> deleteSweep(int id) =>
      (db.delete(db.sweeps)..where((s) => s.id.equals(id))).go();
}

extension _StartWith<T> on Stream<T> {
  Stream<T> startWithFuture(Future<T> first) async* {
    yield await first;
    yield* this;
  }
}
