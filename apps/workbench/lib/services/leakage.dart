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

  /// Junction to reverse-bias and the key prefixes for the reading type.
  static ({Lead anode, Lead cathode, String prefix, String voltPrefix})?
  planFor(IdentifyResult r) {
    final d = diodeLeadsOf(r);
    if (d != null) {
      return (anode: d.$1, cathode: d.$2, prefix: 'ir', voltPrefix: 'vr');
    }
    final cb = bjtCbJunction(r);
    if (cb != null) {
      return (anode: cb.$1, cathode: cb.$2, prefix: 'icbo', voltPrefix: 'vcbo');
    }
    return null;
  }

  Future<void> measure(int readingId, IdentifyResult r) async {
    final plan = planFor(r);
    if (state.running || plan == null) return;
    state = Dca55State(readingId: readingId, running: true);
    try {
      final ctl = ref.read(controllerProvider);
      final params = await ctl.exclusive(
        ConnectionState.sweeping,
        (client) => LeakageMeasurement(client).measurePoints(
          plan.anode,
          plan.cathode,
          prefix: plan.prefix,
          voltPrefix: plan.voltPrefix,
        ),
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
    ref.read(settingsProvider).leakAuto && LeakageNotifier.planFor(r) != null;
