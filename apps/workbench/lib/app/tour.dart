// Developer-only screenshot tour for the wiki.
//
// Compiled in only when SIGHTINGS_TOUR is defined:
//   flutter build macos --debug --dart-define=SIGHTINGS_TOUR=/path/to/out
//   SIGHTINGS_WINDOW=1280x840 build/macos/.../Sightings.app/Contents/MacOS/Sightings
//
// The tour switches on the demo device, records a handful of readings into a
// throw-away database, walks every screen and writes a PNG of each. Settings
// are kept in memory for the run, so the user's own preferences and database
// are never touched.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dca75_device/dca75_device.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/curves/sweep_controller.dart';
import '../services/circuits.dart';
import '../services/dca55.dart';
import '../services/leakage.dart';
import '../services/providers.dart';
import '../services/settings.dart';
import 'router.dart';

/// Output directory; empty when the tour is not compiled in.
const tourDir = String.fromEnvironment('SIGHTINGS_TOUR');
bool get tourEnabled => tourDir.isNotEmpty;

/// Wraps the whole app so it can be rasterized.
final tourBoundaryKey = GlobalKey();

class Tour {
  Tour(this.ref);
  final WidgetRef ref;

  Directory get _out => Directory(tourDir);

  Future<void> run() async {
    try {
      await _run();
      stdout.writeln('tour: done, screenshots in ${_out.path}');
    } catch (e, st) {
      stderr.writeln('tour: failed: $e\n$st');
    } finally {
      exit(0);
    }
  }

  Future<void> _run() async {
    _out.createSync(recursive: true);
    await _settle();

    // Demo device on, every feature on, light theme, all circuits active.
    final s = ref.read(settingsProvider);
    await ref
        .read(settingsProvider.notifier)
        .update(
          s.copyWith(
            demoMode: true,
            pedalBuilder: true,
            themeMode: 'light',
            dca55Auto: true,
            leakAuto: true,
            activeCircuits: {for (final c in ref.read(circuitsProvider)) c.id},
          ),
        );
    await _waitFor(
      () => ref.read(controllerProvider).status.state == ConnectionState.idle,
      'demo device connected',
    );
    await _waitFor(() => ref.read(sessionProvider) != null, 'session');

    final repo = await ref.read(repositoryProvider.future);
    final ctl = ref.read(controllerProvider);
    final unit = ref.read(demoUnitProvider)!..spread = 0.06;

    // A bin of 2N5088s so the statistics pages have something to show.
    final partId = await repo.upsertPart(
      partNumber: '2N5088',
      manufacturer: 'Fairchild',
    );
    final binId = await repo.createBin(partId, 'Lot A');
    final ids = <int>[];
    for (var i = 0; i < 8; i++) {
      unit.selectPart(0);
      final id = await _identifyAndWait(ctl);
      await repo.tagReading(
        id,
        partId: partId,
        binId: binId,
        label: i == 2 ? 'FF Q2' : null,
        starred: i == 2,
      );
      ids.add(id);
    }
    // One of each of the other demo parts, so History shows the variety.
    for (final i in [1, 2, 3, 4]) {
      unit.selectPart(i);
      await _identifyAndWait(ctl);
    }

    // Identify: a fresh saved 2N5088 in its bin, so the sidebar has context.
    unit.selectPart(0);
    final lastId = await _identifyAndWait(ctl);
    await repo.tagReading(lastId, partId: partId, binId: binId);
    router.go('/history');
    await _settle();
    router.go('/identify');
    await _settle(const Duration(milliseconds: 1200));
    await _shot('identify-reading');
    _scrollToEnd();
    await _settle();
    await _shot('identify-cards');
    _scrollToEnd(top: true);
    await _settle();

    // Identify: a unit-button draft (germanium PNP) waiting to be saved.
    unit.selectPart(1);
    unit.pressButton();
    await _waitFor(
      () => ref.read(lastResultProvider)?.isDraft ?? false,
      'draft',
    );
    await _settle(const Duration(milliseconds: 1200));
    await _shot('identify-draft');
    final draft = ref.read(lastResultProvider)!.draft!;
    await ref.read(intakeProvider).saveDraft(draft);
    await _waitQuiet();

    // Curves: an Ic/Vce family on the 2N5088.
    unit.selectPart(0);
    await _identifyAndWait(ctl);
    router.go('/curves');
    await _settle();
    final last = ref.read(lastResultProvider)?.result;
    await ref
        .read(sweepProvider.notifier)
        .start(
          const IcVceParams(),
          last: last,
          readingId: ref.read(lastResultProvider)?.readingId,
        );
    await _settle(const Duration(milliseconds: 800));
    await _shot('curves-icvce');

    // Curves: PN junction I-V on the silicon diode.
    unit.selectPart(3);
    final diodeId = await _identifyAndWait(ctl);
    router.go('/identify');
    await _settle();
    router.go('/curves');
    await _settle();
    final dlast = ref.read(lastResultProvider)?.result;
    await ref
        .read(sweepProvider.notifier)
        .start(
          defaultsFor(SweepKind.pniv, dlast),
          last: dlast,
          readingId: diodeId,
        );
    await _settle(const Duration(milliseconds: 800));
    await _shot('curves-diode');

    router.go('/history');
    await _settle();
    await _shot('history');

    router.go('/history/${ids[2]}');
    await _settle(const Duration(milliseconds: 1200));
    await _shot('reading-detail');
    _scrollToEnd();
    await _settle();
    await _shot('reading-detail-cards');

    router.go('/parts');
    await _settle();
    await _shot('parts');

    router.go('/bins/$binId');
    await _settle(const Duration(milliseconds: 1200));
    await _shot('bin');

    router.go('/circuits');
    await _settle();
    await _shot('circuits');

    router.go('/settings');
    await _settle();
    await _shot('settings');

    router.go('/log');
    await _settle();
    await _shot('log');
  }

