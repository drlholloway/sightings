import 'dart:async';
import 'dart:io';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:dca75_transport/dca75_transport.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../platform/android_usb_transport.dart';
import 'dca55.dart';
import 'drafts.dart';
import 'leakage.dart';
import 'settings.dart';

// ------------------------------------------------------------- transport

/// Overridable for tests / hardware-free demo mode.
/// Whether the app runs against the simulated unit. Watched by the
/// transport so flipping the Settings switch swaps the whole device stack.
final demoModeProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((s) => s.demoMode)),
);

final transportProvider = Provider<DcaTransport>((ref) {
  final DcaTransport t = ref.watch(demoModeProvider)
      ? DemoTransport()
      : Platform.isAndroid
      ? AndroidUsbTransport()
      : LibusbTransport();
  ref.onDispose(t.dispose);
  return t;
});

/// The simulated unit when demo mode is on, for the banner's controls.
final demoUnitProvider = Provider<DemoUnit?>((ref) {
  final t = ref.watch(transportProvider);
  return t is DemoTransport ? t.unit : null;
});

final controllerProvider = Provider<DeviceController>((ref) {
  final c = DeviceController(ref.watch(transportProvider));
  ref.onDispose(c.dispose);
  return c;
});

final deviceStatusProvider = StreamProvider<DeviceStatus>((ref) {
  final c = ref.watch(controllerProvider);
  return c.statusStream.startWith(c.status);
});

/// Convenience: current status without async wrapper.
final statusProvider = Provider<DeviceStatus>(
  (ref) =>
      ref.watch(deviceStatusProvider).value ??
      ref.watch(controllerProvider).status,
);

final transportLogProvider = Provider<TransportLog>(
  (ref) => ref.watch(transportProvider).log,
);

// -------------------------------------------------------------- database

final appInfoProvider = FutureProvider<PackageInfo>(
  (ref) => PackageInfo.fromPlatform(),
);

final databasePathProvider = FutureProvider<String>((ref) async {
  final dir = await getApplicationSupportDirectory();
  await dir.create(recursive: true);
  return p.join(dir.path, 'dca75_workbench.sqlite');
});

final databaseProvider = FutureProvider<AppDatabase>((ref) async {
  final path = await ref.watch(databasePathProvider.future);
  final db = AppDatabase(NativeDatabase.createInBackground(File(path)));
  ref.onDispose(db.close);
  return db;
});

final repositoryProvider = FutureProvider<ReadingsRepository>((ref) async {
  final repo = ReadingsRepository(await ref.watch(databaseProvider.future));
  // Readings written by an older decoder get their parameters regenerated
  // from the stored raw frames; tags and notes are untouched.
  final n = await repo.reDecodeAll();
  if (n > 0) debugPrint('re-decoded $n readings with decoder v$decoderVersion');
  return repo;
});

// ---------------------------------------------------------------- session

/// Starts a database session when the device connects and ends it on
/// disconnect. Exposes the current session id.
class SessionNotifier extends StateNotifier<int?> {
  SessionNotifier(this.ref, DeviceController controller) : super(null) {
    _sub = controller.statusStream.listen(_onStatus);
  }

  String get _platform =>
      ref.read(settingsProvider).demoMode ? 'demo' : Platform.operatingSystem;

  final Ref ref;
  StreamSubscription<DeviceStatus>? _sub;
  String? _serial;

  Future<void> _onStatus(DeviceStatus s) async {
    if (s.isConnected && s.identity != null && s.identity!.serial != _serial) {
      _serial = s.identity!.serial;
      final repo = await ref.read(repositoryProvider.future);
      final info = await ref.read(appInfoProvider.future);
      state = await repo.startSession(
        identity: s.identity,
        calibration: s.calibration,
        rMt2: s.rails?.rMt2,
        platform: _platform,
        appVersion: info.version,
      );
    } else if (!s.isConnected && state != null) {
      final id = state!;
      state = null;
      _serial = null;
      final repo = await ref.read(repositoryProvider.future);
      await repo.endSession(id);
    }
  }

