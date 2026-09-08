import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

Future<SweepCollector> run(
    DcaClient c, SweepParams p, IdentifyResult last) async {
  final col = SweepCollector(p);
  await for (final e in SweepEngine(c).run(p, last: last)) {
    col.add(e);
  }
  return col;
}

void main() {
  late DemoTransport t;
  late DcaClient client;

  setUp(() async {
    t = DemoTransport(unit: DemoUnit(testPolls: 2));
    await t.open((await t.listDevices()).single);
    client = DcaClient(t, sleep: noSleep);
    await client.getState(DeviceState.idle); // as the app does: sets R(MT2)
  });
  tearDown(() => t.dispose());

  test('controller connects and identifies each demo part; unit button works',
      () async {
    final ctl = DeviceController(t, sleep: noSleep, autoPoll: false);
    await ctl.connect();
    expect(ctl.status.identity!.serial, 'DEMO01');
    expect(ctl.status.rails!.rMt2, closeTo(559.5, 0.01));
    final names = <String>[];
    for (var i = 0; i < demoParts.length; i++) {
      t.unit.selectPart(i);
      final r = await ctl.identify();
      names.add(r.name);
    }
    expect(names,
        ['NPN BJT', 'PNP BJT', 'N-ch JFET', 'PN junction', 'PN junction']);
    final events = <IdentifyEvent>[];
    ctl.identifyEvents.listen(events.add);
    t.unit.selectPart(0);
    t.unit.pressButton();
    await ctl.pollOnce();
    expect(events.single.source, ReadingSource.unitButton);
    expect(events.single.result.hfe, closeTo(405.5, 0.1));
    await ctl.dispose();
  });

  test('2N5088: Ic/Vce family rises with Ib and saturates; hFE curve near 405',
      () async {
    t.unit.selectPart(0);
    final last = demoParts[0].identify;
    final fam = await run(
        client,
        const IcVceParams(traces: 3, points: 11, ibMinUa: 5, ibMaxUa: 15),
        last);
    expect(fam.traces.length, 3);
    // top trace (Ib 15 µA): Ic ≈ 405 × 15 µA ≈ 6 mA at mid Vce, flat-ish
    final top = fam.traces.first.points;
    expect(top.length, 11);
    expect(top.last.y, closeTo(6.1, 1.0));
    expect(top.last.y, greaterThan(top[3].y * 0.95));
    expect(top[1].y, lessThan(top.last.y),
        reason: 'saturation region at low Vce');
    final h = await run(client,
        const HfeIcParams(vce: 5, points: 5, ibMinUa: 5, ibMaxUa: 20), last);
    expect(h.traces.single.points.length, 5);
    for (final pt in h.traces.single.points) {
      expect(pt.y, closeTo(405 * (1 + 5 / 100), 25));
    }
  });

  test('2N5088 and MP40A: DCA55-equivalent converges with leakage subtracted',
      () async {
    t.unit.selectPart(0);
    final a = await Dca55Measurement(client).run(4, hfeEstimate: 405);
    expect(a.converged, isTrue);
    expect(a.icMa, closeTo(2.5, 0.03));
    expect(a.hfe, closeTo(405 * 1.025, 15));
    t.unit.selectPart(1);
    final b = await Dca55Measurement(client).run(11, hfeEstimate: 29);
    expect(b.converged, isTrue);
    expect(b.icLeakMa, closeTo(0.031, 0.005));
    expect(b.hfe, closeTo(29 * 1.04, 3));
    expect(b.vbe, closeTo(0.22, 0.01));
  });

  test('J201: transfer curve reaches Idss at Vgs=0 and zero at pinch-off',
      () async {
    t.unit.selectPart(2);
    final last = demoParts[2].identify;
    final tr = await run(client,
        const IdVgsParams(vds: 5, points: 9, vgsMin: -0.734, vgsMax: 0), last);
    final pts = tr.traces.single.points;
    expect(pts.length, 9);
    expect(pts.last.y, closeTo(0.484 * 1.1, 0.06));
    expect(pts.first.y, lessThan(0.01));
    final fam = await run(
        client,
        const IdVdsParams(
            traces: 2, points: 6, vdsMax: 6, vgsMin: -0.5, vgsMax: 0),
        last);
    expect(fam.pointCount, 12);
  });

  test('diodes: forward knee and reverse leakage', () async {
    t.unit.selectPart(3);
    final siAk = diodeLeadsOf(demoParts[3].identify)!;
    final si = await run(
        client,
        PnIvParams(points: 11, vMax: 3, anode: siAk.$1, cathode: siAk.$2),
        demoParts[3].identify);
    final pts = si.traces.single.points;
    expect(pts.first.y, lessThan(0.001));
    expect(pts.last.y, greaterThan(3.5)); // (3 - 0.7) / 560 Ω ≈ 4 mA
    expect(pts.last.x, closeTo(0.7, 0.08));
    final leak =
        await LeakageMeasurement(client).measurePoints(siAk.$1, siAk.$2);
    expect(leak['leak_ir_5v']!.$1, closeTo(5e-9 * 1.75, 3e-9));
    t.unit.selectPart(4);
    final ge = demoParts[4].identify;
    final ak = diodeLeadsOf(ge)!;
    final geLeak = await LeakageMeasurement(client).measurePoints(ak.$1, ak.$2);
    expect(geLeak['leak_ir_5v']!.$1, closeTo(3e-6 * 1.75, 1e-6));
    expect(geLeak['leak_vr_5v']!.$1, closeTo(5, 0.1),
        reason: 'servo compensates the 470k drop');
    final rev = await run(
        client,
        const RevLeakParams(
            vMax: 8, points: 5, anode: Lead.red, cathode: Lead.green),
        demoParts[3].identify);
    expect(rev.traces.single.points.length, 5);
  });

  test('MP40A: Icbo through the gate path', () async {
    t.unit.selectPart(1);
    final cb = bjtCbJunction(demoParts[1].identify)!;
    final p = await LeakageMeasurement(client)
        .measurePoints(cb.$1, cb.$2, prefix: 'icbo', voltPrefix: 'vcbo');
    expect(p['leak_icbo_5v']!.$1, closeTo(2.9e-6 * 1.75, 1.5e-6));
  });
}
