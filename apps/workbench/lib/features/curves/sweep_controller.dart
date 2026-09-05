import 'dart:async';

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/providers.dart';

class SweepState {
  const SweepState({
    this.running = false,
    this.collector,
    this.error,
    this.savedId,
    this.startedAt,
    this.duration,
  });
  final bool running;
  final SweepCollector? collector;
  final String? error;
  final int? savedId;
  final DateTime? startedAt;
  final Duration? duration;

  SweepState copyWith({
    bool? running,
    SweepCollector? collector,
    String? error,
    int? savedId,
    DateTime? startedAt,
    Duration? duration,
    bool clearError = false,
  }) => SweepState(
    running: running ?? this.running,
    collector: collector ?? this.collector,
    error: clearError ? null : (error ?? this.error),
    savedId: savedId ?? this.savedId,
    startedAt: startedAt ?? this.startedAt,
    duration: duration ?? this.duration,
  );
}

/// Runs one sweep at a time through the device controller's exclusive lock,
/// streams points into a collector, and saves the result when it ends.
class SweepNotifier extends StateNotifier<SweepState> {
  SweepNotifier(this.ref) : super(const SweepState());
  final Ref ref;
  CancelToken? _cancel;

  Future<void> start(
    SweepParams params, {
    required IdentifyResult? last,
    int? readingId,
    bool save = true,
  }) async {
    if (state.running) return;
    final ctl = ref.read(controllerProvider);
    final collector = SweepCollector(params);
    final cancel = CancelToken();
    _cancel = cancel;
    final t0 = DateTime.now();
    state = SweepState(running: true, collector: collector, startedAt: t0);
    String? error;
    try {
      await ctl.exclusive(ConnectionState.sweeping, (client) async {
        final engine = SweepEngine(client);
        await for (final ev in engine.run(params, last: last, cancel: cancel)) {
          collector.add(ev);
          state = state.copyWith(collector: collector);
        }
      });
    } catch (e) {
      error = e.toString();
    }
    final dur = DateTime.now().difference(t0);
    int? id;
    if (save && (collector.pointCount > 0 || error != null)) {
      try {
        final repo = await ref.read(repositoryProvider.future);
        final session = await ref.read(sessionProvider.notifier).ensure();
        id = await repo.saveSweep(
          session,
          readingId: readingId,
          params: params,
          traces: collector.traces,
          startedAt: t0,
          duration: dur,
          cancelled: cancel.isCancelled,
          error: error,
        );
      } catch (e) {
        error ??= 'save failed: $e';
      }
    }
    state = SweepState(
      running: false,
      collector: collector,
      error: error,
      savedId: id,
      startedAt: t0,
      duration: dur,
    );
    try {
      await ctl.refreshRails();
    } catch (_) {}
  }

  void cancel() => _cancel?.cancel();

  void clear() => state = const SweepState();
}

final sweepProvider = StateNotifierProvider<SweepNotifier, SweepState>(
  (ref) => SweepNotifier(ref),
);
