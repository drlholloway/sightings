import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dca55.dart' show Dca55State;
import 'providers.dart';
import 'settings.dart';

/// Reverse-leakage measurement for the diode reading being shown; same
/// shape as the DCA55 state so the cards can share logic.
class LeakageNotifier extends StateNotifier<Dca55State> {
  LeakageNotifier(this.ref) : super(const Dca55State());
  final Ref ref;

  Future<void> measure(int readingId, IdentifyResult r) async {
    final ak = diodeLeadsOf(r);
    if (state.running || ak == null) return;
    state = Dca55State(readingId: readingId, running: true);
    try {
      final ctl = ref.read(controllerProvider);
      final params = await ctl.exclusive(
        ConnectionState.sweeping,
        (client) => LeakageMeasurement(client).measurePoints(ak.$1, ak.$2),
      );
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

  void clear() {
    if (!state.running) state = const Dca55State();
  }
}

final leakageProvider = StateNotifierProvider<LeakageNotifier, Dca55State>(
  (ref) => LeakageNotifier(ref),
);

bool leakAutoApplies(Ref ref, IdentifyResult r) =>
    ref.read(settingsProvider).leakAuto &&
    r.type == ComponentType.diode &&
    diodeLeadsOf(r) != null;
