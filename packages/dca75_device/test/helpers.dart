import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';

/// A TEST(2) frame for an NPN silicon BJT in config [cfg] with hFE [hfe].
Uint8List bjtFrame({int cfg = 1, double hfe = 200}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 1;
  b[3] = cfg;
  b[4] = bjtFlagNpn | bjtFlagSilicon;
  final f = [0.001, 0.71, 0.65, 0.024, 0.005, hfe, 5.0, 0.09, 10, 1, 0, 0];
  for (var i = 0; i < f.length; i++) {
    d.setFloat32(5 + 4 * i, f[i].toDouble(), Endian.little);
  }
  return b;
}

/// A TEST(2) frame for an N-channel JFET in config [cfg].
Uint8List jfetFrame({int cfg = 5, double vgsOff = -2.4}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 8;
  b[3] = cfg;
  b[4] = jfetFlagNChannel;
  final f = [vgsOff, 0.0001, -0.5, 3, 0, 0.004, 5.2, 0, 5, 0, 0, 150, 1];
  for (var i = 0; i < f.length; i++) {
    d.setFloat32(5 + 4 * i, f[i].toDouble(), Endian.little);
  }
  return b;
}

IdentifyResult decodeFrame(Uint8List b) => decodeResult(Response(b));
