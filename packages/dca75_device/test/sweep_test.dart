import 'dart:typed_data';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:test/test.dart';

import 'helpers.dart';

Future<SweepCollector> runSweep(SweepEngine e, SweepParams p,
    {IdentifyResult? last, CancelToken? cancel}) async {
  final col = SweepCollector(p);
  await for (final ev in e.run(p, last: last, cancel: cancel)) {
    col.add(ev);
  }
  return col;
}

void main() {
  late ScriptedDca dca;
  late DcaClient client;
  late SweepEngine engine;

  setUp(() async {
    dca = ScriptedDca();
    await dca.transport.open((await dca.transport.listDevices()).single);
    client = DcaClient(dca.transport, sleep: noSleep);
    engine = SweepEngine(client);
  });
  tearDown(() => dca.transport.dispose());

  group('defaults', () {
    test('BJT hFE drives Ib ranges', () {
      final r = decodeFrame(bjtFrame(hfe: 200));
      final ic = defaultsFor(SweepKind.icvce, r) as IcVceParams;
      expect(ic.ibMinUa, 10);
      expect(ic.ibMaxUa, 50);
      final h = defaultsFor(SweepKind.hfeic, r) as HfeIcParams;
      expect(h.ibMinUa, 1.0);
      expect(h.ibMaxUa, 50);
    });
    test('JFET Vgs(off) drives Vgs range', () {
      final r = decodeFrame(jfetFrame(vgsOff: -2.4));
      expect((defaultsFor(SweepKind.idvds, r) as IdVdsParams).vgsMin,
          closeTo(-2.4, 1e-6));
      expect((defaultsFor(SweepKind.idvgs, r) as IdVgsParams).vgsMin,
          closeTo(-2.4, 1e-6));
    });
    test('diode identify sets PN I-V anode/cathode from the pinout', () {
      // cfg 4: gate = red (anode), MT1 = green (cathode)
      final r = decodeFrame(diodeFrame(cfg: 4));
      final p = defaultsFor(SweepKind.pniv, r) as PnIvParams;
      expect(p.anode, Lead.red);
      expect(p.cathode, Lead.green);
      expect(p.forward, isTrue);
      // cfg 5: gate = green, MT1 = blue
      final q = defaultsFor(SweepKind.pniv, decodeFrame(diodeFrame(cfg: 5)))
          as PnIvParams;
      expect(q.anode, Lead.green);
      expect(q.cathode, Lead.blue);
      // a BJT result leaves the plain defaults
      expect(
          (defaultsFor(SweepKind.pniv, decodeFrame(bjtFrame())) as PnIvParams)
              .anode,
          Lead.red);
    });

    test('no result gives plain defaults; canRun gates by type', () {
      expect(defaultsFor(SweepKind.icvce, null), isA<IcVceParams>());
      expect(SweepKind.icvce.canRun(null), isFalse);
      expect(SweepKind.icvce.canRun(decodeFrame(bjtFrame())), isTrue);
      expect(SweepKind.idvds.canRun(decodeFrame(bjtFrame())), isFalse);
      expect(SweepKind.idvds.canRun(decodeFrame(jfetFrame())), isTrue);
      expect(SweepKind.pniv.canRun(null), isTrue);
    });
    test('params JSON round trip', () {
      for (final p in [
        const IcVceParams(vcMax: 6, traces: 3),
        const HfeIcParams(vce: 2),
        const IdVdsParams(vgsMin: -1.5),
        const IdVgsParams(points: 11),
        const PnIvParams(
            anode: Lead.blue,
            cathode: Lead.red,
            thirdLead: ThirdLead.lowToAnode,
            forward: false),
      ]) {
        expect(SweepParams.fromJson(p.toJson()).toJson(), p.toJson());
      }
    });
  });

  test('icvce: exact opcode sequence for 1 trace x 3 points', () async {
    final last = decodeFrame(bjtFrame(cfg: 1));
    final col = await runSweep(
        engine,
        const IcVceParams(
            traces: 1, points: 3, ibMaxUa: 10, ibMinUa: 2, vcMin: 0, vcMax: 2),
        last: last);
    final ops = dca.transport.sentOpcodes;
    const point = [0x8F, 0x8B, 0x94, 0x94, 0x83];
    expect(ops, [
      0x93, 0x8D, // mode analog, leads safe
      0x8E, // rgate walk stops at 470k (< 1.02 MΩ)
      0x8A, 0x90, 0x92, // trnPowerOn
      0x8F, 0x8B, 0x94, // set Vc, boost wait, gate current
      ...point, ...point, ...point,
      0x8D, 0x93, // leads safe, mode none
    ]);
    // frame details
    final boost = dca.transport.sentFor(Opcode.boost).single;
    expect(Frame(Opcode.boost).f32(2), 0); // sanity of helper
    expect(ByteData.sublistView(boost).getFloat32(2, Endian.little),
        closeTo(12.5, 1e-6));
    final cc = dca.transport.sentFor(Opcode.ccGate).first;
    expect(ByteData.sublistView(cc).getFloat32(3, Endian.little),
        closeTo(0.01, 1e-9));
    expect(cc[2], CxMode.on.code);
    final oneShot = dca.transport.sentFor(Opcode.ccGate)[1];
    expect(oneShot[2], CxMode.oneShotBurst.code);
    expect(ByteData.sublistView(oneShot).getUint16(7, Endian.little), 200);
    // collected data
    expect(col.traces.length, 1);
    expect(col.traces[0].label, 'Ib=10.0 µA');
    expect(col.traces[0].points.length, 3);
    expect(col.traces[0].points[0].x, closeTo(3.0, 1e-9)); // green - red
    expect(
        col.traces[0].points[0].y, closeTo(2.0, 1e-6)); // (6.5-5.26)*1000/620
    expect(col.progress, 100);
    expect(col.toCsv().split('\n').first, 'trace,x,y');
  });

  test('icvce: PNP config flips gate current sign and DAC layout', () async {
    await runSweep(engine, const IcVceParams(traces: 1, points: 1, ibMaxUa: 10),
        last: decodeFrame(bjtFrame(cfg: 7)));
    final cc = dca.transport.sentFor(Opcode.ccGate).first;
    expect(ByteData.sublistView(cc).getFloat32(3, Endian.little),
        closeTo(-0.01, 1e-9));
    final all = dca.transport.sentFor(Opcode.allVolts).single;
    final d = ByteData.sublistView(all);
    expect(d.getFloat32(2, Endian.little), closeTo(12.5, 1e-6));
    expect(d.getFloat32(6, Endian.little), closeTo(0.5, 1e-6));
    final mp = dca.transport.sentFor(Opcode.matrixPlus).single;
    expect(mp[2], 1, reason: 'cfg 7 -> 1 on the transistor path');
  });

  test('icvce: current over 12 mA ends the trace', () async {
    dca.adcAlways = [0.5, 0.5, 0.5, 12.5, 2.0, 1, 4, 1.65]; // ic ≈ 16.9 mA
    final col = await runSweep(engine, const IcVceParams(traces: 2, points: 5),
        last: decodeFrame(bjtFrame()));
    expect(col.traces.length, 2);
    expect(col.pointCount, 0);
    expect(dca.transport.sentOpcodes.last, 0x93);
  });

  test('icvce: CC one-shot fault stops the trace and turns the gate off',
      () async {
    dca.ccStatus = 0x48;
    final col = await runSweep(engine, const IcVceParams(traces: 1, points: 5),
        last: decodeFrame(bjtFrame()));
    expect(col.pointCount, 0);
    final offs = dca.transport
        .sentFor(Opcode.ccGate)
        .where((b) => b[2] == CxMode.off.code);
    expect(offs.length, 1);
  });

  test('cancel is cooperative and still ends in leads-safe / mode none',
      () async {
    final tok = CancelToken();
    var n = 0;
    final prev = dca.transport.handler;
    dca.transport.handler = (out) {
      if (++n == 12) tok.cancel();
      return prev!(out);
    };
    final col = await runSweep(engine, const IcVceParams(traces: 3, points: 50),
        last: decodeFrame(bjtFrame()), cancel: tok);
    expect(col.pointCount, lessThan(5));
    final ops = dca.transport.sentOpcodes;
    expect(ops.sublist(ops.length - 2), [0x8D, 0x93]);
  });

  test('transport error mid-sweep triggers safe shutdown then rethrows',
      () async {
    final prev = dca.transport.handler;
    dca.transport.handler =
        (out) => out[0] == 0x83 ? (Uint8List(64)..[0] = 0x01) : prev!(out);
    await expectLater(
        runSweep(engine, const IcVceParams(traces: 1, points: 2),
            last: decodeFrame(bjtFrame())),
        throwsA(isA<TransportException>()));
    final ops = dca.transport.sentOpcodes;
    expect(ops.sublist(ops.length - 4), [0x8D, 0x94, 0x95, 0x93]);
  });

  test('needs a matching identify result', () async {
    await expectLater(
        runSweep(engine, const IcVceParams()), throwsArgumentError);
    await expectLater(
        runSweep(engine, const IdVdsParams(), last: decodeFrame(bjtFrame())),
        throwsArgumentError);
    expect(dca.transport.sent, isEmpty);
  });

  test('hfeic: servo converges immediately when Vce matches, one point per Ib',
      () async {
    // vce(cfg 1) = green - red = 3.0; target 3.0 -> okPoint on first try.
    // setGate 3.0 / gate 2.18 so the measured Ib is non-zero.
    dca.adcAlways = [3.0, 2.18, 0.5, 6.5, 5.26, 1.0, 4.0, 1.65];
    final col = await runSweep(engine,
        const HfeIcParams(vce: 3.0, points: 3, ibMinUa: 10, ibMaxUa: 30),
        last: decodeFrame(bjtFrame(cfg: 1)));
    expect(col.traces.single.label, 'Vce=3.00 V');
    expect(col.traces.single.points.length, 3);
    // hFE = (ic - icZero)/ib with identical ADC values -> ic == icZero -> 0
    expect(col.traces.single.points.first.y, 0);
    expect(col.traces.single.points.first.x, closeTo(2.0, 1e-6));
    // leakage floor step: RGATE 470k, VOLTS gate, ADCS burst 24, RGATE restore
    final adcs = dca.transport.sentFor(Opcode.adcs).where((b) => b[4] == 24);
    expect(adcs.length, 3);
  });

  test('hfeic: no convergence ends the sweep', () async {
    final col = await runSweep(engine, const HfeIcParams(vce: 9.0, points: 5),
        last: decodeFrame(bjtFrame(cfg: 1)));
    expect(col.traces.single.points, isEmpty);
    expect(dca.transport.sentOpcodes.last, 0x93);
  });

  test('idvds: per-trace power-on and CV gate on every point', () async {
    final col = await runSweep(
        engine,
        const IdVdsParams(
            traces: 2, points: 2, vdsMax: 6, vgsMin: -2, vgsMax: 0),
        last: decodeFrame(jfetFrame(cfg: 5)));
    expect(col.traces.map((t) => t.label), ['Vgs=-2.00 V', 'Vgs=0.00 V']);
    expect(col.pointCount, 4);
    expect(dca.transport.sentFor(Opcode.rGate).single[2], RGateIdx.r8k2.code);
    final cv = dca.transport.sentFor(Opcode.cvGate);
    final ons = cv.where((b) => b[2] == CxMode.on.code).length;
    expect(ons, 2 + 4, reason: 'one per trace + one per point');
    final mp = dca.transport.sentFor(Opcode.matrixPlus);
    expect(mp.every((b) => b[2] == 5 && b[3] == 7), isTrue,
        reason: 'raw cfg on FET path');
  });

  test('idvgs: converges when measured Vds equals target', () async {
    // vce(cfg 5) = red - blue = 1.0 - 1.65 = -0.65 → never equals 5 → bad after 64 iters.
    final none = await runSweep(engine, const IdVgsParams(vds: 5, points: 3),
        last: decodeFrame(jfetFrame(cfg: 5)));
    expect(none.traces.single.points, isEmpty);

    // Make the measurement equal the target exactly (float32-exact values):
    // red - blue = 5.5 - 0.5 = 5 -> immediate convergence.
    dca.adcAlways = [0.5, 0.5, 0.5, 6.5, 5.26, 5.5, 4.0, 0.5];
    dca.transport.clearSent();
    final col = await runSweep(
        engine, const IdVgsParams(vds: 5, points: 3, vgsMin: -2, vgsMax: 0),
        last: decodeFrame(jfetFrame(cfg: 5)));
    expect(col.traces.single.points.length, 3);
    // x is vbe(cfg 5) = green - blue = 3.5
    expect(col.traces.single.points.first.x, closeTo(3.5, 1e-6));
    expect(
        dca.transport.sentFor(Opcode.adcs).where((b) => b[4] == 248).length, 3);
  });

  group('pniv', () {
    test('forward red→green: cfg 3, drives MT2/MT1/none, no bridge', () async {
      final col = await runSweep(engine,
          const PnIvParams(points: 2, anode: Lead.red, cathode: Lead.green));
      final m = dca.transport.sentFor(Opcode.matrixRgb).single;
      expect(
          m.sublist(2, 5), [Drive.mt2.code, Drive.mt1.code, Drive.none.code]);
      expect(dca.transport.sentFor(Opcode.bridgeGate), isEmpty);
      expect(
          dca.transport.sentFor(Opcode.rGate).single[2], RGateIdx.r470k.code);
      final boost = dca.transport.sentFor(Opcode.boost).single;
      expect(ByteData.sublistView(boost).getFloat32(2, Endian.little),
          closeTo(5.5, 1e-6));
      expect(col.traces.single.label, 'Red→Green');
      expect(col.traces.single.points.length, 2);
      // x = vce(cfg 3) = red - green = -3.0 with the default ADC values
      expect(col.traces.single.points.first.x, closeTo(-3.0, 1e-9));
      final vs = dca.transport.sentFor(Opcode.volts);
      expect(vs.length, 2);
      expect(ByteData.sublistView(vs.last).getFloat32(2, Endian.little),
          closeTo(5.5, 1e-6));
      expect(vs.last[6], Dac.mt2.code);
    });

    test('reverse swaps drives and config', () async {
      final col = await runSweep(
          engine,
          const PnIvParams(
              points: 1, anode: Lead.red, cathode: Lead.green, forward: false));
      final m = dca.transport.sentFor(Opcode.matrixRgb).single;
      expect(
          m.sublist(2, 5), [Drive.mt1.code, Drive.mt2.code, Drive.none.code]);
      expect(col.traces.single.label, 'Green→Red (rev)');
      // cfg = revM1M2[3] = 1 -> vce = green - red = 3.0
      expect(col.traces.single.points.single.x, closeTo(3.0, 1e-9));
    });

    test('third lead options', () async {
      await runSweep(
          engine, const PnIvParams(points: 1, thirdLead: ThirdLead.lowToAnode));
      var m = dca.transport.sentFor(Opcode.matrixRgb).single;
      expect(m[4], Drive.gate.code);
      expect(dca.transport.sentFor(Opcode.bridgeGate).single[2], Lead.red.code);

      dca.transport.clearSent();
      await runSweep(engine,
          const PnIvParams(points: 1, thirdLead: ThirdLead.lowToCathode));
      expect(
          dca.transport.sentFor(Opcode.bridgeGate).single[2], Lead.green.code);

      dca.transport.clearSent();
      await runSweep(
          engine, const PnIvParams(points: 1, thirdLead: ThirdLead.r470kToGnd));
      m = dca.transport.sentFor(Opcode.matrixRgb).single;
      expect(m[4], Drive.gate.code);
      expect(dca.transport.sentFor(Opcode.bridgeGate), isEmpty);
      final gateVolts = dca.transport
          .sentFor(Opcode.volts)
          .where((b) => b[6] == Dac.gate.code);
      expect(gateVolts.length, 1);
      expect(
          ByteData.sublistView(gateVolts.single).getFloat32(2, Endian.little),
          0);

      dca.transport.clearSent();
      await runSweep(
          engine, const PnIvParams(points: 1, thirdLead: ThirdLead.r470kToVs));
      final vsGate = dca.transport
          .sentFor(Opcode.volts)
          .where((b) => b[6] == Dac.gate.code);
      expect(ByteData.sublistView(vsGate.single).getFloat32(2, Endian.little),
          closeTo(0.5, 1e-6));
    });

    test('same lead for anode and cathode is rejected before any I/O',
        () async {
      await expectLater(
          runSweep(
              engine, const PnIvParams(anode: Lead.red, cathode: Lead.red)),
          throwsArgumentError);
      expect(dca.transport.sent, isEmpty);
    });
  });
}
