import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';

/// Build a synthetic 64-byte response for tests.
Response synth(int opcode, void Function(ByteData d) fill) {
  final b = Uint8List(frameLength);
  b[0] = opcode;
  fill(ByteData.sublistView(b));
  return Response(b);
}

void f32(ByteData d, int off, double v) => d.setFloat32(off, v, Endian.little);
void u16(ByteData d, int off, int v) => d.setUint16(off, v, Endian.little);

/// Write consecutive floats starting at `off`.
void floats(ByteData d, int off, List<double> vs) {
  for (var i = 0; i < vs.length; i++) {
    f32(d, off + 4 * i, vs[i]);
  }
}
