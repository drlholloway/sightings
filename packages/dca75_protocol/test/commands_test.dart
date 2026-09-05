import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:test/test.dart';

/// Expected leading bytes of each builder; the rest of the frame is zero.
void expectHead(Frame f, List<int> head, {String? reason}) {
  final b = f.bytes;
  expect(b.sublist(0, head.length), head, reason: reason);
  expect(b.sublist(head.length).every((x) => x == 0), isTrue,
      reason: 'tail must be zero');
}

void main() {
  test('STATE', () {
    expectHead(buildState(DeviceState.idle), [0x86, 0, 0]);
    expectHead(buildState(DeviceState.testedAck), [0x86, 0, 130]);
  });
  test('CAL read-only', () => expectHead(buildCalRead(), [0x84, 0, 0]));
  test('TEST', () {
    expectHead(buildTestInitiate(), [0x85, 1]);
    expectHead(buildTestRead(), [0x85, 2]);
  });
  test('ADCS', () {
    expectHead(buildAdcs(direct: 0x1F), [0x83, 0, 0x1F, 0, 0]);
    expectHead(buildAdcs(burst: 248), [0x83, 0, 0, 0, 248]);
  });
  test('BOOST clamps to 15 V', () {
    final f = buildBoost(20);
    expect(f.f32(2), 15.0);
    expect(f.bytes[0], 0x8A);
    expect(buildBoost(12.5).f32(2), closeTo(12.5, 1e-6));
  });
  test('simple opcodes', () {
    expectHead(buildBoosted(), [0x8B]);
    expectHead(buildBoostOff(), [0x8C]);
    expectHead(buildLeadsSafe(), [0x8D]);
  });
  test('RGATE', () => expectHead(buildRGate(RGateIdx.r470k), [0x8E, 0, 4]));
  test('VOLTS', () {
    final f = buildDacVolts(0.5, Dac.gate);
    expect(f.bytes[0], 0x8F);
    expect(f.f32(2), 0.5);
    expect(f.bytes[6], 2);
  });
  test('ALLVOLTS', () {
    final f = buildDacAllVolts(0.5, 12.5, 0.5);
    expect(f.bytes[0], 0x90);
    expect(f.f32(2), 0.5);
    expect(f.f32(6), 12.5);
    expect(f.f32(10), 0.5);
  });
  test('MATRIXRGB', () {
    expectHead(
        buildMatrixRgb(Drive.mt2, Drive.mt1, Drive.gate), [0x91, 0, 2, 1, 3]);
  });
  test('MATRIXPLUS', () => expectHead(buildMatrixPlus(3, 7), [0x92, 0, 3, 7]));
  test(
      'BRIDGEGATE', () => expectHead(buildBridgeGate(Lead.blue), [0x97, 0, 3]));
  test('MODE', () => expectHead(buildMode(DeviceMode.analogUsb), [0x93, 0, 3]));
  test('CCGATE matches reference self-test', () {
    final f = buildCcGate(CxMode.on, milliamps: 1.5, timeoutMs: 200);
    expect(f.bytes[0], 0x94);
    expect(f.bytes[2], 1);
    expect(f.f32(3), closeTo(1.5, 1e-6));
    expect(f.u16(7), 200);
    expect(f.bytes.length, 64);
  });
  test('CVGATE', () {
    final f =
        buildCvGate(CxMode.oneShotBurst, cfg: 4, volts: -2.0, timeoutMs: 500);
    expect(f.bytes[0], 0x95);
    expect(f.bytes[2], 6);
    expect(f.bytes[3], 4);
    expect(f.f32(4), -2.0);
    expect(f.u16(8), 500);
  });
}
