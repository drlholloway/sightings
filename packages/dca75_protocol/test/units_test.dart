import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('eng picks SI prefixes', () {
    expect(eng(0.00212, 'A'), '2.12 mA');
    expect(eng(4700, 'Ω'), '4.70 kΩ');
    expect(eng(0.71, 'V'), '710 mV');
    expect(eng(12.0, 'V'), '12.0 V');
    expect(eng(2.5e-6, 'A'), '2.50 µA');
    expect(eng(3e-9, 'A'), '3.00 nA');
    expect(eng(0, 'V'), '0 V');
    expect(eng(null, 'V'), '—');
    expect(eng(double.nan, 'V'), '—');
    expect(eng(-0.005, 'A'), '-5.00 mA');
  });
  test('eng below pico uses exponential', () {
    expect(eng(1.5e-14, 'A'), '1.50e-14 A');
  });
  test('sig and tick', () {
    expect(sig(212.3456), '212.3');
    expect(tick(2.5), '2.5');
    expect(tick(10.0), '10');
    expect(tick(0.30000000000000004), '0.3');
    expect(tick(0), '0');
  });
}
