import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('parseState (reference self-test vector)', () {
    final r = synth(0x86, (d) {
      d.setUint8(2, 2);
      u16(d, 3, 0x00A5);
      u16(d, 5, 0x0112);
      f32(d, 19, 618.5);
      const sn = 'ABC123';
      for (var i = 0; i < 6; i++) {
        u16(d, 7 + 2 * i, sn.codeUnitAt(i));
      }
    });
    final s = parseState(r);
    expect(s.state, DeviceState.tested);
    expect(s.hardwareRev, '00a5');
    expect(s.firmwareRev, '0112');
    expect(s.serial, 'ABC123');
    expect(s.rMt2, closeTo(618.5, 0.01));
  });

  test('parseState ignores insane rMt2', () {
    final r = synth(0x86, (d) => f32(d, 19, 2e6));
    expect(parseState(r).rMt2, isNull);
    final z = synth(0x86, (d) => f32(d, 19, 0));
    expect(parseState(z).rMt2, isNull);
  });

  test('parseState rejects wrong opcode', () {
    expect(() => parseState(synth(0x84, (_) {})),
        throwsA(isA<ProtocolFormatException>()));
  });

  test('parseCal', () {
    final r =
        synth(0x84, (d) => floats(d, 2, [1001, 8190, 68100, 470200, 619.2]));
    final c = parseCal(r);
    expect(c.r1k0, 1001);
    expect(c.r8k2, 8190);
    expect(c.r68k, 68100);
    expect(c.r470k, 470200);
    expect(c.rMt2, closeTo(619.2, 0.01));
  });

  test('parseAdcs with and without rails', () {
    final r = synth(0x83, (d) {
      floats(d, 5, [1.45, 1.2, 12.1, 5.0, 2.5]);
      floats(d, 25, [3.0, 2.4, 0.5, 6.5, 6.1, 1.1, 1.2, 1.3]);
    });
    final a = parseAdcs(r, direct: true);
    expect(a.rails!.batt, closeTo(1.45, 1e-6));
    expect(a.rails!.vRef, closeTo(2.5, 1e-6));
    expect(a.always.setGate, 3.0);
    expect(a.always.blue, closeTo(1.3, 1e-6));
    expect(parseAdcs(r, direct: false).rails, isNull);
  });

  test('boosted / rgate / cx status', () {
    expect(parseBoosted(synth(0x8B, (d) => d.setUint8(1, 1))), isTrue);
    expect(parseBoosted(synth(0x8B, (_) {})), isFalse);
    expect(parseRGate(synth(0x8E, (d) => f32(d, 3, 8200))), 8200);
    expect(parseRGate(synth(0x8E, (d) => f32(d, 3, -1))), isNull);
    expect(ccStatus(synth(0x94, (d) => d.setUint8(9, 0x04))), 0x04);
    expect(cvStatus(synth(0x95, (d) => d.setUint8(10, 0x48))), 0x48);
    expect(cxDone(0x04), isTrue);
    expect(cxFault(0x04), isFalse);
    expect(cxFault(0x08), isTrue);
    expect(cxDone(0), isFalse);
  });
}
