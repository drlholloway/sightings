import 'package:dca75_store/dca75_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workbench/features/history/history_screen.dart';
import 'package:workbench/services/providers.dart';

import 'support.dart';

void main() {
  testWidgets('History lists readings and filters them', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await seed(db);
    await pumpApp(tester, database: db);
    await goTo(tester, '/history');

    expect(find.text('NPN BJT'), findsNWidgets(7));
    expect(find.textContaining('bin Lot A'), findsNWidgets(7));
    expect(find.textContaining('FF Q2'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(2)); // the chip and one row

    // Free-text search.
    await tester.enterText(find.byType(TextField), 'FF Q2');
    await settle(tester);
    expect(find.byType(ListTile), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await settle(tester);
    expect(find.byType(ListTile), findsNWidgets(8));

    // By type.
    await tester.tap(find.widgetWithText(FilterChip, 'Diode'));
    await settle(tester);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('NPN BJT'), findsNothing);
    await tester.tap(find.widgetWithText(FilterChip, 'Diode'));
    await settle(tester);

    // Untagged: only the diode has no part.
    await tester.tap(find.widgetWithText(FilterChip, 'Untagged'));
    await settle(tester);
    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'Untagged'));
    await settle(tester);

    // Starred.
    await tester.tap(find.widgetWithIcon(FilterChip, Icons.star));
    await settle(tester);
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.textContaining('FF Q2'), findsOneWidget);
  });

  testWidgets('History tags and deletes the selected readings', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    final repo = ReadingsRepository(db);
    await repo.createBin(s.partId, 'Lot B');
    await pumpApp(tester, database: db);
    await goTo(tester, '/history');

    // The diode is newest, so it is the first row.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('1 selected'), findsOneWidget);

    // Tag it with the part and a bin.
    await tester.tap(find.text('Tag…'));
    await settle(tester);
    expect(find.text('Tag 1 readings'), findsOneWidget);
    await tester.tap(find.text('Part'));
    await settle(tester);
    await tester.tap(find.text('2N5088 (Fairchild)').last);
    await settle(tester);
    await tester.tap(find.text('Bin'));
    await settle(tester);
    await tester.tap(find.text('Lot B').last);
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await settle(tester);
    final tagged = await repo.loadReading(s.diodeId);
    expect(tagged!.tag.partId, s.partId);
    expect(find.textContaining('bin Lot B'), findsOneWidget);
    expect(find.textContaining('selected'), findsNothing);

    // Cancelling the tag dialog changes nothing.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await tester.tap(find.text('Tag…'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await settle(tester);
    expect(find.text('1 selected'), findsOneWidget);

    // Clear drops the selection.
    await tester.tap(find.widgetWithText(TextButton, 'Clear'));
    await tester.pump();
    expect(find.textContaining('selected'), findsNothing);

    // Delete two, after confirming.
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    expect(find.text('2 selected'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);
    expect(find.text('Delete 2 readings?'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await settle(tester);
    expect(await repo.countReadings(), 8);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await settle(tester);
    expect(await repo.countReadings(), 6);
    expect(find.byType(ListTile), findsNWidgets(6));
  });

  testWidgets('History shows an empty state and the part/bin filter chip', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    await pumpApp(tester, database: db);
    await goTo(tester, '/history');
    expect(find.text('No readings yet.'), findsOneWidget);

    containerOf(tester)
        .read(historyFilterProvider.notifier)
        .state = const ReadingFilter(
      partId: 1,
    );
    await settle(tester);
    expect(find.text('part/bin filter'), findsOneWidget);
    await tester.tap(find.byTooltip('Delete'));
    await settle(tester);
    expect(find.text('part/bin filter'), findsNothing);
    expect(containerOf(tester).read(historyFilterProvider).partId, isNull);
  });

  testWidgets('A reading opens with its cards, details and sweeps', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    await pumpApp(tester, database: db);
    await goTo(tester, '/history');

    // Rows are newest first: the diode, then the BJTs in reverse.
    await tester.tap(find.text('NPN BJT').last);
    await settle(tester);
    final id = s.bjtIds.first;
    expect(find.text('Reading #$id'), findsOneWidget);
    expect(find.text('Taken'), findsOneWidget);
    expect(find.text('Source'), findsOneWidget);
    expect(find.text('app'), findsOneWidget);
    expect(find.text('Session'), findsOneWidget);
    expect(find.text('#${s.session}'), findsOneWidget);
    expect(find.text('SWEEPS'), findsOneWidget);
    expect(find.text('Ic / Vce family'), findsOneWidget);
    expect(find.textContaining('1 traces · 3 points'), findsOneWidget);

    // The saved sweep opens on the Curves tab as an overlay.
    await tester.tap(find.text('Ic / Vce family'));
    await settle(tester);
    expect(find.textContaining('SAVED SWEEPS'), findsOneWidget);
    expect(find.text('#${s.sweepId} Ic / Vce family'), findsOneWidget);
    expect(
      tester
          .widget<CheckboxListTile>(find.byType(CheckboxListTile).first)
          .value,
      isTrue,
    );

    // "Use for curves" carries the reading over.
    await goTo(tester, '/history/$id');
    await tester.tap(find.text('Use for curves'));
    await settle(tester);
    expect(find.textContaining('Based on: NPN BJT (#$id)'), findsOneWidget);
    expect(containerOf(tester).read(lastResultProvider)!.readingId, id);
  });

  testWidgets('A reading from the unit button, on a narrow window', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    await pumpApp(tester, database: db, size: const Size(800, 1600));
    await goTo(tester, '/history/${s.diodeId}');
    expect(find.text('Reading #${s.diodeId}'), findsOneWidget);
    expect(find.text('unit button'), findsOneWidget);
    expect(find.text('None yet.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    expect(find.byType(HistoryScreen), findsOneWidget);
  });

  testWidgets('A reading that does not exist says so', (tester) async {
    await pumpApp(tester);
    await goTo(tester, '/history/999');
    expect(find.text('Reading not found.'), findsOneWidget);
  });
}
