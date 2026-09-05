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
}
