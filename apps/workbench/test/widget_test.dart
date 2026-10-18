import 'dart:typed_data';

import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workbench/widgets/curve_plot.dart';
import 'package:workbench/widgets/pinout.dart';
import 'package:workbench/widgets/result_card.dart';

Uint8List bjtFrame({int cfg = 3}) {
  final b = Uint8List(64)..[0] = 0x85;
  final d = ByteData.sublistView(b);
  b[2] = 1;
  b[3] = cfg;
  b[4] = bjtFlagNpn | bjtFlagSilicon;
  final f = [0.001, 0.71, 0.65, 0.024, 0.005, 212.4, 5.0, 0.09, 10, 1, 0, 0];
  for (var i = 0; i < f.length; i++) {
    d.setFloat32(5 + 4 * i, f[i].toDouble(), Endian.little);
  }
  return b;
}

void main() {
  testWidgets('ResultCard renders a BJT with pinout and params', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final r = decodeResult(Response(bjtFrame()));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: ResultCard(result: r)),
        ),
      ),
    );
    expect(find.text('NPN BJT'), findsOneWidget);
    expect(find.text('SILICON'), findsOneWidget);
    expect(find.text('hFE (gain)'), findsOneWidget);
    expect(find.text('212.4'), findsOneWidget);
    expect(find.text('710 mV'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('B on Blue lead')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('E on Green lead')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('C on Red lead')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('ResultCard with no result shows placeholder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ResultCard(result: null))),
    );
    expect(find.text('—'), findsOneWidget);
    expect(find.text('No parameters.'), findsOneWidget);
  });

  testWidgets('PinoutWidget colors follow the lead', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PinoutWidget(pins: pinsFor(1, const ['E', 'C', 'B'])),
        ),
      ),
    );
    expect(find.text('E'), findsOneWidget);
    expect(find.text('RED'), findsOneWidget);
    expect(find.text('GREEN'), findsOneWidget);
    expect(find.text('BLUE'), findsOneWidget);
  });

  testWidgets('CurvePlot draws traces without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CurvePlot(
            traces: const [
              PlotTrace(
                label: 'a',
                color: Colors.red,
                points: [(x: 0.0, y: 0.0), (x: 1.0, y: 2.0), (x: 2.0, y: 3.5)],
              ),
            ],
            xLabel: 'Vce (V)',
            yLabel: 'Ic (mA)',
            height: 300,
          ),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('CurvePlot hover snaps the readout to the nearest sample', (
    tester,
  ) async {
    const traces = [
      PlotTrace(
        label: 'a',
        color: Colors.red,
        points: [(x: 0.0, y: 0.0), (x: 1.0, y: 2.0), (x: 2.0, y: 3.5)],
      ),
    ];
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CurvePlot(
            traces: traces,
            xLabel: 'Vce (V)',
            yLabel: 'Ic (mA)',
            height: 300,
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byType(CurvePlot));
    final axes = PlotAxes(traces, Size(box.width - 2, 300 - 2));
    // Slightly off the sample, so the readout has to snap to it.
    final near =
        box.topLeft +
        const Offset(1, 1) +
        Offset(axes.px(1) + 6, axes.py(2) - 4);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(near);
    await tester.pump();
    expect(find.text('a   Vce (V): 1.000   Ic (mA): 2.000'), findsOneWidget);

    await mouse.moveTo(box.bottomRight + const Offset(0, 50));
    await tester.pump();
    expect(find.textContaining('Vce (V):'), findsNothing);
  });

  test('PlotAxes.nearest ignores pointers outside the plot', () {
    const traces = [
      PlotTrace(
        label: 'a',
        color: Colors.red,
        points: [(x: 0.0, y: 0.0), (x: 1.0, y: 1.0)],
      ),
    ];
    final axes = PlotAxes(traces, const Size(600, 300));
    expect(axes.nearest(traces, const Offset(5, 5)), isNull);
    expect(axes.nearest(const [], const Offset(200, 150)), isNull);
    expect(axes.nearest(traces, const Offset(200, 150))?.trace.label, 'a');
  });

  test('niceTicks', () {
    expect(niceTicks(0, 10), [0, 2, 4, 6, 8, 10]);
    expect(niceTicks(0, 1).first, 0);
    expect(niceTicks(5, 5).length, greaterThan(1));
  });
}
