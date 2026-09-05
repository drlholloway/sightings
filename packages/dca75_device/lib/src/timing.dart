/// Injectable sleep so tests can run sweeps without real delays.
typedef Sleep = Future<void> Function(Duration d);

Future<void> realSleep(Duration d) => Future<void>.delayed(d);

/// A sleep that yields to the event loop without waiting.
Future<void> noSleep(Duration d) => Future<void>.value();

/// Cooperative cancellation for identify and sweep loops.
class CancelToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}
