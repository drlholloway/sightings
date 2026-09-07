import 'dart:typed_data';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:test/test.dart';

/// Model: a diode with constant reverse leakage [leakA], plus a 4 mV offset
/// between the SetGate and Gate ADC channels that the baseline must cancel.
/// Anode red on MT1 (0.5 V), cathode green on the gate through 470 kΩ.
class LeakyDiode {
  LeakyDiode({this.leakA = 50e-9, this.offsetV = 0.004}) {
    dca = ScriptedDca();
    final base = dca.transport.handler!;
    dca.transport.handler = (out) {
      if (out[0] == 0x8F && out[6] == Dac.gate.code) {
        setGate = ByteData.sublistView(out).getFloat32(2, Endian.little);
      }
      if (out[0] == 0x83) {
        final vr = setGate - 0.5;
        final i = vr > 0 ? leakA : 0.0;
        final gate = setGate - i * 470000 - offsetV; // lead-side voltage
        dca.adcAlways = [setGate, gate, 0.5, 0.5, 0.5, 0.5, gate, 0.0];
      }
      return base(out);
    };
  }
  late final ScriptedDca dca;
  final double leakA, offsetV;
  double setGate = 0.5;
}

void main() {
  test(
      'reverse leakage sweep reads nA through the gate path with baseline cancelled',
      () async {
    final m = LeakyDiode(leakA: 50e-9);
    final t = m.dca.transport;
    await t.open((await t.listDevices()).single);
    final client = DcaClient(t, sleep: noSleep);
    final pts = await LeakageMeasurement(client)
        .sweep(Lead.red, Lead.green, [0, 5, 10]).toList();
    expect(pts.length, 3);
    expect(pts[0].irAmps.abs(), lessThan(2e-9),
        reason: 'baseline cancels the 4 mV offset');
    expect(pts[1].irAmps, closeTo(50e-9, 2e-9));
    expect(pts[2].irAmps, closeTo(50e-9, 2e-9));
    // the servo raises the DAC so the junction sees the requested Vr
    expect(pts[2].vrMeasured, closeTo(10, 0.05));
    // routing: green (cathode) → gate, red (anode) → MT1, blue open; 470k selected
    final m1 = t.sentFor(Opcode.matrixRgb).single;
    expect(
        m1.sublist(2, 5), [Drive.mt1.code, Drive.gate.code, Drive.none.code]);
    expect(t.sentFor(Opcode.rGate).single[2], RGateIdx.r470k.code);
    final ops = t.sentOpcodes;
    expect(ops.sublist(ops.length - 2), [0x8D, 0x93]);
    await t.dispose();
  });

  test('measurePoints keys and the engine sweep kind', () async {
    final m = LeakyDiode(leakA: 1e-6);
    final t = m.dca.transport;
    await t.open((await t.listDevices()).single);
    final client = DcaClient(t, sleep: noSleep);
    final p =
        await LeakageMeasurement(client).measurePoints(Lead.red, Lead.green);
    expect(
        p.keys,
        containsAll(
            ['leak_ir_5v', 'leak_vr_5v', 'leak_ir_10v', 'leak_vr_10v']));
    expect(p['leak_ir_10v']!.$1, closeTo(1e-6, 5e-9));
    expect(p['leak_ir_10v']!.$2, 'A');
    // 1 µA drops 0.47 V across 470 kΩ; the servo compensates (DAC ≈ 10.97 V)
    expect(p['leak_vr_10v']!.$1, closeTo(10, 0.05));

    t.clearSent();
    final col = SweepCollector(const RevLeakParams(
        vMax: 10, points: 3, anode: Lead.red, cathode: Lead.green));
    await for (final ev in SweepEngine(client).run(col.params)) {
      col.add(ev);
    }
    expect(col.traces.single.points.length, 3);
    expect(col.traces.single.points.last.y, closeTo(1000, 5), reason: 'nA');
    expect(col.progress, 100);
    await t.dispose();
  });

  test('servo stops at the 12.5 V DAC ceiling when leakage is too high',
      () async {
    final m = LeakyDiode(leakA: 10e-6); // 4.7 V drop: 10 V needs a 15.2 V DAC
    final t = m.dca.transport;
    await t.open((await t.listDevices()).single);
    final p = await LeakageMeasurement(DcaClient(t, sleep: noSleep))
        .measurePoints(Lead.red, Lead.green);
    expect(p['leak_vr_5v']!.$1, closeTo(5, 0.05),
        reason: '5 V is reachable (DAC 9.7 V)');
    expect(p['leak_vr_10v']!.$1, lessThan(9.0),
        reason: 'reports what the junction actually saw');
    expect(p['leak_vr_10v']!.$1, closeTo(12.5 - 0.5 - 4.7 - 0.004, 0.05));
    await t.dispose();
  });

  test('defaults take the leads from a diode identify; same-lead rejected',
      () async {
    final b = Uint8List(64)..[0] = 0x85;
    b[2] = 6;
    b[3] = 1;
    b[5] = 1;
    b[6] = 5; // cfg 5: gate=green (A), MT1=blue (K)
    final r = decodeResult(Response(b));
    final p = defaultsFor(SweepKind.revleak, r) as RevLeakParams;
    expect(p.anode, Lead.green);
    expect(p.cathode, Lead.blue);
    expect(SweepParams.fromJson(p.toJson()).toJson(), p.toJson());
    final m = LeakyDiode();
    final t = m.dca.transport;
    await t.open((await t.listDevices()).single);
    await expectLater(
        LeakageMeasurement(DcaClient(t, sleep: noSleep))
            .sweep(Lead.red, Lead.red, [5]).toList(),
        throwsArgumentError);
    expect(t.sent, isEmpty);
    await t.dispose();
  });
}
