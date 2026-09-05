# Phase 4 — Datastore (`packages/dca75_store`)

**Goal:** a versioned SQLite database (via `drift`) that stores devices, sessions, identify
readings with raw frames and decoded parameters, sweeps with traces, and user annotations
(parts, bins, tags, notes); DAOs for the UI; export/import; and migration tests.

**Effort:** 3–4 days. **Hardware:** none.

## Schema (drift tables; DDL shown for clarity)

```sql
CREATE TABLE devices (
  serial        TEXT PRIMARY KEY,
  product_name  TEXT, hardware_rev TEXT, firmware_rev TEXT,
  r_mt2 REAL, cal_r1k0 REAL, cal_r8k2 REAL, cal_r68k REAL, cal_r470k REAL,
  first_seen    INTEGER NOT NULL, last_seen INTEGER NOT NULL          -- unix ms
);
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY, device_serial TEXT REFERENCES devices(serial),
  started_at INTEGER NOT NULL, ended_at INTEGER,
  platform TEXT NOT NULL, app_version TEXT NOT NULL, notes TEXT
);
CREATE TABLE readings (
  id INTEGER PRIMARY KEY, session_id INTEGER NOT NULL REFERENCES sessions(id),
  taken_at INTEGER NOT NULL, source TEXT NOT NULL CHECK (source IN ('app','unit_button','import')),
  type INTEGER NOT NULL, config INTEGER NOT NULL, flags INTEGER NOT NULL,
  raw_frame BLOB NOT NULL CHECK (length(raw_frame) = 64),
  decoder_version INTEGER NOT NULL,
  batt_v REAL, v12_v REAL, vref_v REAL
);
CREATE TABLE reading_params (
  reading_id INTEGER NOT NULL REFERENCES readings(id) ON DELETE CASCADE,
  key TEXT NOT NULL, value REAL NOT NULL, unit TEXT NOT NULL,
  PRIMARY KEY (reading_id, key)
);
CREATE TABLE parts (
  id INTEGER PRIMARY KEY, part_number TEXT NOT NULL, manufacturer TEXT, description TEXT,
  family TEXT,                         -- 'bjt','mosfet','jfet','diode',... (ComponentType name)
  UNIQUE (part_number, manufacturer)
);
CREATE TABLE bins (
  id INTEGER PRIMARY KEY, part_id INTEGER NOT NULL REFERENCES parts(id), name TEXT NOT NULL,
  created_at INTEGER NOT NULL, notes TEXT, UNIQUE (part_id, name)
);
CREATE TABLE reading_tags (                -- one row per reading; annotations are separate from the immutable reading
  reading_id INTEGER PRIMARY KEY REFERENCES readings(id) ON DELETE CASCADE,
  part_id INTEGER REFERENCES parts(id), bin_id INTEGER REFERENCES bins(id),
  label TEXT, notes TEXT, starred INTEGER NOT NULL DEFAULT 0, updated_at INTEGER NOT NULL
);
CREATE TABLE sweeps (
  id INTEGER PRIMARY KEY, session_id INTEGER NOT NULL REFERENCES sessions(id),
  reading_id INTEGER REFERENCES readings(id) ON DELETE SET NULL,   -- the identify result the sweep was based on
  kind TEXT NOT NULL,                       -- 'icvce','hfeic','idvds','idvgs','pniv'
  params_json TEXT NOT NULL, x_label TEXT NOT NULL, y_label TEXT NOT NULL,
  started_at INTEGER NOT NULL, duration_ms INTEGER, cancelled INTEGER NOT NULL DEFAULT 0, error TEXT
);
CREATE TABLE sweep_traces (
  id INTEGER PRIMARY KEY, sweep_id INTEGER NOT NULL REFERENCES sweeps(id) ON DELETE CASCADE,
  idx INTEGER NOT NULL, label TEXT NOT NULL, n_points INTEGER NOT NULL,
  points BLOB NOT NULL                       -- little‑endian float64 pairs [x0,y0,x1,y1,...]
);
CREATE TABLE schema_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);   -- 'created_by', 'db_uuid'

CREATE INDEX ix_readings_taken ON readings(taken_at);
CREATE INDEX ix_readings_type  ON readings(type);
CREATE INDEX ix_params_key_val ON reading_params(key, value);
CREATE INDEX ix_tags_part_bin  ON reading_tags(part_id, bin_id);
CREATE INDEX ix_sweeps_reading ON sweeps(reading_id);

CREATE VIEW reading_headlines AS
  SELECT r.id, r.taken_at, r.type, r.config, r.flags, t.part_id, t.bin_id, t.label,
    MAX(CASE p.key WHEN 'hfe'     THEN p.value END) AS hfe,
    MAX(CASE p.key WHEN 'vbe_5ma' THEN p.value END) AS vbe_5ma,
    MAX(CASE p.key WHEN 'ic_leak' THEN p.value END) AS ic_leak,
    MAX(CASE p.key WHEN 'vgs_th'  THEN p.value END) AS vgs_th,
    MAX(CASE p.key WHEN 'rds_on'  THEN p.value END) AS rds_on,
    MAX(CASE p.key WHEN 'vgs_off' THEN p.value END) AS vgs_off,
    MAX(CASE p.key WHEN 'idss'    THEN p.value END) AS idss,
    MAX(CASE p.key WHEN 'd1_vf'   THEN p.value END) AS vf,
    MAX(CASE p.key WHEN 'vout'    THEN p.value END) AS vout
  FROM readings r LEFT JOIN reading_tags t ON t.reading_id = r.id
  LEFT JOIN reading_params p ON p.reading_id = r.id
  GROUP BY r.id;
```

