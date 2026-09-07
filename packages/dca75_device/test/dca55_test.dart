import 'dart:typed_data';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:test/test.dart';

/// A crude NPN model in config 1 wrapped around [ScriptedDca]: Ic = hFE·Ib,
/// the measured Vce equals the requested collector voltage, Vbe is fixed.
class BjtModel {
  BjtModel({this.hfe = 200, this.vbe = 0.66, this.leakMa = 0.002}) {
    dca = ScriptedDca();
    final base = dca.transport.handler!;
    dca.transport.handler = (out) {
      switch (out[0]) {
        case 0x8F: // VOLTS: MT2 channel sets the collector voltage (0.5 V offset);
          // a gate-channel write hands the base back to the DAC (no forced Ib).
          if (out[6] == Dac.mt2.code) {
            vc = ByteData.sublistView(out).getFloat32(2, Endian.little) - 0.5;
          } else if (out[6] == Dac.gate.code) {
            gateOn = false;
          }
        case 0x94: // CCGATE ON sets Ib (mA)
          if (out[2] == CxMode.on.code) {
            ib = ByteData.sublistView(out).getFloat32(3, Endian.little).abs();
            gateOn = true;
          } else if (out[2] == CxMode.off.code) {
            gateOn = false;
          }
        case 0x8E: // RGATE
          rGate = switch (out[2]) {
            1 => 1000.0,
            2 => 8200.0,
            3 => 68000.0,
            _ => 470000.0
          };
      }
      if (out[0] == 0x83) {
        // ADCS: derive the mirror values from the model.
        final ic = gateOn ? (hfe * ib + leakMa) : leakMa; // mA
        final drop =
            ic * 620 / 1000; // volts across R(MT2) (mirror default 620 Ω)
        final ibDrop = ib * rGate / 1000; // setGate - gate
        dca.adcAlways = [
          3.0,
          3.0 - ibDrop,
          0.5,
          0.5 + vc + drop,
          0.5 + vc,
          1.0,
          1.0 + vc,
          1.0 + vbe
        ];
      }
      return base(out);
    };
  }

  late final ScriptedDca dca;
  final double hfe, vbe, leakMa;
  double vc = 0, ib = 0, rGate = 470000;
  bool gateOn = false;
}

void main() {
  test('converges on Ic 2.50 mA at Vce 2.5 V and reports DCA55-style hFE',
      () async {
    final m = BjtModel(hfe: 200);
    final t = m.dca.transport;
    await t.open((await t.listDevices()).single);
    final client = DcaClient(t, sleep: noSleep);
    final r = await Dca55Measurement(client).run(1, hfeEstimate: 400);
    expect(r.converged, isTrue);
    expect(r.icMa, closeTo(2.5, 0.03));
    expect(r.vce, closeTo(2.5, 0.03));
    // hFE = (Ic − leakage) / Ib = 200 by construction
    expect(r.hfe, closeTo(200, 2));
    expect(r.vbeAtPoint, closeTo(0.66, 1e-6));
    expect(r.vbe, closeTo(0.66, 1e-6));
    expect(r.icLeakMa, closeTo(0.002, 1e-6));
    expect(r.iterations, lessThan(6),
        reason: 'proportional step from a 2x wrong guess');
    // ends safe
    final ops = t.sentOpcodes;
    expect(ops.sublist(ops.length - 2), [0x8D, 0x93]);
    final p = r.toParams();
    expect(p['hfe_dca55']!.$1, closeTo(200, 2));
    expect(p.keys.every((k) => k.endsWith('_dca55')), isTrue);
    await t.dispose();
  });

  test('gives up cleanly when Ic cannot reach the target', () async {
    final m = BjtModel(hfe: 0.0001); // no gain: Ic never reaches 2.5 mA
    final t = m.dca.transport;
    await t.open((await t.listDevices()).single);
    final client = DcaClient(t, sleep: noSleep);
    final r = await Dca55Measurement(client).run(1, hfeEstimate: 100);
    expect(r.converged, isFalse);
    expect(r.iterations, 12);
    expect(t.sentOpcodes.last, 0x93);
    await t.dispose();
  });

  test('rejects a bad config before any I/O', () async {
    final m = BjtModel();
    final t = m.dca.transport;
    await t.open((await t.listDevices()).single);
    await expectLater(Dca55Measurement(DcaClient(t, sleep: noSleep)).run(0),
        throwsArgumentError);
    expect(t.sent, isEmpty);
    await t.dispose();
  });
}
