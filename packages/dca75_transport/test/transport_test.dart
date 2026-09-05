import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:test/test.dart';

void main() {
  late FakeTransport t;
  setUp(() async {
    t = FakeTransport();
    await t.open((await t.listDevices()).single);
  });
  tearDown(() => t.dispose());

  test('exchange echoes opcode by default and logs', () async {
    final r = await t.exchange(buildLeadsSafe());
    expect(r.opcode, 0x8D);
    expect(t.sentOpcodes, [0x8D]);
    expect(t.log.length, 1);
    expect(t.log.entries.single.ok, isTrue);
  });

  test('policy violations never reach the wire', () async {
    final f = buildState(DeviceState.idle)..setU8(1, writeArmStatus);
    expect(() => t.exchange(f), throwsA(isA<ProtocolPolicyError>()));
    expect(t.sent, isEmpty);
    expect(t.log.length, 0);
  });

  test('not open -> notOpen error', () async {
    await t.close();
    await expectLater(
        t.exchange(buildLeadsSafe()),
        throwsA(isA<TransportException>()
            .having((e) => e.kind, 'kind', TransportErrorKind.notOpen)));
  });

  test('stale frames are retried up to 3 times then fail', () async {
    var n = 0;
    t.handler = (out) {
      n++;
      return Uint8List(64)..[0] = 0x99; // never matches
    };
    await expectLater(
        t.exchange(buildLeadsSafe()),
        throwsA(isA<TransportException>()
            .having((e) => e.kind, 'kind', TransportErrorKind.mismatch)));
    expect(n, 3);
    expect(t.log.entries.where((e) => !e.ok).length, 3);
  });

  test('one stale frame then good is accepted', () async {
    var n = 0;
    t.handler = (out) => ++n == 1 ? (Uint8List(64)..[0] = 0x11) : null;
    final r = await t.exchange(buildLeadsSafe());
    expect(r.opcode, 0x8D);
    expect(n, 2);
  });

  test('exchanges are serialised in call order', () async {
    t.latency = const Duration(milliseconds: 5);
    final order = <int>[];
    t.handler = (out) {
      order.add(out[0]);
      return null;
    };
    await Future.wait([
      t.exchange(buildLeadsSafe()),
      t.exchange(buildBoostOff()),
      t.exchange(buildMode(DeviceMode.none)),
    ]);
    expect(order, [0x8D, 0x8C, 0x93]);
  });

  test('a failed exchange does not block the next one', () async {
    t.handler = (out) => out[0] == 0x8C ? (Uint8List(64)..[0] = 0x01) : null;
    final f1 = t.exchange(buildBoostOff());
    final f2 = t.exchange(buildLeadsSafe());
    await expectLater(f1, throwsA(isA<TransportException>()));
    expect((await f2).opcode, 0x8D);
  });

  test('pulling the device emits detached and closes', () async {
    final events = <TransportEvent>[];
    t.events.listen(events.add);
    t.pull();
    await expectLater(
        t.exchange(buildLeadsSafe()),
        throwsA(isA<TransportException>()
            .having((e) => e.kind, 'kind', TransportErrorKind.disconnected)));
    await Future<void>.delayed(Duration.zero);
    expect(t.isOpen, isFalse);
    expect(events.map((e) => e.kind), contains(TransportEventKind.detached));
  });

  test('timeout', () async {
    final slow = FakeTransport(timeout: const Duration(milliseconds: 20));
    await slow.open((await slow.listDevices()).single);
    slow.latency = const Duration(milliseconds: 800); // > 20 ms + 500 ms margin
    await expectLater(
        slow.exchange(buildLeadsSafe()),
        throwsA(isA<TransportException>()
            .having((e) => e.kind, 'kind', TransportErrorKind.timeout)));
    await slow.dispose();
  });

  test('per-exchange timeout override', () async {
    final slow = FakeTransport(timeout: const Duration(milliseconds: 20));
    await slow.open((await slow.listDevices()).single);
    slow.latency = const Duration(milliseconds: 800);
    // default budget (20 ms + 500 ms margin) is not enough for 800 ms
    await expectLater(
        slow.exchange(buildLeadsSafe()),
        throwsA(isA<TransportException>()
            .having((e) => e.kind, 'kind', TransportErrorKind.timeout)));
    // an override of 1 s is
    final r = await slow.exchange(buildLeadsSafe(),
        timeout: const Duration(seconds: 1));
    expect(r.opcode, 0x8D);
    await slow.dispose();
  });

  test('queued responses are consumed in order', () async {
    t.enqueue(0x8B, Uint8List(64)..[0] = 0x8B);
    t.enqueue(0x8B, (Uint8List(64)..[0] = 0x8B)..[1] = 1);
    expect(parseBoosted(await t.exchange(buildBoosted())), isFalse);
    expect(parseBoosted(await t.exchange(buildBoosted())), isTrue);
    expect(parseBoosted(await t.exchange(buildBoosted())), isFalse,
        reason: 'falls back to echo');
  });

  test('latency stats', () async {
    for (var i = 0; i < 10; i++) {
      await t.exchange(buildLeadsSafe());
    }
    final s = t.log.latency();
    expect(s.n, 10);
    expect(s.p95 >= s.p50, isTrue);
  });
}
