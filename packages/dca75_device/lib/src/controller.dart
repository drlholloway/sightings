import 'dart:async';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_transport/dca75_transport.dart';

import 'client.dart';
import 'timing.dart';

enum ConnectionState {
  disconnected,
  connecting,
  idle,
  testing,
  fetching,
  sweeping
}

/// Where an identify result came from.
enum ReadingSource { app, unitButton, import }

class DeviceIdentity {
  const DeviceIdentity({
    required this.serial,
    required this.hardwareRev,
    required this.firmwareRev,
    this.productName,
  });
  final String serial, hardwareRev, firmwareRev;
  final String? productName;

  @override
  String toString() => 'DCA Pro s/n $serial hw $hardwareRev fw $firmwareRev';
}

class Rails {
  const Rails({
    required this.batt,
    required this.v12,
    required this.vRef,
    required this.rMt2,
    required this.at,
  });
  final double batt, v12, vRef, rMt2;
  final DateTime at;
}

class DeviceStatus {
  const DeviceStatus({
    this.state = ConnectionState.disconnected,
    this.device,
    this.identity,
    this.calibration,
    this.rails,
    this.lastError,
  });
  final ConnectionState state;
  final DcaDeviceInfo? device;
  final DeviceIdentity? identity;
  final Calibration? calibration;
  final Rails? rails;
  final String? lastError;

  bool get isConnected =>
      state != ConnectionState.disconnected &&
      state != ConnectionState.connecting;
  bool get isBusy =>
      state == ConnectionState.testing ||
      state == ConnectionState.fetching ||
      state == ConnectionState.sweeping;

  DeviceStatus copyWith({
    ConnectionState? state,
    DcaDeviceInfo? device,
    DeviceIdentity? identity,
    Calibration? calibration,
    Rails? rails,
    String? lastError,
    bool clearError = false,
    bool clearDevice = false,
  }) =>
      DeviceStatus(
        state: state ?? this.state,
        device: clearDevice ? null : (device ?? this.device),
        identity: clearDevice ? null : (identity ?? this.identity),
        calibration: clearDevice ? null : (calibration ?? this.calibration),
        rails: clearDevice ? null : (rails ?? this.rails),
        lastError: clearError ? null : (lastError ?? this.lastError),
      );
}

class IdentifyEvent {
  const IdentifyEvent({
    required this.result,
    required this.source,
    required this.at,
    this.rails,
  });
  final IdentifyResult result;
  final ReadingSource source;
  final DateTime at;
  final Rails? rails;
}

/// Owns the transport for one connection and runs the connection state
/// machine: connect, idle polling for unit-button tests, identify, and
/// exclusive access for sweeps. Emits [DeviceStatus] and [IdentifyEvent]s.
class DeviceController {
  DeviceController(
    this.transport, {
    Sleep? sleep,
    this.pollInterval = const Duration(milliseconds: 600),
    this.identifyPollInterval = const Duration(milliseconds: 150),
    this.identifyTimeout = const Duration(seconds: 15),
    this.autoPoll = true,
  })  : sleep = sleep ?? realSleep,
        client = DcaClient(transport, sleep: sleep ?? realSleep) {
    _transportSub = transport.events.listen(_onTransportEvent);
  }

  final DcaTransport transport;
  final DcaClient client;
  final Sleep sleep;
  final Duration pollInterval;
  final Duration identifyPollInterval;
  final Duration identifyTimeout;
  final bool autoPoll;

  final _status = StreamController<DeviceStatus>.broadcast(sync: true);
  final _identify = StreamController<IdentifyEvent>.broadcast(sync: true);
  DeviceStatus _current = const DeviceStatus();
  StreamSubscription<TransportEvent>? _transportSub;
  Timer? _pollTimer;
  bool _busy = false;
  bool _polling = false;

  DeviceStatus get status => _current;
  Stream<DeviceStatus> get statusStream => _status.stream;
  Stream<IdentifyEvent> get identifyEvents => _identify.stream;
  bool get isBusy => _busy;

  void _set(DeviceStatus s) {
    _current = s;
    if (!_status.isClosed) _status.add(s);
  }

  // ------------------------------------------------------------ connection

  /// Connect to [device], or to the only DCA75 present when null.
  Future<void> connect([DcaDeviceInfo? device]) async {
    if (_current.state != ConnectionState.disconnected) return;
    _set(
        _current.copyWith(state: ConnectionState.connecting, clearError: true));
    try {
      final target = device ?? await _onlyDevice();
      await transport.open(target);
      final st = await client.getState(DeviceState.idle);
      Calibration? cal;
      try {
        cal = await client.readCal();
      } catch (_) {
        cal = null;
      }
      final rails = await _rails();
      _set(DeviceStatus(
        state: ConnectionState.idle,
        device: target,
        identity: DeviceIdentity(
          serial: st.serial,
          hardwareRev: st.hardwareRev,
          firmwareRev: st.firmwareRev,
          productName: target.productName,
        ),
        calibration: cal,
        rails: rails,
      ));
      if (autoPoll) startPolling();
    } catch (e) {
      try {
        await transport.close();
      } catch (_) {}
      _set(DeviceStatus(lastError: _describe(e)));
      rethrow;
    }
  }

  Future<DcaDeviceInfo> _onlyDevice() async {
    final devs =
        (await transport.listDevices()).where((d) => d.isDca75).toList();
    if (devs.isEmpty) {
      throw TransportException(TransportErrorKind.noDevice, 'no DCA75 found');
    }
    if (devs.length > 1) {
      throw TransportException(TransportErrorKind.noDevice,
          '${devs.length} DCA75 units found; choose one');
    }
    return devs.single;
  }

