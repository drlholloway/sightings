import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';

/// One exchange as seen by the transport.
class TransportLogEntry {
  TransportLogEntry({
    required this.opcode,
    required this.out,
    required this.input,
    required this.duration,
    this.error,
    DateTime? at,
  }) : at = at ?? DateTime.now();

  final DateTime at;
  final int opcode;
  final Uint8List out;
  final Uint8List? input;
  final Duration duration;
  final String? error;

  bool get ok => error == null;

  String get opcodeName =>
      Opcode.fromCode(opcode)?.name.toUpperCase() ??
      '0x${opcode.toRadixString(16)}';

  String _head(Uint8List? b, [int n = 8]) => b == null
      ? '-'
      : b
          .sublist(0, n)
          .map((x) => x.toRadixString(16).padLeft(2, '0'))
          .join(' ');

  @override
  String toString() {
    final t = at.toIso8601String().substring(11, 23);
    final d = '${duration.inMicroseconds / 1000}ms';
    final base = '[$t] $opcodeName out ${_head(out)} | in ${_head(input)} $d';
    return error == null ? base : '$base ERROR $error';
  }
}

/// Rolling in-memory log of exchanges, plus a broadcast stream for UIs and
/// capture writers.
class TransportLog {
  TransportLog({this.capacity = 2000});

  final int capacity;
  final _entries = ListQueue<TransportLogEntry>();
  final _controller = StreamController<TransportLogEntry>.broadcast();

  Stream<TransportLogEntry> get stream => _controller.stream;
  List<TransportLogEntry> get entries => List.unmodifiable(_entries);
  int get length => _entries.length;

  void add(TransportLogEntry e) {
    _entries.addLast(e);
    while (_entries.length > capacity) {
      _entries.removeFirst();
    }
    if (!_controller.isClosed) _controller.add(e);
  }

  void clear() => _entries.clear();

  /// Latency statistics over successful entries.
  ({int n, Duration p50, Duration p95, Duration max}) latency() {
    final ds = _entries.where((e) => e.ok).map((e) => e.duration).toList()
      ..sort();
    if (ds.isEmpty) {
      return (n: 0, p50: Duration.zero, p95: Duration.zero, max: Duration.zero);
    }
    Duration pct(double p) => ds[((ds.length - 1) * p).round()];
    return (n: ds.length, p50: pct(0.5), p95: pct(0.95), max: ds.last);
  }

  Future<void> dispose() => _controller.close();
}
