import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An identify result picked up from the unit's own button that has not
/// been saved yet. Held in memory only.
class Draft {
  Draft({required this.event, int? seq}) : seq = seq ?? _next++;
  static int _next = 1;
  final int seq;
  final IdentifyEvent event;
  IdentifyResult get result => event.result;
}

class DraftsNotifier extends StateNotifier<List<Draft>> {
  DraftsNotifier() : super(const []);

  void add(IdentifyEvent e) => state = [...state, Draft(event: e)];

  Draft? get current => state.isEmpty ? null : state.first;

  void remove(Draft d) => state = state.where((x) => x.seq != d.seq).toList();

  void clear() => state = const [];

  /// Move a draft to the front so it is the one shown.
  void select(Draft d) => state = [d, ...state.where((x) => x.seq != d.seq)];
}

final draftsProvider = StateNotifierProvider<DraftsNotifier, List<Draft>>(
  (ref) => DraftsNotifier(),
);
