import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  DeviceMirror mirror() => DeviceMirror()
    ..rMt2 = 620
    ..rGate = 8200
    ..setGate = 3.0
    ..gate = 2.18
    ..setMt2 = 6.5
    ..mt2 = 5.26
    ..red = 1.0
    ..green = 4.0
    ..blue = 1.65;

  test('vce and vbe follow the lead tables', () {
    final m = mirror();
    // cfg 1: vce = green - red, vbe = blue - red
    expect(m.vce(1), closeTo(3.0, 1e-9));
    expect(m.vbe(1), closeTo(0.65, 1e-9));
    // cfg 7 (P): vce = red - green
    expect(m.vce(7), closeTo(-3.0, 1e-9));
  });

  test('ib and ic in mA, sign flipped for P configs', () {
    final m = mirror();
    expect(m.ib(1), closeTo(1000 * (3.0 - 2.18) / 8200, 1e-9));
    expect(m.ib(7), closeTo(-1000 * (3.0 - 2.18) / 8200, 1e-9));
    expect(m.ic(1), closeTo((6.5 - 5.26) * (1000 / 620), 1e-6));
    expect(m.ic(7), 0, reason: 'negative after flip -> floor');
  });

  test('ic zero floor', () {
    final m = mirror()
      ..setMt2 = 1.0
      ..mt2 = 1.0 - 0.0005;
    expect(m.ic(1), 0);
    m.mt2 = 1.0 - 0.01;
    expect(m.ic(1), greaterThan(0));
  });

  test('applyState / applyAdcs / applyRGate', () {
    final m = DeviceMirror();
    m.applyState(parseState(synth(0x86, (d) => f32(d, 19, 618.5))));
    expect(m.rMt2, closeTo(618.5, 0.01));
    m.applyState(parseState(synth(0x86, (d) => f32(d, 19, 0))));
    expect(m.rMt2, closeTo(618.5, 0.01), reason: 'null keeps previous');
    m.applyAdcsResponse(
        synth(0x83, (d) {
          floats(d, 5, [1.5, 0, 12, 5, 2.5]);
          floats(d, 25, [1, 2, 3, 4, 5, 6, 7, 8]);
        }),
        direct: true);
    expect(m.batt, 1.5);
    expect(m.blue, 8);
    m.applyRGate(null);
    expect(m.rGate, 1e7);
    m.applyRGate(470000);
    expect(m.rGate, 470000);
  });
}
