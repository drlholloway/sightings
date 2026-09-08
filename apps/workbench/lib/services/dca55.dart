import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'providers.dart';
import 'settings.dart';

/// State of the DCA55-equivalent measurement for the reading being shown.
class Dca55State {
  const Dca55State({
    this.readingId,
    this.running = false,
    this.result,
    this.error,
  });
  final int? readingId;
  final bool running;
  final Map<String, (double, String)>? result;
  final String? error;
}

/// Runs the DCA55-equivalent BJT measurement through the device controller's
/// exclusive lock and attaches the figures to the reading.
class Dca55Notifier extends StateNotifier<Dca55State> {
  Dca55Notifier(this.ref) : super(const Dca55State());
  final Ref ref;

  Future<void> measure(int readingId, IdentifyResult r) async {
    if (state.running || r.type != ComponentType.bjt) return;
    state = Dca55State(readingId: readingId, running: true);
    try {
      final ctl = ref.read(controllerProvider);
      final res = await ctl.exclusive(
        ConnectionState.sweeping,
        (client) => Dca55Measurement(client).run(r.config, hfeEstimate: r.hfe),
      );
      final params = res.toParams();
      final repo = await ref.read(repositoryProvider.future);
      await repo.saveExtraParams(readingId, params);
      state = Dca55State(readingId: readingId, result: params);
      try {
        await ctl.refreshRails();
      } catch (_) {}
    } catch (e) {
      state = Dca55State(readingId: readingId, error: e.toString());
    }
  }

  /// Show previously stored figures for a reading.
  void show(int readingId, Map<String, (double, String)> extras) {
    if (state.running) return;
    state = Dca55State(
      readingId: readingId,
      result: extras.isEmpty ? null : extras,
    );
  }

  void clear() {
    if (!state.running) state = const Dca55State();
  }
}

final dca55Provider = StateNotifierProvider<Dca55Notifier, Dca55State>(
  (ref) => Dca55Notifier(ref),
);

/// Whether the automatic run is enabled and applies to this result.
bool dca55AutoApplies(Ref ref, IdentifyResult r) =>
    ref.read(settingsProvider).dca55Auto && r.type == ComponentType.bjt;