  /// A session for readings that arrive without a live device (imports).
  Future<int> ensure() async {
    if (state != null) return state!;
    final repo = await ref.read(repositoryProvider.future);
    final info = await ref.read(appInfoProvider.future);
    state = await repo.startSession(
      platform: _platform,
      appVersion: info.version,
    );
    return state!;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, int?>(
  // Watching the controller re-creates the session tracker when the
  // transport is swapped (demo mode on/off).
  (ref) => SessionNotifier(ref, ref.watch(controllerProvider)),
);

// ----------------------------------------------------------------- intake

/// The last identify result (saved or draft) — drives sweep defaults and
/// the Identify card.
class LastResult {
  const LastResult({required this.event, this.readingId, this.draft});
  final IdentifyEvent event;
  final int? readingId;
  final Draft? draft;
  IdentifyResult get result => event.result;
  bool get isDraft => draft != null;
}

class LastResultNotifier extends StateNotifier<LastResult?> {
  LastResultNotifier() : super(null);
  void set(LastResult? r) => state = r;
  void savedAs(int id) {
    final s = state;
    if (s != null) state = LastResult(event: s.event, readingId: id);
  }
}

final lastResultProvider =
    StateNotifierProvider<LastResultNotifier, LastResult?>(
      (ref) => LastResultNotifier(),
    );

/// Routes identify events: app-initiated results are saved immediately;
/// unit-button results become drafts (unless the setting says otherwise).
class ReadingIntake {
  ReadingIntake(this.ref, DeviceController controller) {
    _sub = controller.identifyEvents.listen(_onEvent);
  }

  final Ref ref;
  StreamSubscription<IdentifyEvent>? _sub;

  /// The most recent saved result, restored when the last draft is discarded.
  LastResult? _lastSaved;

  void _setSaved(LastResult r) {
    _lastSaved = r;
    ref.read(lastResultProvider.notifier).set(r);
  }

  Future<void> _onEvent(IdentifyEvent e) async {
    if (!e.result.type.isComponent && e.result.type != ComponentType.none) {
      // Low battery / USB fail: surface as a banner, not a reading.
      ref.read(bannerProvider.notifier).state = e.result.name;
      return;
    }
    final asDraft =
        e.source == ReadingSource.unitButton &&
        ref.read(settingsProvider).unitButtonAsDraft;
    if (asDraft) {
      ref.read(draftsProvider.notifier).add(e);
      final d = ref.read(draftsProvider).last;
      ref.read(lastResultProvider.notifier).set(LastResult(event: e, draft: d));
      return;
    }
    final id = await save(e);
    _setSaved(LastResult(event: e, readingId: id));
    _maybeDca55(id, e.result);
  }

  /// Kick off the follow-up measurements that apply to this component:
  /// DCA55-equivalent figures for BJTs, reverse leakage for diodes.
  void _maybeDca55(int readingId, IdentifyResult r) {
    if (dca55AutoApplies(ref, r)) {
      ref.read(dca55Provider.notifier).measure(readingId, r);
    } else {
      ref.read(dca55Provider.notifier).clear();
    }
    if (leakAutoApplies(ref, r)) {
      ref.read(leakageProvider.notifier).measure(readingId, r);
    } else {
      ref.read(leakageProvider.notifier).clear();
    }
  }

  Future<int> save(IdentifyEvent e) async {
    final repo = await ref.read(repositoryProvider.future);
    final session = await ref.read(sessionProvider.notifier).ensure();
    return repo.saveReading(
      session,
      e.result,
      source: e.source,
      rails: e.rails,
      takenAt: e.at,
    );
  }

  /// Persist a draft; returns the new reading id.
  Future<int> saveDraft(Draft d) async {
    final id = await save(d.event);
    ref.read(draftsProvider.notifier).remove(d);
    final last = ref.read(lastResultProvider);
    final saved = LastResult(event: d.event, readingId: id);
    if (last?.draft?.seq == d.seq) {
      _setSaved(saved);
      _maybeDca55(id, d.event.result);
    } else {
      _lastSaved = saved;
    }
    return id;
  }

  void discardDraft(Draft d) {
    ref.read(draftsProvider.notifier).remove(d);
    final last = ref.read(lastResultProvider);
    if (last?.draft?.seq == d.seq) {
      final next = ref.read(draftsProvider);
      ref
          .read(lastResultProvider.notifier)
          .set(
            next.isEmpty
                ? _lastSaved
                : LastResult(event: next.first.event, draft: next.first),
          );
    }
  }

  void dispose() => _sub?.cancel();
}

final intakeProvider = Provider<ReadingIntake>((ref) {
  final i = ReadingIntake(ref, ref.watch(controllerProvider));
  ref.onDispose(i.dispose);
  return i;
});

/// Transient banner text (low battery etc.); null hides it.
final bannerProvider = StateProvider<String?>((ref) => null);

// ----------------------------------------------------------- auto-connect

/// Watches for attach events and connects when exactly one unit is present.
class AutoConnector {
  AutoConnector(this.ref, DcaTransport t) {
    if (t is LibusbTransport) t.startWatching();
    _sub = t.events.listen((e) {
      if (e.kind == TransportEventKind.attached) _maybeConnect();
    });
    // Initial attempt shortly after startup.
    _initial = Timer(const Duration(milliseconds: 300), _maybeConnect);
  }

  final Ref ref;
  StreamSubscription<TransportEvent>? _sub;
  Timer? _initial;
  bool _busy = false;
  bool _disposed = false;

  Future<void> _maybeConnect() async {
    if (_disposed || _busy) return;
    if (!ref.read(settingsProvider).autoConnect) return;
    final c = ref.read(controllerProvider);
    if (c.status.state != ConnectionState.disconnected) return;
    _busy = true;
    try {
      final devs = await ref.read(transportProvider).listDevices();
      if (_disposed) return;
      if (devs.length == 1) await c.connect(devs.single);
    } catch (e) {
      debugPrint('auto-connect: $e');
    } finally {
      _busy = false;
    }
  }

  void dispose() {
    _disposed = true;
    _initial?.cancel();
    _sub?.cancel();
  }
}

final autoConnectorProvider = Provider<AutoConnector>((ref) {
  final a = AutoConnector(ref, ref.watch(transportProvider));
  ref.onDispose(a.dispose);
  return a;
});

extension<T> on Stream<T> {
  Stream<T> startWith(T first) async* {
    yield first;
    yield* this;
  }
}
