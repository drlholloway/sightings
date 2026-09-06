import 'dart:io';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

/// Real frames captured from hardware. Lines starting with `#` are comments.
Response golden(String name) {
  final text = File('test/golden/$name.hex').readAsStringSync();
  final hex =
      text.split('\n').where((l) => !l.trimLeft().startsWith('#')).join(' ');
  return Response.fromHex(hex);
}

void main() {
  test('2N5088 (NPN silicon BJT, config 4)', () {
    final r = decodeResult(golden('bjt-2n5088'));
    expect(r.type, ComponentType.bjt);
    expect(r.name, 'NPN BJT');
    expect(r.flagLabels, ['NPN', 'SILICON']);
    expect(r.config, 4);
    expect(r.pins, [
      const PinAssignment(lead: Lead.green, terminal: 'E'),
      const PinAssignment(lead: Lead.red, terminal: 'B'),
      const PinAssignment(lead: Lead.blue, terminal: 'C'),
    ]);
    expect(r.hfe, closeTo(404.0, 0.01));
    expect(r.param('ic_test')!.value, closeTo(4.997e-3, 1e-5));
    expect(r.param('ic_leak')!.display, '4.92 µA');
    expect(r.param('vbe_5ma')!.display, '769 mV');
    expect(r.param('vbe_5ma')!.label, 'Vbe @ 5.00 mA');
    expect(r.param('vbe_1ma')!.display, '705 mV');
    expect(r.param('vbe_1ma')!.label, 'Vbe @ 1.00 mA');
    expect(r.param('vce_sat')!.display, '22.8 mV');
    expect(r.param('ic_sat')!.display, '5.01 mA');
    expect(r.param('ib_sat')!.display, '1.00 mA');
    expect(r.param('r_shunt'), isNull);
    expect(r.headline['hfe'], closeTo(404.0, 0.01));
  });

  test('J201 (N-channel JFET, config 1)', () {
    final r = decodeResult(golden('jfet-j201'));
    expect(r.type, ComponentType.jfet);
    expect(r.name, 'N-ch JFET');
    expect(r.flagLabels, ['N-CHANNEL', 'SYMMETRIC D/S']);
    expect(r.config, 1);
    expect(r.pins, [
      const PinAssignment(lead: Lead.red, terminal: 'S'),
      const PinAssignment(lead: Lead.blue, terminal: 'G'),
      const PinAssignment(lead: Lead.green, terminal: 'D'),
    ]);
    expect(r.vgsOff, closeTo(-0.734, 1e-3));
    expect(r.param('idss')!.display, '484 µA');
    expect(r.param('gfs')!.display, '1.56 mS');
    expect(r.param('id_off')!.display, '4.80 µA');
    expect(r.param('rds')!.display, '673 Ω');
    expect(r.headline['gfs'], closeTo(1.561e-3, 1e-5));
  });
}
