import 'package:drift/drift.dart';

part 'database.g.dart';

/// Timestamps are stored as unix milliseconds (UTC) in INTEGER columns so
/// the file is trivially readable from any SQLite client.

class Devices extends Table {
  TextColumn get serial => text()();
  TextColumn get productName => text().nullable()();
  TextColumn get hardwareRev => text().nullable()();
  TextColumn get firmwareRev => text().nullable()();
  RealColumn get rMt2 => real().nullable()();
  RealColumn get calR1k0 => real().nullable()();
  RealColumn get calR8k2 => real().nullable()();
  RealColumn get calR68k => real().nullable()();
  RealColumn get calR470k => real().nullable()();
  IntColumn get firstSeenMs => integer()();
  IntColumn get lastSeenMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {serial};
}

class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceSerial =>
      text().nullable().references(Devices, #serial)();
  IntColumn get startedAtMs => integer()();
  IntColumn get endedAtMs => integer().nullable()();
  TextColumn get platform => text()();
  TextColumn get appVersion => text()();
  TextColumn get notes => text().nullable()();
}

@DataClassName('ReadingEntity')
class Readings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  IntColumn get takenAtMs => integer()();
  TextColumn get source => text()(); // app | unit_button | import
  IntColumn get type => integer()();
  IntColumn get config => integer()();
  IntColumn get flags => integer()();
  BlobColumn get rawFrame => blob()();
  IntColumn get decoderVersion => integer()();
  RealColumn get battV => real().nullable()();
  RealColumn get v12V => real().nullable()();
  RealColumn get vrefV => real().nullable()();
}

class ReadingParams extends Table {
  IntColumn get readingId =>
      integer().references(Readings, #id, onDelete: KeyAction.cascade)();
  TextColumn get key => text()();
  RealColumn get value => real()();
  TextColumn get unit => text()();

  @override
  Set<Column<Object>> get primaryKey => {readingId, key};
}

@DataClassName('PartEntity')
class Parts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get partNumber => text()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get family => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {partNumber, manufacturer},
      ];
}

@DataClassName('BinEntity')
class Bins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get partId =>
      integer().references(Parts, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  IntColumn get createdAtMs => integer()();
  TextColumn get notes => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {partId, name},
      ];
}

/// One row per reading; annotations are kept apart from the immutable
/// reading so re-decoding never touches them.
@DataClassName('ReadingTagEntity')
class ReadingTags extends Table {
  IntColumn get readingId =>
      integer().references(Readings, #id, onDelete: KeyAction.cascade)();
  IntColumn get partId => integer()
      .nullable()
      .references(Parts, #id, onDelete: KeyAction.setNull)();
  IntColumn get binId =>
      integer().nullable().references(Bins, #id, onDelete: KeyAction.setNull)();
  TextColumn get label => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get starred => boolean().withDefault(const Constant(false))();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {readingId};
}

@DataClassName('SweepEntity')
class Sweeps extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(Sessions, #id)();
  IntColumn get readingId => integer()
      .nullable()
      .references(Readings, #id, onDelete: KeyAction.setNull)();
  TextColumn get kind => text()();
  TextColumn get paramsJson => text()();
  TextColumn get xLabel => text()();
  TextColumn get yLabel => text()();
  IntColumn get startedAtMs => integer()();
  IntColumn get durationMs => integer().nullable()();
  BoolColumn get cancelled => boolean().withDefault(const Constant(false))();
  TextColumn get error => text().nullable()();
}

@DataClassName('SweepTraceEntity')
class SweepTraces extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sweepId =>
      integer().references(Sweeps, #id, onDelete: KeyAction.cascade)();
  IntColumn get idx => integer()();
  TextColumn get label => text()();
  IntColumn get nPoints => integer()();

  /// Little-endian float64 pairs `[x0, y0, x1, y1, ...]`.
  BlobColumn get points => blob()();
}

class SchemaMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Headline keys pivoted by the `reading_headlines` view.
const List<String> headlineKeys = [
  'hfe',
  'vbe_5ma',
  'ic_leak',
  'vce_sat',
  'vgs_th',
  'rds_on',
  'gm',
  'vgs_off',
  'idss',
  'gfs',
  'vf',
  'vz',
  'vout',
  'vdo',
  'igt',
  'vgt',
  'v_hold',
];

String _headlineViewSql() {
  final cols = headlineKeys
      .map((k) => "    MAX(CASE p.key WHEN '$k' THEN p.value END) AS $k")
      .join(',\n');
  return '''
CREATE VIEW IF NOT EXISTS reading_headlines AS
  SELECT r.id, r.session_id, r.taken_at_ms, r.source, r.type, r.config, r.flags,
    t.part_id, t.bin_id, t.label, t.starred,
$cols
  FROM readings r
  LEFT JOIN reading_tags t ON t.reading_id = r.id
  LEFT JOIN reading_params p ON p.reading_id = r.id
  GROUP BY r.id''';
}

@DriftDatabase(tables: [
  Devices,
  Sessions,
  Readings,
  ReadingParams,
  Parts,
  Bins,
  ReadingTags,
  Sweeps,
  SweepTraces,
  SchemaMeta,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexesAndViews();
          await into(schemaMeta).insert(
              SchemaMetaCompanion.insert(key: 'db_uuid', value: _uuid()));
          await into(schemaMeta).insert(SchemaMetaCompanion.insert(
              key: 'created_at',
              value: DateTime.now().toUtc().toIso8601String()));
        },
        onUpgrade: (m, from, to) async {
          // Future versions: step migrations here, then refresh the view.
          await customStatement('DROP VIEW IF EXISTS reading_headlines');
          await _createIndexesAndViews();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  Future<void> _createIndexesAndViews() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS ix_readings_taken ON readings(taken_at_ms)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS ix_readings_type ON readings(type)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS ix_params_key_val ON reading_params(key, value)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS ix_tags_part_bin ON reading_tags(part_id, bin_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS ix_sweeps_reading ON sweeps(reading_id)');
    await customStatement(_headlineViewSql());
  }

  static String _uuid() {
    final r = DateTime.now().microsecondsSinceEpoch;
    final h = r.toRadixString(16).padLeft(16, '0');
    final rnd = (r * 6364136223846793005 + 1442695040888963407)
        .toUnsigned(64)
        .toRadixString(16)
        .padLeft(16, '0');
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-4${h.substring(13, 16)}-${rnd.substring(0, 4)}-${rnd.substring(4, 16)}';
  }

  /// `VACUUM INTO` a consistent snapshot at [path].
  Future<void> backupTo(String path) =>
      customStatement('VACUUM INTO ?', [path]);

  Future<String?> meta(String key) async {
    final row = await (select(schemaMeta)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }
}
