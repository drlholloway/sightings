import 'package:dca75_device/dca75_device.dart';

import 'database.dart';
import 'models.dart';

String _q(Object? v) {
  if (v == null) return '';
  final s = v.toString();
  return s.contains(RegExp(r'[",\n]')) ? '"${s.replaceAll('"', '""')}"' : s;
}

/// One row per reading with the headline columns pivoted.
String readingsCsv(List<ReadingRow> rows) {
  final sb = StringBuffer();
  sb.writeln([
    'id',
    'taken_at',
    'source',
    'type',
    'name',
    'config',
    'flags',
    'part_number',
    'bin',
    'label',
    'starred',
    ...headlineKeys
  ].join(','));
  for (final r in rows) {
    sb.writeln([
      r.id,
      r.takenAt.toIso8601String(),
      sourceToDb(r.source),
      r.typeCode,
      _q(r.name),
      r.config,
      r.flags,
      _q(r.partNumber),
      _q(r.binName),
      _q(r.label),
      r.starred ? 1 : 0,
      ...headlineKeys.map((k) => r.headline[k]?.toString() ?? ''),
    ].join(','));
  }
  return sb.toString();
}

/// `trace,x,y` — identical to the reference client's export.
String sweepCsv(List<SweepTrace> traces) {
  final sb = StringBuffer('trace,x,y\n');
  for (final t in traces) {
    for (final p in t.points) {
      sb.writeln('${_q(t.label)},${p.x},${p.y}');
    }
  }
  return sb.toString();
}
