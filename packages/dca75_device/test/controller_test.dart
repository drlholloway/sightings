import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  late ScriptedDca dca;
  late DeviceController ctl;

  setUp(() {
    dca = ScriptedDca(result: bjtFrame(cfg: 3, hfe: 212.4));
    ctl = DeviceController(dca.transport,
        sleep: noSleep,
        autoPoll: false,
        identifyTimeout: const Duration(milliseconds: 200));
  });
  tearDown(() => ctl.dispose());

  test('connect populates identity, calibration and rails', () async {
    final states = <ConnectionState>[];
    ctl.statusStream.listen((s) => states.add(s.state));
    await ctl.connect();
    final s = ctl.status;
    expect(s.state, ConnectionState.idle);
    expect(s.identity!.serial, 'ABC123');
    expect(s.identity!.firmwareRev, '0112');
    expect(s.calibration!.r8k2, 8200);
    expect(s.rails!.v12, closeTo(12.1, 1e-6));
    expect(s.rails!.rMt2, closeTo(618.5, 0.01));
    expect(states, [ConnectionState.connecting, ConnectionState.idle]);
    expect(dca.transport.sentOpcodes, [0x86, 0x84, 0x83]);
  });

  test('connect with no device fails cleanly', () async {
    dca.transport.present = false;
    await expectLater(ctl.connect(), throwsA(isA<TransportException>()));
    expect(ctl.status.state, ConnectionState.disconnected);
    expect(ctl.status.lastError, contains('no DCA75'));
  });

  test('identify from the app: TEST(1), polls, ack, TEST(2), rails', () async {
    await ctl.connect();
    dca.transport.clearSent();
    final events = <IdentifyEvent>[];
    ctl.identifyEvents.listen(events.add);
    final r = await ctl.identify();
    expect(r.type, ComponentType.bjt);
    expect(r.hfe, closeTo(212.4, 1e-3));
    await Future<void>.delayed(Duration.zero);
    expect(events.single.source, ReadingSource.app);
    expect(events.single.rails, isNotNull);
    final ops = dca.transport.sentOpcodes;
    expect(ops.first, 0x85);
    expect(dca.transport.sent.first[1], 1, reason: 'TEST initiate');
    final ackIdx =
        dca.transport.sent.indexWhere((b) => b[0] == 0x86 && b[2] == 130);
    expect(ackIdx, greaterThan(0));
    expect(ops[ackIdx + 1], 0x85);
    expect(dca.transport.sent[ackIdx + 1][1], 2, reason: 'TEST read');
    expect(ops.last, 0x83, reason: 'rails refresh');
    expect(ctl.status.state, ConnectionState.idle);
  });

  test('identify timeout returns to idle with error and safe shutdown',
      () async {
    dca.testedAfterPolls = 1 << 30;
    await ctl.connect();
    dca.transport.clearSent();
    await expectLater(ctl.identify(), throwsA(isA<IdentifyTimeout>()));
    expect(ctl.status.state, ConnectionState.idle);
    expect(ctl.status.lastError, 'test timed out');
    final ops = dca.transport.sentOpcodes;
    expect(ops.sublist(ops.length - 4), [0x8D, 0x94, 0x95, 0x93],
        reason: 'LEADSAFE, CC off, CV off, MODE none');
  });

  test('identify while busy throws StateError', () async {
    await ctl.connect();
    final f = ctl.identify();
    expect(() => ctl.identify(), throwsStateError);
    await f;
  });

  test('pollOnce picks up a unit-button test and acks exactly once', () async {
    await ctl.connect();
    dca.transport.clearSent();
    final events = <IdentifyEvent>[];
    ctl.identifyEvents.listen(events.add);
    await ctl.pollOnce(); // nothing
    expect(events, isEmpty);
    dca.unitButtonPress = true;
    await ctl.pollOnce();
    await Future<void>.delayed(Duration.zero);
    expect(events.single.source, ReadingSource.unitButton);
    expect(events.single.result.type, ComponentType.bjt);
    final acks = dca.transport.sent.where((b) => b[0] == 0x86 && b[2] == 130);
    expect(acks.length, 1);
    await ctl.pollOnce();
    expect(events.length, 1, reason: 'no re-fetch after ack');
    expect(ctl.status.state, ConnectionState.idle);
  });

  test('poller does not touch the unit while exclusive work runs', () async {
    await ctl.connect();
    dca.transport.clearSent();
    final gate = Future<void>.delayed(const Duration(milliseconds: 20));
    final work = ctl.exclusive(ConnectionState.sweeping, (c) async {
      await gate;
      return 1;
    });
    expect(ctl.status.state, ConnectionState.sweeping);
    await ctl.pollOnce();
    expect(dca.transport.sent, isEmpty);
    expect(await work, 1);
    expect(ctl.status.state, ConnectionState.idle);
  });

  test('startPolling polls on the timer', () {
    // Everything must be created inside the fake zone so its futures and
    // timers are the fake ones.
    fakeAsync((async) {
      final dca2 = ScriptedDca();
      final ctl2 =
          DeviceController(dca2.transport, sleep: noSleep, autoPoll: false);
      ctl2.connect();
      async.flushMicrotasks();
      expect(ctl2.status.state, ConnectionState.idle,
          reason: ctl2.status.lastError);
      dca2.transport.clearSent();
      ctl2.startPolling();
      async.elapse(const Duration(milliseconds: 1300));
      expect(dca2.transport.sentOpcodes, [0x86, 0x86]);
      ctl2.stopPolling();
      async.elapse(const Duration(seconds: 2));
      expect(dca2.transport.sentOpcodes.length, 2);
      ctl2.dispose();
      async.flushMicrotasks();
    });
  });

  test('device pulled -> disconnected with error', () async {
    await ctl.connect();
    dca.transport.pull();
    await ctl.pollOnce();
    await Future<void>.delayed(Duration.zero);
    expect(ctl.status.state, ConnectionState.disconnected);
    expect(ctl.status.lastError, isNotNull);
    expect(ctl.status.identity, isNull);
  });

  test('exclusive error runs safe shutdown and records error', () async {
    await ctl.connect();
    dca.transport.clearSent();
    await expectLater(
        ctl.exclusive(
            ConnectionState.sweeping, (c) async => throw StateError('boom')),
        throwsStateError);
    expect(dca.transport.sentOpcodes, [0x8D, 0x94, 0x95, 0x93]);
    expect(ctl.status.lastError, contains('boom'));
    expect(ctl.status.state, ConnectionState.idle);
  });

  test('disconnect shuts down safely and closes', () async {
    await ctl.connect();
    dca.transport.clearSent();
    await ctl.disconnect();
    expect(dca.transport.sentOpcodes, [0x8D, 0x94, 0x95, 0x93]);
    expect(dca.transport.isOpen, isFalse);
    expect(ctl.status.state, ConnectionState.disconnected);
    expect(ctl.status.lastError, isNull);
  });
}
