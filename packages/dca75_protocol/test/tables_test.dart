import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('reference self-test: cfg tables', () {
    expect(vceTab[3]!.$1, Lead.red);
    expect(vbeTab[1]!.$1, Lead.blue);
    expect(cfgLeads[4]!.gate, Lead.red);
  });

  test('reference self-test: diode cfg fwd R/G == 3', () {
    expect(configFrom12G(Lead.green, Lead.red), 3);
  });

  test('configFrom12G covers every ordered lead pair', () {
    const leads = [Lead.red, Lead.green, Lead.blue];
    final seen = <int>{};
    for (final k in leads) {
      for (final a in leads) {
        if (k == a) continue;
        final cfg = configFrom12G(k, a);
        expect(cfg, inInclusiveRange(1, 6));
        // MT1 must carry the cathode, MT2 the anode.
        expect(cfgLeads[cfg]!.mt1, k, reason: 'cathode $k anode $a');
        expect(cfgLeads[cfg]!.mt2, a, reason: 'cathode $k anode $a');
        seen.add(cfg);
      }
    }
    expect(seen.length, 6);
  });

  test('revM1M2 swaps MT1 and MT2', () {
    for (final e in revM1M2.entries) {
      expect(cfgLeads[e.value]!.mt1, cfgLeads[e.key]!.mt2);
      expect(cfgLeads[e.value]!.mt2, cfgLeads[e.key]!.mt1);
      expect(cfgLeads[e.value]!.gate, cfgLeads[e.key]!.gate);
    }
  });

  test('pinsFor order is MT1, GATE, MT2 and P configs reuse leads', () {
    final n = pinsFor(1, ['E', 'C', 'B'])!;
    expect(n, [
      const PinAssignment(lead: Lead.red, terminal: 'E'),
      const PinAssignment(lead: Lead.blue, terminal: 'B'),
      const PinAssignment(lead: Lead.green, terminal: 'C'),
    ]);
    expect(pinsFor(7, ['E', 'C', 'B']), n);
    expect(pinsFor(0, ['E', 'C', 'B']), isNull);
    expect(pinsFor(13, ['E', 'C', 'B']), isNull);
  });

  test('diodePins puts anode on gate lead and cathode on MT1', () {
    expect(diodePins(2), [
      const PinAssignment(lead: Lead.green, terminal: 'A'),
      const PinAssignment(lead: Lead.red, terminal: 'K'),
    ]);
  });

  test('vce/vbe tables cover 1..12 and use distinct leads', () {
    for (var c = 1; c <= 12; c++) {
      expect(vceTab[c]!.$1, isNot(vceTab[c]!.$2));
      expect(vbeTab[c]!.$1, isNot(vbeTab[c]!.$2));
    }
  });
}
