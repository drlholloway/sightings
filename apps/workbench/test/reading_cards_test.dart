import 'package:dca75_store/dca75_store.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workbench/features/circuits/circuits_screen.dart';
import 'package:workbench/widgets/circuit_fit_card.dart';
import 'package:workbench/widgets/dca55_card.dart';
import 'package:workbench/widgets/leakage_card.dart';
import 'package:workbench/widgets/section_card.dart';

import 'support.dart';

void main() {
  testWidgets('A reading shows its stored DCA55 and leakage figures', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    final id = s.bjtIds.first;
    await ReadingsRepository(db).saveExtraParams(id, {
      'hfe_dca55': (188.0, ''),
      'ic_dca55': (0.0025, 'A'),
      'ib_dca55': (0.0000133, 'A'),
      'vce_dca55': (2.5, 'V'),
      'vbe_point_dca55': (0.655, 'V'),
      'vbe_dca55': (0.61, 'V'),
      'ib_vbe_dca55': (0.00001, 'A'),
      'ic_leak_dca55': (0.0000002, 'A'),
      'converged_dca55': (0, ''),
      'leak_icbo_5v': (0.00000002, 'A'),
      'leak_vcbo_5v': (5.0, 'V'),
      'leak_icbo_10v': (0.000000001, 'A'),
      'leak_vcbo_10v': (10.0, 'V'),
    });
    await pumpApp(tester, database: db);
    await goTo(tester, '/history/$id');

    final dca55 = find.byType(Dca55Card);
    Finder inCard(Finder card, Finder f) =>
        find.descendant(of: card, matching: f);
    expect(inCard(dca55, find.text('DCA55‑EQUIVALENT')), findsOneWidget);
    expect(inCard(dca55, find.text('hFE (DCA55)')), findsOneWidget);
    expect(inCard(dca55, find.textContaining('188')), findsOneWidget);
    expect(inCard(dca55, find.text('Vce held')), findsOneWidget);
    expect(
      inCard(dca55, find.textContaining('did not settle on 2.50 mA')),
      findsOneWidget,
    );
    expect(
      inCard(dca55, find.textContaining('DCA75 identify: hFE 200')),
      findsOneWidget,
    );
    expect(inCard(dca55, find.byType(ValueRow)), findsNWidgets(6));

    final leak = find.byType(LeakageCard);
    expect(inCard(leak, find.text('REVERSE LEAKAGE')), findsOneWidget);
    expect(inCard(leak, find.textContaining('Icbo @')), findsNWidgets(2));
    expect(inCard(leak, find.text('< 5 nA')), findsOneWidget);
    expect(
      inCard(leak, find.textContaining('DCA75 identify Ic leakage')),
      findsOneWidget,
    );

    // Not connected, so neither card offers to measure.
    expect(find.text('Measure'), findsNothing);
    expect(find.text('Re‑measure'), findsNothing);
    // Pedal Builder is off, so there is no circuits card.
    expect(find.text('PEDAL CIRCUITS'), findsNothing);
  });

  testWidgets('A diode reading says leakage is not measured yet', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    await pumpApp(tester, database: db);
    await goTo(tester, '/history/${s.diodeId}');
    expect(find.byType(Dca55Card), findsNothing);
    expect(
      find.descendant(
        of: find.byType(LeakageCard),
        matching: find.text('Not measured yet.'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('reverse-biased through 470 kΩ'), findsOne);
  });

  testWidgets('The circuits card follows the Pedal Builder settings', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    await pumpApp(
      tester,
      database: db,
      // The marker alone means the user turned every circuit off.
      prefs: {
        'pedalBuilder': true,
        'activeCircuits': <String>['__touched__'],
      },
    );
    await goTo(tester, '/history/${s.bjtIds.first}');
    final card = find.byType(CircuitFitCard);
    expect(
      find.descendant(of: card, matching: find.text('PEDAL CIRCUITS')),
      findsOneWidget,
    );
    expect(find.textContaining('No circuits are active.'), findsOneWidget);

    await tester.ensureVisible(find.text('Edit circuits'));
    await settle(tester);
    await tester.tap(find.text('Edit circuits'));
    await settle(tester);
    expect(find.byType(CircuitsScreen), findsOneWidget);
  });

  testWidgets('The circuits card lists where a transistor fits', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    final s = await seed(db);
    await pumpApp(
      tester,
      database: db,
      prefs: {
        'pedalBuilder': true,
        'activeCircuits': <String>[
          '__touched__',
          'fuzz_face_si',
          'fuzz_face_ge',
        ],
      },
    );
    await goTo(tester, '/history/${s.bjtIds.first}');
    final card = find.byType(CircuitFitCard);
    Finder inCard(Finder f) => find.descendant(of: card, matching: f);
    // A silicon NPN with hFE 200 is judged against the active circuits.
    expect(
      inCard(find.text('Valid for')).evaluate().isNotEmpty ||
          inCard(find.text('Not for')).evaluate().isNotEmpty,
      isTrue,
    );
    expect(inCard(find.textContaining('No active circuit')), findsNothing);
  });

  testWidgets('Cards measure on the demo unit from the Identify tab', (
    tester,
  ) async {
    await pumpApp(tester, demo: true);
    await pumpUntil(tester, find.textContaining('s/n DEMO01'));
    await tester.tap(find.widgetWithText(FilledButton, 'Test'));
    await pumpUntil(tester, find.textContaining('saved #1'));

    final dca55 = find.byType(Dca55Card);
    final leak = find.byType(LeakageCard);
    await tester.ensureVisible(dca55);
    await settle(tester);
    await tester.tap(
      find.descendant(of: dca55, matching: find.text('Measure')),
    );
    await pumpUntil(
      tester,
      find.descendant(of: dca55, matching: find.text('Re‑measure')),
    );
    expect(
      find.descendant(of: dca55, matching: find.text('hFE (DCA55)')),
      findsOneWidget,
    );

    await tester.ensureVisible(leak);
    await settle(tester);
    await tester.tap(find.descendant(of: leak, matching: find.text('Measure')));
    await pumpUntil(
      tester,
      find.descendant(of: leak, matching: find.text('Re‑measure')),
    );
    expect(
      find.descendant(of: leak, matching: find.textContaining('Icbo @')),
      findsWidgets,
    );

    await tester.tap(find.text('Disconnect'));
    await pumpUntil(tester, find.text('Connect'));
  });
}
