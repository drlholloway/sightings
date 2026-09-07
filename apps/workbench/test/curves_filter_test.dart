import 'dart:typed_data';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workbench/features/curves/curves_screen.dart';

Uint8List frame(int type, int cfg, int flags) {
  final b = Uint8List(64)..[0] = 0x85;
  b[2] = type;
  b[3] = cfg;
  b[4] = flags;
  if (type == 6) {
    b[3] = 1;
    b[5] = 1;
    b[6] = cfg;
  }
  return b;
}

IdentifyResult res(int type, {int cfg = 1, int flags = 0}) =>
    decodeResult(Response(frame(type, cfg, flags)));

void main() {
  test('sweep kinds are filtered by the identified component', () {
    expect(sweepKindsFor(null), [SweepKind.pniv, SweepKind.revleak]);
    expect(sweepKindsFor(res(1, flags: bjtFlagNpn)), [
      SweepKind.icvce,
      SweepKind.hfeic,
      SweepKind.pniv,
      SweepKind.revleak,
    ]);
    expect(sweepKindsFor(res(8, flags: jfetFlagNChannel)), [
      SweepKind.idvds,
      SweepKind.idvgs,
      SweepKind.pniv,
      SweepKind.revleak,
    ]);
    expect(sweepKindsFor(res(2, flags: fetFlagNChannel)), [
      SweepKind.idvds,
      SweepKind.idvgs,
      SweepKind.pniv,
      SweepKind.revleak,
    ]);
    expect(sweepKindsFor(res(6)), [SweepKind.pniv, SweepKind.revleak]);
    expect(sweepKindsFor(res(9)), [SweepKind.pniv, SweepKind.revleak]);
  });
}
