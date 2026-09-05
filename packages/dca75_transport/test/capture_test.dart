import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:test/test.dart';

void main() {
  test('capture round-trips through encode/parse and replays', () async {
    final s = ScriptedDca();
    final t = s.transport;
    await t.open((await t.listDevices()).single);
    await t.exchange(buildState(DeviceState.idle));
    await t.exchange(buildCalRead());
    await t.exchange(buildAdcs(direct: adcsAllRails));
    final text = encodeCapture(t.log.entries, comment: 'test');
    await t.dispose();

    final lines = parseCapture(text);
    expect(lines.length, 3);
    expect(lines[0].opcode, 0x86);
    expect(lines[2].input![0], 0x83);

    final r = ReplayTransport(lines);
    await r.open((await r.listDevices()).single);
    final st = parseState(await r.exchange(buildState(DeviceState.idle)));
    expect(st.serial, 'ABC123');
    await r.exchange(buildCalRead());
    final a = parseAdcs(await r.exchange(buildAdcs(direct: adcsAllRails)),
        direct: true);
    expect(a.rails!.batt, closeTo(1.5, 1e-6));
    expect(r.exhausted, isTrue);
    await expectLater(
        r.exchange(buildLeadsSafe()), throwsA(isA<TransportException>()));
    await r.dispose();
  });

  test('strict replay rejects a different frame; lenient accepts same opcode',
      () async {
    final s = ScriptedDca();
    final t = s.transport;
    await t.open((await t.listDevices()).single);
    await t.exchange(buildState(DeviceState.idle));
    final lines = parseCapture(encodeCapture(t.log.entries));
    await t.dispose();

    final strict = ReplayTransport(lines);
    await strict.open((await strict.listDevices()).single);
    await expectLater(strict.exchange(buildState(DeviceState.testedAck)),
        throwsA(isA<ReplayMismatch>()));
    await strict.dispose();

    final lenient = ReplayTransport(lines, strict: false);
    await lenient.open((await lenient.listDevices()).single);
    expect((await lenient.exchange(buildState(DeviceState.testedAck))).opcode,
        0x86);
    await lenient.dispose();
  });

  test('comments and blank lines are ignored; bad lines throw', () {
    expect(parseCapture('# hello\n\n'), isEmpty);
    expect(() => parseCapture('2026-01-01T00:00:00Z 00 - 1'),
        throwsFormatException);
  });
}