Design notes
- `PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON;` on open.
- `decoder_version` lets a future `re-decode` command regenerate `reading_params` from
  `raw_frame` without touching `reading_tags`.
- Points as float64 BLOB: a 5‑trace × 51‑point family is ~4 KB; loading a sweep is one query.
- Timestamps as unix milliseconds UTC; display in local time.

## DAOs / repository API

```dart
class ReadingsRepository {
  Future<int> startSession(DeviceIdentity id, Calibration? cal, {required String platform, required String appVersion});
  Future<void> endSession(int sessionId);
  Future<int> saveReading(int sessionId, IdentifyResult r, {required ReadingSource source, Rails? rails});
  Future<int> saveSweep(int sessionId, SweepRecord s);              // called once at sweep end (traces included)
  Future<void> tagReading(int readingId, {int? partId, int? binId, String? label, String? notes, bool? starred});
  Stream<List<ReadingRow>> watchReadings(ReadingFilter f);          // type, part, bin, date range, text, untagged-only; paged
  Future<ReadingDetail> loadReading(int id);                        // reading + params + tags + sweeps list
  Future<SweepDetail> loadSweep(int id);
  Stream<List<PartRow>> watchParts(); Future<int> upsertPart(...); Future<int> createBin(...);
  Future<BinStats> binStats(int binId, String key);                 // n, min, max, mean, stddev, p5/p25/p50/p75/p95, histogram(k buckets)
  Future<double> percentileOf(int binId, String key, double value); // where a reading falls in its bin
  Future<void> reDecodeAll(int fromDecoderVersion);
}
```

`binStats` is one SQL query over `reading_params` filtered by bin; histogram bucketing is
done in Dart on the returned values (n is small, thousands at most).

## Export / import

- **Backup**: `VACUUM INTO '<path>'` to write a consistent snapshot; share via the platform
  share sheet (Android) or save dialog (desktop). Restore = close DB, copy file, reopen,
  run migrations.
- **CSV**: readings (one row per reading, headline columns + all params pivoted), a bin
  (same, filtered), a sweep (`trace,x,y`, identical to the reference client).
- **Merge import** (later): import another `.sqlite` skipping readings whose
  `(device_serial, taken_at, raw_frame)` already exist. Needed for the iOS viewer and for
  combining desktop and phone databases. Design the `db_uuid` in `schema_meta` now.

## Tasks
1. Drift tables + view + indices; `AppDatabase` with `NativeDatabase.createInBackground`.
2. Migration strategy: `MigrationStrategy(onCreate, onUpgrade)` with a `schemaVersion` constant; drift's schema‑export tooling to generate `drift_schemas/v1.json` and write migration tests (`drift_dev schema generate`).
3. Repository implementation + `ReadingFilter` query builder.
4. `binStats`/`percentileOf` with unit tests on known data (e.g. 100 synthetic hFE values).
5. Backup/restore and CSV writers; tests against an in‑memory database.
6. `tools/dca75_cli import-dcalog file.dcalog` — turns a capture into readings (source=`import`) so the UI can be developed against realistic data without hardware.

## Acceptance criteria
- All repository tests green against in‑memory SQLite.
- Migration test proves v1 schema matches the generated schema file.
- Backup → restore round‑trip preserves counts and a spot‑checked raw frame byte‑for‑byte.
- `reading_headlines` view query for “all BJTs in bin X ordered by hFE” returns in < 50 ms with 10 000 readings (seed script in `tools/`).
