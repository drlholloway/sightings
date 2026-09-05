import 'dart:convert';
import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';

import 'transport_log.dart';

/// `.dcalog` capture format: one exchange per line,
/// `<iso8601> <128 hex chars out> <128 hex chars in|-> <duration_ms>`;
/// lines starting with `#` are comments.
class CaptureLine {
  const CaptureLine({
    required this.at,
    required this.out,
    required this.input,
    required this.durationMs,
  });

  final DateTime at;
  final Uint8List out;
  final Uint8List? input;
  final double durationMs;

  int get opcode => out[0];

  static String _hex(Uint8List b) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

  static Uint8List _unhex(String s) {
    final out = Uint8List(s.length ~/ 2);
    for (var i = 0; i < out.length; i++) {
      out[i] = int.parse(s.substring(2 * i, 2 * i + 2), radix: 16);
    }
    return out;
  }

  String encode() =>
      '${at.toUtc().toIso8601String()} ${_hex(out)} ${input == null ? '-' : _hex(input!)} ${durationMs.toStringAsFixed(3)}';

  static CaptureLine? decode(String line) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('#')) return null;
    final parts = t.split(RegExp(r'\s+'));
    if (parts.length < 4) {
      throw FormatException('bad capture line: $line');
    }
    final out = _unhex(parts[1]);
    if (out.length != frameLength) {
      throw FormatException('out frame must be $frameLength bytes: $line');
    }
    final input = parts[2] == '-' ? null : _unhex(parts[2]);
    return CaptureLine(
      at: DateTime.parse(parts[0]),
      out: out,
      input: input,
      durationMs: double.parse(parts[3]),
    );
  }

  factory CaptureLine.fromLog(TransportLogEntry e) => CaptureLine(
        at: e.at,
        out: e.out,
        input: e.input,
        durationMs: e.duration.inMicroseconds / 1000,
      );
}

/// Parse a whole capture file.
List<CaptureLine> parseCapture(String text) => const LineSplitter()
    .convert(text)
    .map(CaptureLine.decode)
    .whereType<CaptureLine>()
    .toList();

/// Serialise log entries as a capture file (with a header comment).
String encodeCapture(Iterable<TransportLogEntry> entries, {String? comment}) {
  final sb = StringBuffer();
  sb.writeln('# dcalog v1${comment == null ? '' : ' - $comment'}');
  for (final e in entries) {
    sb.writeln(CaptureLine.fromLog(e).encode());
  }
  return sb.toString();
}
