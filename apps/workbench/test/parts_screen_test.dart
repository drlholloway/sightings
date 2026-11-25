import 'package:dca75_store/dca75_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workbench/features/history/history_screen.dart';
import 'package:workbench/features/history/reading_detail_screen.dart';
import 'package:workbench/features/parts/bin_screen.dart';
import 'package:workbench/features/parts/part_screen.dart';
import 'package:workbench/features/parts/parts_screen.dart';
import 'package:workbench/widgets/histogram.dart';

import 'support.dart';

void main() {
  testWidgets('Parts starts empty and creates a part', (tester) async {
    final db = await pumpApp(tester);
    final repo = ReadingsRepository(db);
    await goTo(tester, '/parts');
    expect(find.textContaining('No parts yet.'), findsOneWidget);

    // Cancel, and Create with no part number, add nothing.
    await tester.tap(find.text('New part'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await settle(tester);
    await tester.tap(find.text('New part'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await settle(tester);
    expect(await repo.listParts(), isEmpty);

    await tester.tap(find.text('New part'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextField, 'Part number'),
      'AC128',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Manufacturer (optional)'),
      'Mullard',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Description (optional)'),
      'germanium PNP',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await settle(tester);
    expect(find.text('AC128 (Mullard)'), findsOneWidget);
    expect(
      find.textContaining('germanium PNP · 0 readings · 0 bins'),
      findsOneWidget,
    );
    final part = (await repo.listParts()).single;
    expect(part.manufacturer, 'Mullard');
  });

  testWidgets('A part lists its bins and statistics', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    final repo = ReadingsRepository(db);
    await pumpApp(tester, database: db);
    await goTo(tester, '/parts');
    expect(find.textContaining('7 readings · 1 bins'), findsOneWidget);

    await tester.tap(find.text('2N5088 (Fairchild)'));
    await settle(tester);
    expect(find.byType(PartScreen), findsOneWidget);
    expect(find.text('low-noise NPN'), findsOneWidget);
    expect(find.text('BINS'), findsOneWidget);
    expect(find.text('Lot A'), findsOneWidget);
    expect(find.text('ALL READINGS OF THIS PART'), findsOneWidget);
    expect(find.text('Parameter'), findsOneWidget);

    // A new bin: cancelled, then created.
    await tester.tap(find.text('New bin'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await settle(tester);
    await tester.tap(find.text('New bin'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Lot B');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await settle(tester);
    expect(find.text('Lot B'), findsOneWidget);
    expect((await repo.listBins(partId: s.partId)).length, 2);

    // The readings button opens History filtered to this part.
    await tester.tap(find.text('7 readings'));
    await settle(tester);
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(find.text('part/bin filter'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(7));
    expect(containerOf(tester).read(historyFilterProvider).partId, s.partId);
    containerOf(tester).read(historyFilterProvider.notifier).state =
        const ReadingFilter();

    // Back from the part goes to the list.
    await goTo(tester, '/parts/${s.partId}');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    expect(find.byType(PartsScreen), findsOneWidget);
  });

  testWidgets('A bin shows statistics, outliers and closest matches', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    await pumpApp(tester, database: db);
    await goTo(tester, '/parts/${s.partId}');
    await tester.tap(find.text('Lot A'));
    await settle(tester);
    expect(find.byType(BinScreen), findsOneWidget);
    expect(find.text('2N5088 (Fairchild) — bin “Lot A”'), findsOneWidget);

    // hFE is the first parameter; the 900 reading is outside the fences.
    expect(find.text('hFE distribution'), findsOneWidget);
    expect(find.textContaining('1 of 7 readings fall outside'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsNWidgets(2));
    expect(find.byType(HistogramChart), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(7));

    // Picking a member lists the closest others.
    final first = s.bjtIds.first;
    await tester.tap(find.widgetWithText(ChoiceChip, '#$first 200.0'));
    await settle(tester);
    expect(find.text('Closest to #$first by hFE:'), findsOneWidget);
    expect(find.textContaining('#${s.bjtIds[1]}  205'), findsOneWidget);

    // Another parameter resets the pick.
    await tester.tap(find.text('Vbe @ 5 mA'));
    await settle(tester);
    expect(find.text('Vbe @ 5 mA distribution'), findsOneWidget);
    expect(find.textContaining('Closest to'), findsNothing);

    // A closest match opens that reading.
    await tester.tap(find.text('hFE'));
    await settle(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, '#$first 200.0'));
    await settle(tester);
    await tester.tap(find.textContaining('#${s.bjtIds[1]}  205'));
    await settle(tester);
    expect(find.byType(ReadingDetailScreen), findsOneWidget);
    expect(find.text('Reading #${s.bjtIds[1]}'), findsOneWidget);
  });

  testWidgets('A bin links to its readings and back to its part', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    final empty = await ReadingsRepository(db).createBin(s.partId, 'Empty');
    await pumpApp(tester, database: db);

    await goTo(tester, '/bins/$empty');
    expect(find.text('No measured values yet.'), findsOneWidget);
    expect(find.text('0 readings'), findsOneWidget);

    // Through the part, as the app does: the bin screen loads once.
    await goTo(tester, '/parts/${s.partId}');
    await tester.tap(find.text('Lot A'));
    await settle(tester);
    await tester.tap(find.text('7 readings'));
    await settle(tester);
    expect(find.byType(HistoryScreen), findsOneWidget);
    expect(containerOf(tester).read(historyFilterProvider).binId, s.binId);
    containerOf(tester).read(historyFilterProvider.notifier).state =
        const ReadingFilter();

    await goTo(tester, '/bins/${s.binId}');
    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    expect(find.byType(PartScreen), findsOneWidget);
  });
}