  Future<void> disconnect() async {
    stopPolling();
    if (_current.state == ConnectionState.disconnected) return;
    if (transport.isOpen) {
      await client.safeShutdown();
      try {
        await transport.close();
      } catch (_) {}
    }
    _set(const DeviceStatus());
  }

  void _onTransportEvent(TransportEvent e) {
    if (e.kind == TransportEventKind.detached &&
        _current.state != ConnectionState.disconnected) {
      stopPolling();
      _set(DeviceStatus(lastError: e.message ?? 'device unplugged'));
    }
  }

  // ---------------------------------------------------------------- polling

  void startPolling() {
    stopPolling();
    _polling = true;
    _pollTimer = Timer.periodic(pollInterval, (_) => pollOnce());
  }

  void stopPolling() {
    _polling = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  bool get isPolling => _polling;

  /// One idle poll: if the unit reports TESTED (the user pressed its button),
  /// acknowledge, fetch, and emit the result as a unit-button reading.
  /// Transient errors are ignored; a disconnect is handled by the transport
  /// event.
  Future<void> pollOnce() async {
    if (_busy || _current.state != ConnectionState.idle) return;
    _busy = true;
    try {
      final st = await client.getState(DeviceState.idle);
      if (st.state == DeviceState.tested) {
        _set(_current.copyWith(state: ConnectionState.fetching));
        final ev = await _fetchResult(ReadingSource.unitButton);
        _set(_current.copyWith(state: ConnectionState.idle));
        _identify.add(ev);
      }
    } catch (_) {
      if (_current.state == ConnectionState.fetching) {
        _set(_current.copyWith(state: ConnectionState.idle));
      }
    } finally {
      _busy = false;
    }
  }

  Future<IdentifyEvent> _fetchResult(ReadingSource source) async {
    await client.getState(DeviceState.testedAck);
    final result = await client.readTestResult();
    Rails? rails;
    try {
      rails = await _rails();
    } catch (_) {}
    if (rails != null) _set(_current.copyWith(rails: rails));
    return IdentifyEvent(
        result: result, source: source, at: DateTime.now(), rails: rails);
  }

  // --------------------------------------------------------------- identify

  /// Run a test from the app. Returns the decoded result and also emits it
  /// on [identifyEvents] with source `app`.
  Future<IdentifyResult> identify({CancelToken? cancel}) async {
    final ev = await exclusive(ConnectionState.testing, (c) async {
      await c.initiateTest();
      final sw = Stopwatch()..start();
      DeviceState? st;
      do {
        await sleep(identifyPollInterval);
        // The unit is silent for the whole test (seconds); let one poll
        // block for the full identify budget rather than time out.
        st = (await c.getState(DeviceState.idle, timeout: identifyTimeout))
            .state;
        if (cancel?.isCancelled ?? false) {
          throw const IdentifyCancelled();
        }
      } while (st != DeviceState.tested && sw.elapsed < identifyTimeout);
      if (st != DeviceState.tested) {
        throw const IdentifyTimeout();
      }
      return _fetchResult(ReadingSource.app);
    });
    _identify.add(ev);
    return ev.result;
  }

  Future<Rails> refreshRails() async {
    final r = await _rails();
    _set(_current.copyWith(rails: r));
    return r;
  }

  Future<Rails> _rails() async {
    final a = await client.readRails();
    return Rails(
        batt: a.batt,
        v12: a.v12,
        vRef: a.vRef,
        rMt2: client.mirror.rMt2,
        at: DateTime.now());
  }

  // ------------------------------------------------------------- exclusive

  /// Run [body] with exclusive access to the unit while the status shows
  /// [busyState]. On any error the unit is put back into a safe state before
  /// the error propagates. Sweeps use this with [ConnectionState.sweeping].
  Future<T> exclusive<T>(
      ConnectionState busyState, Future<T> Function(DcaClient c) body) async {
    if (!_current.isConnected) {
      throw StateError('not connected');
    }
    if (_busy) throw StateError('device is busy');
    _busy = true;
    _set(_current.copyWith(state: busyState, clearError: true));
    try {
      return await body(client);
    } catch (e) {
      if (transport.isOpen) await client.safeShutdown();
      if (_current.state != ConnectionState.disconnected) {
        _set(_current.copyWith(lastError: _describe(e)));
      }
      rethrow;
    } finally {
      _busy = false;
      if (_current.state != ConnectionState.disconnected) {
        _set(_current.copyWith(state: ConnectionState.idle));
      }
    }
  }

  static String _describe(Object e) => switch (e) {
        TransportException t => t.message,
        IdentifyTimeout _ => 'test timed out',
        IdentifyCancelled _ => 'test cancelled',
        _ => e.toString(),
      };

  Future<void> dispose() async {
    stopPolling();
    await _transportSub?.cancel();
    if (transport.isOpen) {
      try {
        await client.safeShutdown();
        await transport.close();
      } catch (_) {}
    }
    await _status.close();
    await _identify.close();
  }
}

class IdentifyTimeout implements Exception {
  const IdentifyTimeout();
  @override
  String toString() => 'test timed out';
}

class IdentifyCancelled implements Exception {
  const IdentifyCancelled();
  @override
  String toString() => 'test cancelled';
}
