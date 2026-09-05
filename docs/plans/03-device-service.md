# Phase 3 — Device service

**Goal:** the single object the UI talks to. Owns the transport, the protocol mirror, the
connection state machine, the idle poller that catches unit‑button tests, the identify flow,
rail readings, and the shutdown sequence. Lives in `apps/workbench/lib/device/`.

**Effort:** 2–3 days. **Hardware:** yes for final verification; all logic unit‑testable
with `FakeTransport`.

## State machine

```
disconnected ──open()──▶ connecting ──STATE ok, CAL read, ADCS rails──▶ idle
idle ──identify()──▶ testing ──TESTED + ack + TEST(2)──▶ idle (emits IdentifyResult)
idle ──poll sees TESTED──▶ fetching ──ack + TEST(2)──▶ idle (emits IdentifyResult, source=unitButton)
idle ──startSweep()──▶ sweeping ──done/cancel/error──▶ idle
any ──transport detached / fatal error──▶ disconnected (after shutdown sequence if possible)
```

Exposed as a Riverpod `StateNotifier<DeviceStatus>` with:

```dart
class DeviceStatus { ConnectionState state; DeviceIdentity? identity; Calibration? cal;
                     Rails? rails; String? lastError; }
class DeviceIdentity { String serial, hardwareRev, firmwareRev, productName; }
class Rails { double batt, v12, vRef, rMt2; DateTime at; }
```

and streams: `Stream<IdentifyEvent>` (result + source + timestamp), `Stream<LogLine>`.

## Tasks

1. **Connect sequence** — `open` → `STATE(ack=idle)` → `parseState` (identity, rMt2) →
   `CAL` read (tolerate failure) → `ADCS(direct=0x1F)` for rails → state idle → start poller.
   Any failure: `close`, state disconnected with `lastError`.

2. **Poller** — every 600 ms while idle and not sweeping: `STATE(idle)`; if TESTED,
   `STATE(ack=130)` → `TEST(2)` → decode → emit with `source = unitButton`. Transient errors
   are swallowed; a “device gone” error transitions to disconnected. The poller must yield to
   `identify()`/sweeps (they take a lock; the poller skips a tick if the lock is held).

3. **Identify** — `TEST(1)`; poll `STATE(idle)` every 150 ms up to 15 s; on TESTED → ack →
   `TEST(2)` → decode; then refresh rails. Timeout → error “test timed out”, state back to idle.

4. **Rails refresh** — `ADCS(direct=0x1F)`; update `Rails` and the mirror; called after
   connect, after every identify, after every sweep. Low battery / USB‑fail result types (10/11)
   surface as a banner, not as a reading.

5. **Shutdown sequence** — `safeShutdown()`: LEADSAFE, CCGATE OFF, CVGATE OFF, MODE NONE,
   each in its own try/catch. Called on: disconnect request, app pause/detach lifecycle,
   any sweep error, and `dispose`.

6. **Auto‑connect** — on app start and on every attach event, if exactly one DCA75 is present,
   connect automatically (setting, default on). Android: the app is launched by the attach
   intent; on resume, retry `hasPermission` and connect.

7. **Persistence hook** — `IdentifyEvent`s are handed to an app‑level `ReadingIntake`
   listener; the service itself does not know about the database.
   - `source == app`: intake calls `ReadingsRepository.saveReading` immediately and returns
     the `readingId` to the UI for tagging.
   - `source == unitButton`: intake appends the event to a `DraftsNotifier` (in‑memory queue
     holding the full `IdentifyResult`, rails snapshot and timestamp). Nothing is written
     until the user presses **Save** on the draft; **Discard** drops it. `taken_at` on save is
     the original capture time, not the save time.
   - Drafts are in‑memory only (see PLAN.md decisions); the app asks before quitting if any
     drafts remain.

8. **Tests** with `FakeTransport`
   - connect happy path populates identity/cal/rails;
   - identify: TESTED after 3 polls → result emitted; never TESTED → timeout error and idle;
   - poller picks up a unit‑button test and acks exactly once;
   - transport failure mid‑identify → shutdown sequence frames observed → disconnected;
   - poller does not send STATE while a sweep holds the lock.

## Acceptance criteria
- On hardware: connect shows serial/fw matching the unit; app‑initiated identify and
  unit‑button identify both produce a result card; unplugging mid‑session returns the UI to
  disconnected without a crash; replugging auto‑reconnects.
- All FakeTransport tests green.
