import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:drift/native.dart';

AppDatabase memDb() => AppDatabase(NativeDatabase.memory());

Uint8List bjtFrame({int cfg = 1, double hfe = 200, double vbe = 0.71}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 1;
  b[3] = cfg;
  b[4] = bjtFlagNpn | bjtFlagSilicon;
  final f = [0.001, vbe, 0.65, 0.024, 0.005, hfe, 5.0, 0.09, 10, 1, 0, 0];
  for (var i = 0; i < f.length; i++) {
    d.setFloat32(5 + 4 * i, f[i].toDouble(), Endian.little);
  }
  return b;
}

Uint8List diodeFrame({double vf = 0.62}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 6;
  b[3] = 1;
  b[5] = 1;
  b[6] = 4;
  d.setFloat32(7, vf, Endian.little);
  d.setFloat32(11, 5, Endian.little);
  return b;
}

IdentifyResult bjt({int cfg = 1, double hfe = 200, double vbe = 0.71}) =>
    decodeResult(Response(bjtFrame(cfg: cfg, hfe: hfe, vbe: vbe)));

IdentifyResult diode({double vf = 0.62}) =>
    decodeResult(Response(diodeFrame(vf: vf)));
