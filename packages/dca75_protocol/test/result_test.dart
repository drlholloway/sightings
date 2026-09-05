import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

import 'helpers.dart';

Response testFrame(
        int type, int cfg, int flags, void Function(ByteData d) fill) =>
    synth(0x85, (d) {
      d.setUint8(2, type);
      d.setUint8(3, cfg);
      d.setUint8(4, flags);
      fill(d);
    });

void main() {
  test('rejects non-TEST frames', () {
    expect(() => decodeResult(synth(0x86, (_) {})),
        throwsA(isA<ProtocolFormatException>()));
  });

  test('NPN silicon BJT', () {
    // IcLeak Vbe5 Vbe1 Ib5 Ib1 HFE Ic VceSat IcSat IbSat Rshunt Rinput
    final r = decodeResult(testFrame(
        1,
        3,
        bjtFlagNpn | bjtFlagSilicon,
        (d) => floats(d, 5,
            [0.001, 0.71, 0.65, 0.024, 0.005, 212.4, 5.0, 0.09, 10, 1, 0, 0])));
    expect(r.type, ComponentType.bjt);
    expect(r.name, 'NPN BJT');
    expect(r.flagLabels, ['NPN', 'SILICON']);
    expect(r.config, 3);
    expect(r.pins, [
      const PinAssignment(lead: Lead.green, terminal: 'E'),
      const PinAssignment(lead: Lead.blue, terminal: 'B'),
      const PinAssignment(lead: Lead.red, terminal: 'C'),
    ]);
    expect(r.hfe, closeTo(212.4, 1e-3));
    expect(r.param('hfe')!.display, '212.4');
    expect(r.param('vbe_5ma')!.display, '710 mV');
    expect(r.param('ib_5ma')!.value, closeTo(24e-6, 1e-12));
    expect(r.param('ib_5ma')!.display, '24.0 µA');
    expect(r.param('ic_leak')!.value, closeTo(1e-6, 1e-12));
    expect(r.param('r_shunt'), isNull, reason: 'Rshunt 0 is hidden');
    expect(r.param('r_input'), isNull, reason: 'only for digital');
    expect(
        r.headline.keys, containsAll(['hfe', 'ic_leak', 'vbe_5ma', 'vce_sat']));
    expect(r.raw.length, 64);
    expect(r.raw[2], 1);
  });

  test('PNP darlington digital with shunt', () {
    final r = decodeResult(testFrame(
        1,
        9,
        bjtFlagDarlington | bjtFlagDigital,
        (d) => floats(
            d, 5, [0, 1.2, 0.8, 3, 0.01, 8000, 5, 0.9, 10, 1, 10000, 47000])));
    expect(r.name, 'PNP Darlington');
    expect(r.flagLabels, ['PNP', 'DARLINGTON', 'DIGITAL']);
    expect(r.param('vi_on')!.display, '1.20 V');
    expect(r.param('vbe_5ma'), isNull);
    expect(r.param('r_shunt')!.display, '10.0 kΩ');
    expect(r.param('r_input')!.display, '47.0 kΩ');
    expect(r.headline.containsKey('vbe_5ma'), isFalse);
  });

  test('N-channel MOSFET with body diode', () {
    // Vgth IdOn IgOn IdOn2 VgOff IdOff gm VdsSat IdSat VgSat Rds Vsd
    final r = decodeResult(testFrame(
        2,
        2,
        fetFlagNChannel | fetFlagBodyDiode,
        (d) => floats(
            d, 5, [2.1, 10, 0, 0, 0, 0.0002, 0.35, 0.2, 10, 5, 1.8, 0.72])));
    expect(r.name, 'N-ch MOSFET');
    expect(r.flagLabels, ['N-CHANNEL', 'BODY DIODE']);
    expect(r.pins!.map((p) => p.terminal), ['S', 'G', 'D']);
    expect(r.param('vgs_th')!.display, '2.10 V');
    expect(r.param('gm')!.display, '350 mS');
    expect(r.param('vsd')!.display, '720 mV');
    expect(r.param('vds_sat')!.label, 'Vds(sat)');
    expect(r.headline['rds_on'], closeTo(1.8, 1e-6));
  });

  test('IGBT labels and depletion MOSFET name', () {
    final igbt = decodeResult(testFrame(
        3, 1, fetFlagNChannel, (d) => floats(d, 5, List.filled(12, 1))));
    expect(igbt.name, 'N-ch IGBT');
    expect(igbt.pins!.map((p) => p.terminal), ['E', 'G', 'C']);
    expect(igbt.param('vds_sat')!.label, 'Vce(sat)');
    final dep = decodeResult(testFrame(2, 1, fetFlagDepletion, (d) {}));
    expect(dep.name, 'P-ch depletion MOSFET');
  });

  test('N-channel JFET', () {
    // VgsOff IdOff VgsOn IdOn IdOn2 gfs Idzero Vgszero Vdszero VgsSat IgSat Rds IdRds
    final r = decodeResult(testFrame(
        8,
        5,
        jfetFlagNChannel | jfetFlagSymmetric,
        (d) => floats(
            d, 5, [-2.4, 0.0001, -0.5, 3, 0, 0.004, 5.2, 0, 5, 0, 0, 150, 1])));
    expect(r.name, 'N-ch JFET');
    expect(r.flagLabels, ['N-CHANNEL', 'SYMMETRIC D/S']);
    expect(r.vgsOff, closeTo(-2.4, 1e-6));
    expect(r.param('idss')!.display, '5.20 mA');
    expect(r.param('rds')!.display, '150 Ω');
    expect(r.headline['idss'], closeTo(5.2e-3, 1e-9));
  });

  test('SCR and TRIAC', () {
    final scr = decodeResult(testFrame(
        4, 1, 0, (d) => floats(d, 5, [0.001, 0, 5, 0.8, 0, 0, 0, 0, 1.1, 0])));
    expect(scr.name, 'Thyristor (SCR)');
    expect(scr.pins!.map((p) => p.terminal), ['K', 'G', 'A']);
    expect(scr.param('igt')!.display, '5.00 mA');
    expect(scr.param('vgt')!.display, '800 mV');
    expect(scr.param('v_on')!.display, '1.10 V');
    final triac =
        decodeResult(testFrame(5, 2, 0, (d) => floats(d, 5, [0.002, 1.3])));
    expect(triac.name, 'Triac');
    expect(triac.pins!.map((p) => p.terminal), ['MT1', 'G', 'MT2']);
    expect(triac.param('v_hold')!.display, '1.30 V');
  });

  test('single PN diode', () {
    final r = decodeResult(testFrame(6, 1, 0x12, (d) {
      d.setUint8(5, 1); // kind PN
      d.setUint8(6, 4); // cfg
      floats(d, 7, [0.62, 5, 0, 0.00001, 0, 0, 0]);
    }));
    expect(r.name, 'PN junction');
    expect(r.config, 4);
    expect(r.pins, [
      const PinAssignment(lead: Lead.red, terminal: 'A'),
      const PinAssignment(lead: Lead.green, terminal: 'K'),
    ]);
    expect(r.param('d1_vf')!.display, '620 mV');
    expect(r.param('d1_vz'), isNull);
    expect(r.flagLabels, ['pattern 0x12']);
    expect(r.headline['vf'], closeTo(0.62, 1e-6));
  });

  test('zener and two-junction network', () {
    final z = decodeResult(testFrame(6, 1, 0, (d) {
      d.setUint8(5, 4);
      d.setUint8(6, 1);
      floats(d, 7, [0.7, 5, 5.1, 0.001, 0, 0, 0]);
    }));
    expect(z.name, 'Zener');
    expect(z.param('d1_vz')!.display, '5.10 V');
    expect(z.headline['vz'], closeTo(5.1, 1e-6));

    final two = decodeResult(testFrame(6, 2, 0, (d) {
      d.setUint8(5, 2);
      d.setUint8(6, 1);
      floats(d, 7, [1.8, 5, 0, 0, 0, 0, 0]);
      d.setUint8(36, 3);
      floats(d, 37, [2.1, 5]);
    }));
    expect(two.name, '2 junctions');
    expect(two.param('d2_vf')!.display, '2.10 V');
    expect(two.param('d2_cfg')!.display, '3');
  });

  test('short circuit', () {
    final r = decodeResult(testFrame(7, 5, 0, (_) {}));
    expect(r.name, 'Short circuit');
    expect(r.param('shorted_mask')!.display, 'Red + Blue');
    expect(r.pins, isNull);
    expect(
        decodeResult(testFrame(7, 0, 0, (_) {})).param('shorted_mask')!.display,
        '—');
  });

  test('voltage regulator', () {
    final r = decodeResult(
        testFrame(9, 6, 0, (d) => floats(d, 5, [5.02, 5, 3.5, 1.7, 0.01])));
    expect(r.name, 'Voltage regulator');
    expect(r.pins!.map((p) => p.terminal), ['In', 'Out', 'Gnd']);
    expect(r.param('vout')!.display, '5.02 V');
    expect(r.param('iq')!.display, '3.50 mA');
    expect(r.headline['vout'], closeTo(5.02, 1e-6));
  });

  test('status results and nothing detected', () {
    expect(decodeResult(testFrame(10, 0, 0, (_) {})).name, 'Low battery');
    expect(decodeResult(testFrame(11, 0, 0, (_) {})).name, 'USB voltage fail');
    final none = decodeResult(testFrame(0, 0, 0, (_) {}));
    expect(none.name, 'No component detected');
    expect(none.type.isComponent, isFalse);
    expect(none.params, isEmpty);
  });

  test('rawHex matches reference layout', () {
    final r = decodeResult(testFrame(1, 1, 16, (_) {}));
    final lines = r.rawHex.split('\n');
    expect(lines.length, 4);
    expect(lines.first.startsWith('85 00 01 01 10 00'), isTrue);
  });
}
