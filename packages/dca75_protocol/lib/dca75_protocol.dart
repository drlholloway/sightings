/// Pure-Dart protocol library for the Peak Atlas DCA75 ("DCA Pro").
///
/// Ported from the reference WebUSB client (`ref-docs/dca-bench.html`).
/// Contains no I/O: it builds 64-byte command frames, parses 64-byte
/// responses, and computes derived measurements. A transport (see
/// `dca75_transport`) moves the bytes.
library;

export 'src/commands.dart';
export 'src/constants.dart';
export 'src/frame.dart';
export 'src/measure.dart';
export 'src/parsers.dart';
export 'src/result.dart';
export 'src/tables.dart';
export 'src/units.dart';
