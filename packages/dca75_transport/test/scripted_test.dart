import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:test/test.dart';

void main() {
  test('ScriptedDca answers STATE/CAL/ADCS like a unit', () async {
    final s = ScriptedDca();
    final t = s.transport;
    await t.open((await t.listDevices()).single);
    final st = parseState(await t.exchange(buildState(DeviceState.idle)));
    expect(st.serial, 'ABC123');
    expect(st.state, DeviceState.idle);
    expect(st.rMt2, closeTo(618.5, 0.01));
    final cal = parseCal(await t.exchange(buildCalRead()));
    expect(cal.r8k2, 8200);
    final a = parseAdcs(await t.exchange(buildAdcs(direct: adcsAllRails)),
        direct: true);
    expect(a.rails!.v12, closeTo(12.1, 1e-6));
    expect(parseRGate(await t.exchange(buildRGate(RGateIdx.r8k2))), 8200);
    await t.dispose();
  });

  test('ScriptedDca test flow: TEST(1), polls, TESTED, ack, TEST(2)', () async {
    final s = ScriptedDca(testedAfterPolls: 2);
    final t = s.transport;
    await t.open((await t.listDevices()).single);
    await t.exchange(buildTestInitiate());
    expect(parseState(await t.exchange(buildState(DeviceState.idle))).state,
        DeviceState.testing);
    expect(parseState(await t.exchange(buildState(DeviceState.idle))).state,
        DeviceState.tested);
    await t.exchange(buildState(DeviceState.testedAck));
    expect(parseState(await t.exchange(buildState(DeviceState.idle))).state,
        DeviceState.idle);
    await t.dispose();
  });

  test('ScriptedDca unit button press shows TESTED once', () async {
    final s = ScriptedDca()..unitButtonPress = true;
    final t = s.transport;
    await t.open((await t.listDevices()).single);
    expect(parseState(await t.exchange(buildState(DeviceState.idle))).state,
        DeviceState.tested);
    await t.exchange(buildState(DeviceState.testedAck));
    expect(parseState(await t.exchange(buildState(DeviceState.idle))).state,
        DeviceState.idle);
    await t.dispose();
  });
}
