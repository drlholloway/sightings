import 'dart:convert';
import 'dart:typed_data';

import 'package:dca75_circuits/dca75_circuits.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

IdentifyResult bjt(
    {required bool npn,
    required bool germanium,
    double hfe = 100,
    double leakMa = 0}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 1;
  b[3] = 1;
  b[4] =
      (npn ? bjtFlagNpn : 0) | (germanium ? bjtFlagGermanium : bjtFlagSilicon);
  final f = [leakMa, 0.7, 0.65, 5, 1, hfe, 5.0, 0.1, 5, 1, 0, 0];
  for (var i = 0; i < f.length; i++) {
    d.setFloat32(5 + 4 * i, f[i].toDouble(), Endian.little);
  }
  return decodeResult(Response(b));
}

IdentifyResult diode(double vf, {int kind = 1}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 6;
  b[3] = 1;
  b[5] = kind;
  b[6] = 4;
  d.setFloat32(7, vf, Endian.little);
  d.setFloat32(11, 5, Endian.little);
  return decodeResult(Response(b));
}

Map<String, double> vals(IdentifyResult r,
        [Map<String, double> extra = const {}]) =>
    {...r.headline, ...extra};

void main() {
  test('profiles round-trip through JSON and have unique ids', () {
    final ids = defaultCircuits.map((c) => c.id).toSet();
    expect(ids.length, defaultCircuits.length);
    for (final c in defaultCircuits) {
      final back = CircuitProfile.fromJson(
          jsonDecode(jsonEncode(c.toJson())) as Map<String, Object?>);
      expect(jsonEncode(back.toJson()), jsonEncode(c.toJson()));
      expect(c.source, isNotNull, reason: '${c.id} must cite its numbers');
    }
  });

  test(
      'MP40A-like germanium PNP (hFE 25 DCA55, Iceo 31 µA): fits nothing at hFE 25, Q1 fits at 78',
      () {
    final r = bjt(npn: false, germanium: true, hfe: 29, leakMa: 0.031);
    final low = evaluate(r, vals(r, {'hfe_dca55': 25}), defaultCircuits);
    expect(low.where((f) => f.fits), isEmpty);
    final ff = low.firstWhere(
        (f) => f.circuit.id == 'fuzz_face_ge' && f.position.id == 'q1');
    expect(ff.typeMatches, isTrue);
    expect(ff.firstFailure, contains('hFE (DCA55) 25.0 below 70'));

    final good = evaluate(r, vals(r, {'hfe_dca55': 78}), defaultCircuits);
    final fits = good
        .where((f) => f.fits)
        .map((f) => '${f.circuit.id}/${f.position.id}')
        .toList();
    expect(
        fits,
        containsAll([
          'fuzz_face_ge/q1',
          'tone_bender_mk2/q1',
          'tone_bender_mk2/q2',
          'rangemaster/q1'
        ]));
    expect(fits, isNot(contains('fuzz_face_ge/q2')));
    expect(fits, isNot(contains('fuzz_face_si/q1')),
        reason: 'polarity/material gate');
  });

  test('germanium gain rules fall back to the DCA75 hFE when DCA55 is absent',
      () {
    final r = bjt(npn: false, germanium: true, hfe: 130, leakMa: 0.05);
    final fits = evaluate(r, vals(r), defaultCircuits)
        .where((f) => f.fits)
        .map((f) => '${f.circuit.id}/${f.position.id}');
    expect(fits, contains('fuzz_face_ge/q2'));
    final q2 = evaluate(r, vals(r), defaultCircuits).firstWhere(
        (f) => f.circuit.id == 'fuzz_face_ge' && f.position.id == 'q2');
    expect(q2.results.first.text, startsWith('hFE 130 in'));
  });

  test('leaky germanium fails on leakage with a readable reason', () {
    final r = bjt(npn: false, germanium: true, hfe: 78, leakMa: 0.31);
    final q1 = evaluate(r, vals(r), [defaultCircuit('fuzz_face_ge')!]).first;
    expect(q1.fits, isFalse);
    expect(q1.firstFailure, 'Ic leakage 310 µA above 100 µA');
  });

  test('2N5088 (NPN Si, hFE 405): Big Muff and silicon Fuzz Face Q2, not Q1',
      () {
    final r = bjt(npn: true, germanium: false, hfe: 405);
    final fits = evaluate(r, vals(r), defaultCircuits)
        .where((f) => f.fits)
        .map((f) => '${f.circuit.id}/${f.position.id}')
        .toList();
    expect(fits, ['fuzz_face_si/q2', 'big_muff_si/q1']);
  });

  test('diodes: material inferred from Vf, LED from kind or Vf', () {
    expect(
        evaluate(diode(0.69), vals(diode(0.69)), defaultCircuits)
            .where((f) => f.fits)
            .map((f) => f.circuit.id),
        ['clipping_si']);
    final ge = diode(0.455);
    final geFits = evaluate(ge, vals(ge, {'leak_ir_5v': 3e-6}), defaultCircuits)
        .where((f) => f.fits)
        .map((f) => f.circuit.id);
    expect(geFits, ['clipping_ge']);
    final leaky = evaluate(ge, vals(ge, {'leak_ir_5v': 50e-6}), defaultCircuits)
        .firstWhere((f) => f.circuit.id == 'clipping_ge');
    expect(leaky.fits, isFalse);
    expect(leaky.firstFailure, contains('Ir @ 5 V 50.0 µA above 20.0 µA'));
    final led = diode(1.9, kind: 2);
    expect(
        evaluate(led, vals(led), defaultCircuits)
            .where((f) => f.fits)
            .map((f) => f.circuit.id),
        ['clipping_led']);
    final unmeasured =
        evaluate(ge, vals(ge), [defaultCircuit('clipping_ge')!]).first;
    expect(unmeasured.fits, isFalse);
    expect(unmeasured.firstFailure, 'Ir @ 5 V not measured');
  });

  test('editing a rule and resetting to default', () {
    final c = defaultCircuit('fuzz_face_ge')!;
    final edited = c.copyWith(positions: [
      c.positions.first.copyWith(rules: [
        c.positions.first.rules.first.copyWith(min: 60, max: 90),
        c.positions.first.rules[1]
      ]),
      c.positions[1],
    ]);
    final r = bjt(npn: false, germanium: true, hfe: 65);
    expect(evaluate(r, vals(r), [c]).first.fits, isFalse);
    expect(evaluate(r, vals(r), [edited]).first.fits, isTrue);
    expect(jsonEncode(defaultCircuit('fuzz_face_ge')!.toJson()),
        jsonEncode(c.toJson()),
        reason: 'defaults untouched');
  });
}