  /// Runs an app-initiated identify and waits for the saved reading and any
  /// automatic follow-up measurements to finish.
  Future<int> _identifyAndWait(DeviceController ctl) async {
    final before = ref.read(lastResultProvider)?.readingId;
    await ctl.identify();
    await _waitFor(() {
      final r = ref.read(lastResultProvider);
      return r != null && !r.isDraft && r.readingId != before;
    }, 'reading saved');
    final id = ref.read(lastResultProvider)!.readingId!;
    await _waitQuiet();
    return id;
  }

  /// Waits until the device is idle and no follow-up measurement is running,
  /// and that has held for a while: the follow-ups run one after the other
  /// with a brief idle gap between them.
  Future<void> _waitQuiet() async {
    final ctl = ref.read(controllerProvider);
    bool quiet() =>
        ctl.status.state == ConnectionState.idle &&
        !ref.read(dca55Provider).running &&
        !ref.read(leakageProvider).running;
    var held = 0;
    await _waitFor(() {
      held = quiet() ? held + 1 : 0;
      return held >= 12; // 12 polls of 50 ms
    }, 'follow-up measurements');
  }

  Future<void> _waitFor(
    bool Function() ok,
    String what, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final t0 = DateTime.now();
    while (!ok()) {
      if (DateTime.now().difference(t0) > timeout) {
        throw TimeoutException('waiting for $what');
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  }

  /// Jumps every vertical scrollable on screen to its end (or top).
  void _scrollToEnd({bool top = false}) {
    void visit(Element e) {
      if (e is StatefulElement && e.state is ScrollableState) {
        final pos = (e.state as ScrollableState).position;
        if (pos.axis == Axis.vertical && pos.maxScrollExtent > 0) {
          pos.jumpTo(top ? 0 : pos.maxScrollExtent);
        }
      }
      e.visitChildren(visit);
    }

    tourBoundaryKey.currentContext!.visitChildElements(visit);
  }

  Future<void> _settle([Duration d = const Duration(milliseconds: 500)]) async {
    await Future<void>.delayed(d);
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> _shot(String name) async {
    final boundary =
        tourBoundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final f = File('${_out.path}/$name.png');
    await f.writeAsBytes(bytes!.buffer.asUint8List());
    stdout.writeln('tour: wrote ${f.path}');
  }
}

class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
  @override
  String toString() => 'TimeoutException: $message';
}
