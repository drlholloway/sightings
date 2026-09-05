import 'dart:typed_data';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';

/// Row shape for history lists.
class ReadingRow {
  const ReadingRow({
    required this.id,
    required this.sessionId,
    required this.takenAt,
    required this.source,
    required this.typeCode,
    required this.config,
    required this.flags,
    required this.name,
    this.partId,
    this.partNumber,
    this.binId,
    this.binName,
    this.label,
    this.starred = false,
    this.headline = const {},
  });

  final int id;
  final int sessionId;
  final DateTime takenAt;
  final ReadingSource source;
  final int typeCode;
  final int config;
  final int flags;

  /// Decoded display name ("NPN BJT", "Zener", ...).
  final String name;
  final int? partId;
  final String? partNumber;
  final int? binId;
  final String? binName;
  final String? label;
  final bool starred;
  final Map<String, double> headline;

  ComponentType get type => ComponentType.fromCode(typeCode);
  bool get isTagged =>
      partId != null || binId != null || (label?.isNotEmpty ?? false);
}

class ReadingTag {
  const ReadingTag({
    this.partId,
    this.binId,
    this.label,
    this.notes,
    this.starred = false,
    this.updatedAt,
  });
  final int? partId;
  final int? binId;
  final String? label;
  final String? notes;
  final bool starred;
  final DateTime? updatedAt;
}

class ReadingDetail {
  const ReadingDetail({
    required this.row,
    required this.result,
    required this.tag,
    required this.sweeps,
    this.battV,
    this.v12V,
    this.vrefV,
    this.deviceSerial,
  });
  final ReadingRow row;
  final IdentifyResult result;
  final ReadingTag tag;
  final List<SweepRow> sweeps;
  final double? battV, v12V, vrefV;
  final String? deviceSerial;
}

class PartRow {
  const PartRow({
    required this.id,
    required this.partNumber,
    this.manufacturer,
    this.description,
    this.family,
    this.readingCount = 0,
    this.binCount = 0,
  });
  final int id;
  final String partNumber;
  final String? manufacturer, description, family;
  final int readingCount, binCount;

  String get displayName =>
      manufacturer == null ? partNumber : '$partNumber ($manufacturer)';
}

class BinRow {
  const BinRow({
    required this.id,
    required this.partId,
    required this.name,
    required this.createdAt,
    this.notes,
    this.readingCount = 0,
  });
  final int id;
  final int partId;
  final String name;
  final DateTime createdAt;
  final String? notes;
  final int readingCount;
}

class SweepRow {
  const SweepRow({
    required this.id,
    required this.sessionId,
    required this.kind,
    required this.startedAt,
    this.readingId,
    this.durationMs,
    this.cancelled = false,
    this.error,
    this.traceCount = 0,
    this.pointCount = 0,
  });
  final int id;
  final int sessionId;
  final int? readingId;
  final SweepKind kind;
  final DateTime startedAt;
  final int? durationMs;
  final bool cancelled;
  final String? error;
  final int traceCount, pointCount;
}

class SweepDetail {
  const SweepDetail(
      {required this.row, required this.params, required this.traces});
  final SweepRow row;
  final SweepParams params;
  final List<SweepTrace> traces;
}

/// Filter for [ReadingsRepository.watchReadings].
class ReadingFilter {
  const ReadingFilter({
    this.types = const {},
    this.partId,
    this.binId,
    this.from,
    this.to,
    this.text,
    this.untaggedOnly = false,
    this.starredOnly = false,
    this.sessionId,
    this.limit = 200,
    this.offset = 0,
    this.newestFirst = true,
  });

  final Set<ComponentType> types;
  final int? partId;
  final int? binId;
  final DateTime? from, to;
  final String? text;
  final bool untaggedOnly;
  final bool starredOnly;
  final int? sessionId;
  final int limit, offset;
  final bool newestFirst;

  ReadingFilter copyWith({
    Set<ComponentType>? types,
    int? partId,
    int? binId,
    DateTime? from,
    DateTime? to,
    String? text,
    bool? untaggedOnly,
    bool? starredOnly,
    int? sessionId,
    int? limit,
    int? offset,
    bool? newestFirst,
    bool clearPart = false,
    bool clearBin = false,
    bool clearDates = false,
  }) =>
      ReadingFilter(
        types: types ?? this.types,
        partId: clearPart ? null : (partId ?? this.partId),
        binId: clearBin ? null : (binId ?? this.binId),
        from: clearDates ? null : (from ?? this.from),
        to: clearDates ? null : (to ?? this.to),
        text: text ?? this.text,
        untaggedOnly: untaggedOnly ?? this.untaggedOnly,
        starredOnly: starredOnly ?? this.starredOnly,
        sessionId: sessionId ?? this.sessionId,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
        newestFirst: newestFirst ?? this.newestFirst,
      );
}

/// Pack/unpack sweep points as little-endian float64 pairs.
Uint8List packPoints(List<({double x, double y})> pts) {
  final out = Float64List(pts.length * 2);
  for (var i = 0; i < pts.length; i++) {
    out[2 * i] = pts[i].x;
    out[2 * i + 1] = pts[i].y;
  }
  final bytes = out.buffer.asUint8List();
  if (Endian.host == Endian.little) return Uint8List.fromList(bytes);
  final bd = ByteData(bytes.length);
  for (var i = 0; i < out.length; i++) {
    bd.setFloat64(8 * i, out[i], Endian.little);
  }
  return bd.buffer.asUint8List();
}

List<({double x, double y})> unpackPoints(Uint8List bytes) {
  final bd = ByteData.sublistView(bytes);
  final n = bytes.length ~/ 16;
  return List.generate(
      n,
      (i) => (
            x: bd.getFloat64(16 * i, Endian.little),
            y: bd.getFloat64(16 * i + 8, Endian.little)
          ),
      growable: false);
}

String sourceToDb(ReadingSource s) => switch (s) {
      ReadingSource.app => 'app',
      ReadingSource.unitButton => 'unit_button',
      ReadingSource.import => 'import',
    };

ReadingSource sourceFromDb(String s) => switch (s) {
      'unit_button' => ReadingSource.unitButton,
      'import' => ReadingSource.import,
      _ => ReadingSource.app,
    };
