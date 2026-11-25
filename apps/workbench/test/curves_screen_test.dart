import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workbench/features/curves/sweep_controller.dart';
import 'package:workbench/services/providers.dart';
import 'package:workbench/widgets/curve_plot.dart';

import 'support.dart';

/// The traces the plot is drawing.
List<PlotTrace> plotted(WidgetTester tester) =>
    tester.widget<CurvePlot>(find.byType(CurvePlot)).traces;

/// Identifies demo part [index] from the app and waits for the reading.
Future<void> identifyDemoPart(
  WidgetTester tester,
  int index,
  int readingId,
) async {
  await goTo(tester, '/identify');
  containerOf(tester).read(demoUnitProvider)!.selectPart(index);
  await tester.tap(find.widgetWithText(FilledButton, 'Test'));
  await pumpUntil(tester, find.textContaining('saved #$readingId'));
}

Future<void> disconnect(WidgetTester tester) async {
  await tester.tap(find.text('Disconnect'));
  await pumpUntil(tester, find.text('Connect'));
}

void main() {
  testWidgets('Curves runs a sweep on the demo unit and saves it', (
    tester,
  ) async {
    final db = await pumpApp(tester, demo: true);
    final repo = ReadingsRepository(db);
    await pumpUntil(tester, find.textContaining('s/n DEMO01'));

    // Nothing identified yet: the two-lead junction sweep and its fields.
    await goTo(tester, '/curves');
    expect(find.textContaining('Based on:'), findsNothing);
    expect(find.textContaining('Two-lead junction sweep'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'V max'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Vce max'), findsNothing);

    await identifyDemoPart(tester, 0, 1);
    await goTo(tester, '/curves');
    expect(find.textContaining('Based on: NPN BJT (#1)'), findsOneWidget);
    expect(find.text('link to reading #1'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Vce max'), findsOneWidget);
    expect(plotted(tester), isEmpty);

    // Run the collector family.
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await pumpUntil(tester, find.textContaining('saved sweep #1'));
    expect(find.textContaining('points in'), findsOneWidget);
    expect(plotted(tester), isNotEmpty);
    final saved = (await repo.listSweeps()).single;
    expect(saved.readingId, 1);
    expect(saved.kind, SweepKind.icvce);
    expect(saved.traceCount, plotted(tester).length);

    // It is listed, and ticking it overlays it on the live traces.
    await pumpUntil(tester, find.text('#1 Ic / Vce family'));
    expect(find.textContaining('SAVED SWEEPS FOR READING #1'), findsOneWidget);
    final live = plotted(tester).length;
    await tester.tap(find.byType(CheckboxListTile));
    await settle(tester);
    expect(plotted(tester).length, live * 2);
    expect(plotted(tester).last.label, startsWith('#1 '));
    await tester.tap(find.byType(CheckboxListTile));
    await settle(tester);
    expect(plotted(tester).length, live);

    // Clear plot drops the live traces too.
    await tester.tap(find.byTooltip('Clear plot'));
    await settle(tester);
    expect(plotted(tester), isEmpty);
    expect(containerOf(tester).read(sweepProvider).collector, isNull);

    // Unlinked: the next sweep is saved without the reading.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Start'));
    await pumpUntil(tester, find.textContaining('saved sweep #2'));
    expect((await repo.loadSweep(2))!.row.readingId, isNull);

    // Deleting a saved sweep removes it from the list.
    await tester.tap(find.byIcon(Icons.delete_outline));
    await settle(tester);
    expect(find.byType(CheckboxListTile), findsNothing);
    expect(await repo.loadSweep(1), isNull);

    await disconnect(tester);
  });

  testWidgets('Curves parameters follow the sweep and can be edited', (
    tester,
  ) async {
    await pumpApp(tester, demo: true);
    await pumpUntil(tester, find.textContaining('s/n DEMO01'));
    await identifyDemoPart(tester, 0, 1);
    await goTo(tester, '/curves');

    // Edit a field, then put the defaults back.
    final vceMax = find.widgetWithText(TextFormField, 'Vce max');
    final before = tester.widget<TextFormField>(vceMax).initialValue;
    await tester.enterText(vceMax, '3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);
    expect(
      tester
          .widget<TextFormField>(find.widgetWithText(TextFormField, 'Vce max'))
          .initialValue,
      '3',
    );
    await tester.tap(find.widgetWithText(TextButton, 'Defaults'));
    await settle(tester);
    expect(
      tester
          .widget<TextFormField>(find.widgetWithText(TextFormField, 'Vce max'))
          .initialValue,
      before,
    );

    // Each sweep kind brings its own fields.
    Future<void> pick(String title) async {
      await tester.tap(find.byType(DropdownMenu<SweepKind>));
      await settle(tester);
      await tester.tap(find.text(title).last);
      await settle(tester);
    }

    await pick('hFE vs Ic');
    expect(find.widgetWithText(TextFormField, 'Vce (V)'), findsOneWidget);
    expect(find.textContaining('germanium matching curve'), findsOneWidget);

    await pick('PN junction I-V');
    expect(find.widgetWithText(TextFormField, 'V max'), findsOneWidget);
    expect(find.text('Third lead'), findsWidgets);
    expect(find.text('Bias'), findsWidgets);

    await pick('Reverse leakage I-V');
    expect(find.widgetWithText(TextFormField, 'Vr max'), findsOneWidget);

    // A JFET swaps the BJT sweeps for the FET ones.
    await identifyDemoPart(tester, 2, 2);
    await goTo(tester, '/curves');
    await settle(tester);
    expect(find.textContaining('(#2)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Vds max'), findsOneWidget);
    await pick('Id / Vgs transfer');
    expect(find.widgetWithText(TextFormField, 'Vds (V)'), findsOneWidget);
    expect(find.text('Ic / Vce family'), findsNothing);

    await disconnect(tester);
  });

  testWidgets('Curves lists recent sweeps and opens one by link', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    await pumpApp(tester, database: db);
    await goTo(tester, '/curves?sweep=${s.sweepId}');

    expect(find.textContaining('SAVED SWEEPS — tick to overlay'), findsOne);
    expect(find.textContaining('1 traces · 3 pts'), findsOneWidget);
    expect(plotted(tester).single.label, '#${s.sweepId} Ib 10 µA');
    // Not connected, so nothing can be started.
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Start'))
          .onPressed,
      isNull,
    );
  });
}
