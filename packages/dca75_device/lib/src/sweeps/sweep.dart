import 'dart:math' as math;

import 'package:dca75_protocol/dca75_protocol.dart';

enum SweepNeed { bjt, fet, none }

enum SweepKind {
  icvce('Ic / Vce family', 'Vce (V)', 'Ic (mA)', SweepNeed.bjt,
      'Collector family: one trace per base current. Needs a BJT identify result first.'),
  hfeic('hFE vs Ic', 'Ic (mA)', 'hFE', SweepNeed.bjt,
      'Gain vs collector current at a held Vce — the germanium matching curve. Needs a BJT result.'),
  idvds('Id / Vds family', 'Vds (V)', 'Id (mA)', SweepNeed.fet,
      'Drain family: one trace per Vgs. Needs a JFET or MOSFET identify result.'),
  idvgs('Id / Vgs transfer', 'Vgs (V)', 'Id (mA)', SweepNeed.fet,
      'Transfer curve at a held Vds — reads pinch-off and Idss straight off the plot.'),
  pniv('PN junction I-V', 'Vf (V)', 'I (mA)', SweepNeed.none,
      'Two-lead junction sweep. Pick which clips hold the part; current limits at ~12 mA.');

  const SweepKind(this.title, this.xLabel, this.yLabel, this.need, this.hint);
  final String title, xLabel, yLabel, hint;
  final SweepNeed need;

  static SweepKind fromName(String n) => values.firstWhere((k) => k.name == n);

  /// Whether this sweep can run given the last identify result.
  bool canRun(IdentifyResult? last) => switch (need) {
        SweepNeed.none => true,
        SweepNeed.bjt => last?.type == ComponentType.bjt,
        SweepNeed.fet => last != null &&
            (last.type == ComponentType.jfet ||
                last.type == ComponentType.mosfet),
      };
}

/// Which clip holds which junction terminal, and what to do with the spare.
enum ThirdLead {
  open('Open'),
  r470kToVs('470k to Vs'),
  r470kToGnd('470k to 0V'),
  lowToAnode('Low Ω to anode'),
  lowToCathode('Low Ω to cathode');

  const ThirdLead(this.label);
  final String label;
}

sealed class SweepParams {
  const SweepParams();
  SweepKind get kind;
  Map<String, Object?> toJson();

  static SweepParams fromJson(Map<String, Object?> j) {
    double d(String k) => (j[k] as num).toDouble();
    int i(String k) => (j[k] as num).toInt();
    return switch (SweepKind.fromName(j['kind'] as String)) {
      SweepKind.icvce => IcVceParams(
          vcMin: d('vcMin'),
          vcMax: d('vcMax'),
          points: i('points'),
          traces: i('traces'),
          ibMinUa: d('ibMinUa'),
          ibMaxUa: d('ibMaxUa')),
      SweepKind.hfeic => HfeIcParams(
          vce: d('vce'),
          points: i('points'),
          ibMinUa: d('ibMinUa'),
          ibMaxUa: d('ibMaxUa')),
      SweepKind.idvds => IdVdsParams(
          vdsMin: d('vdsMin'),
          vdsMax: d('vdsMax'),
          points: i('points'),
          traces: i('traces'),
          vgsMin: d('vgsMin'),
          vgsMax: d('vgsMax')),
      SweepKind.idvgs => IdVgsParams(
          vds: d('vds'),
          points: i('points'),
          vgsMin: d('vgsMin'),
          vgsMax: d('vgsMax')),
      SweepKind.pniv => PnIvParams(
          vMin: d('vMin'),
          vMax: d('vMax'),
          points: i('points'),
          anode: Lead.fromLabel(j['anode'] as String),
          cathode: Lead.fromLabel(j['cathode'] as String),
          thirdLead: ThirdLead.values.byName(j['thirdLead'] as String),
          forward: j['forward'] as bool),
    };
  }
}

class IcVceParams extends SweepParams {
  const IcVceParams({
    this.vcMin = 0,
    this.vcMax = 12,
    this.points = 51,
    this.traces = 5,
    this.ibMinUa = 2,
    this.ibMaxUa = 10,
  });
  final double vcMin, vcMax, ibMinUa, ibMaxUa;
  final int points, traces;
  @override
  SweepKind get kind => SweepKind.icvce;
  @override
  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'vcMin': vcMin,
        'vcMax': vcMax,
        'points': points,
        'traces': traces,
        'ibMinUa': ibMinUa,
        'ibMaxUa': ibMaxUa,
      };
  IcVceParams copyWith(
          {double? vcMin,
          double? vcMax,
          int? points,
          int? traces,
          double? ibMinUa,
          double? ibMaxUa}) =>
      IcVceParams(
          vcMin: vcMin ?? this.vcMin,
          vcMax: vcMax ?? this.vcMax,
          points: points ?? this.points,
          traces: traces ?? this.traces,
          ibMinUa: ibMinUa ?? this.ibMinUa,
          ibMaxUa: ibMaxUa ?? this.ibMaxUa);
}

class HfeIcParams extends SweepParams {
  const HfeIcParams(
      {this.vce = 5, this.points = 21, this.ibMinUa = 1, this.ibMaxUa = 50});
  final double vce, ibMinUa, ibMaxUa;
  final int points;
  @override
  SweepKind get kind => SweepKind.hfeic;
  @override
  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'vce': vce,
        'points': points,
        'ibMinUa': ibMinUa,
        'ibMaxUa': ibMaxUa
      };
  HfeIcParams copyWith(
          {double? vce, int? points, double? ibMinUa, double? ibMaxUa}) =>
      HfeIcParams(
          vce: vce ?? this.vce,
          points: points ?? this.points,
          ibMinUa: ibMinUa ?? this.ibMinUa,
          ibMaxUa: ibMaxUa ?? this.ibMaxUa);
}

class IdVdsParams extends SweepParams {
  const IdVdsParams({
    this.vdsMin = 0,
    this.vdsMax = 12,
    this.points = 51,
    this.traces = 5,
    this.vgsMin = -3,
    this.vgsMax = 0,
  });
  final double vdsMin, vdsMax, vgsMin, vgsMax;
  final int points, traces;
  @override
  SweepKind get kind => SweepKind.idvds;
  @override
  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'vdsMin': vdsMin,
        'vdsMax': vdsMax,
        'points': points,
        'traces': traces,
        'vgsMin': vgsMin,
        'vgsMax': vgsMax,
      };
  IdVdsParams copyWith(
          {double? vdsMin,
          double? vdsMax,
          int? points,
          int? traces,
          double? vgsMin,
          double? vgsMax}) =>
      IdVdsParams(
          vdsMin: vdsMin ?? this.vdsMin,
          vdsMax: vdsMax ?? this.vdsMax,
          points: points ?? this.points,
          traces: traces ?? this.traces,
          vgsMin: vgsMin ?? this.vgsMin,
          vgsMax: vgsMax ?? this.vgsMax);
}

class IdVgsParams extends SweepParams {
  const IdVgsParams(
      {this.vds = 5, this.points = 41, this.vgsMin = -3, this.vgsMax = 0});
  final double vds, vgsMin, vgsMax;
  final int points;
  @override
  SweepKind get kind => SweepKind.idvgs;
  @override
  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'vds': vds,
        'points': points,
        'vgsMin': vgsMin,
        'vgsMax': vgsMax
      };
  IdVgsParams copyWith(
          {double? vds, int? points, double? vgsMin, double? vgsMax}) =>
      IdVgsParams(
          vds: vds ?? this.vds,
          points: points ?? this.points,
          vgsMin: vgsMin ?? this.vgsMin,
          vgsMax: vgsMax ?? this.vgsMax);
}

class PnIvParams extends SweepParams {
  const PnIvParams({
    this.vMin = 0,
    this.vMax = 5,
    this.points = 51,
    this.anode = Lead.red,
    this.cathode = Lead.green,
    this.thirdLead = ThirdLead.open,
    this.forward = true,
  });
  final double vMin, vMax;
  final int points;
  final Lead anode, cathode;
  final ThirdLead thirdLead;
  final bool forward;
  @override
  SweepKind get kind => SweepKind.pniv;
  @override
  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'vMin': vMin,
        'vMax': vMax,
        'points': points,
        'anode': anode.label,
        'cathode': cathode.label,
        'thirdLead': thirdLead.name,
        'forward': forward,
      };
  PnIvParams copyWith(
          {double? vMin,
          double? vMax,
          int? points,
          Lead? anode,
          Lead? cathode,
          ThirdLead? thirdLead,
          bool? forward}) =>
      PnIvParams(
          vMin: vMin ?? this.vMin,
          vMax: vMax ?? this.vMax,
          points: points ?? this.points,
          anode: anode ?? this.anode,
          cathode: cathode ?? this.cathode,
          thirdLead: thirdLead ?? this.thirdLead,
          forward: forward ?? this.forward);
}

/// Port of `applyResultDefaults`: sensible parameters given the last
/// identify result.
SweepParams defaultsFor(SweepKind kind, IdentifyResult? last) {
  final hfe = last?.type == ComponentType.bjt ? last?.hfe : null;
  final vgsOff =
      last?.type == ComponentType.jfet ? (last?.vgsOff ?? -3.0) : null;
  switch (kind) {
    case SweepKind.icvce:
      if (hfe != null && hfe > 0) {
        final imax = 10000 / hfe; // µA for ~10 mA Ic
        final step = math.max((imax / 5).round(), 1).toDouble();
        return IcVceParams(ibMinUa: step, ibMaxUa: step * 5, traces: 5);
      }
      return const IcVceParams();
    case SweepKind.hfeic:
      if (hfe != null && hfe > 0) {
        final imax = 10000 / hfe;
        final lo =
            math.max(double.parse((imax / 50).toStringAsPrecision(2)), 0.1);
        return HfeIcParams(ibMinUa: lo, ibMaxUa: imax.roundToDouble());
      }
      return const HfeIcParams();
    case SweepKind.idvds:
      if (vgsOff != null) {
        return IdVdsParams(
            vgsMin: double.parse(vgsOff.toStringAsPrecision(3)), vgsMax: 0);
      }
      return const IdVdsParams();
    case SweepKind.idvgs:
      if (vgsOff != null) {
        return IdVgsParams(
            vgsMin: double.parse(vgsOff.toStringAsPrecision(3)), vgsMax: 0);
      }
      return const IdVgsParams();
    case SweepKind.pniv:
      // A diode identify tells us which clip holds the anode (gate lead)
      // and the cathode (MT1 lead); start the sweep forward-biased.
      final pins = last?.type == ComponentType.diode ? last?.pins : null;
      if (pins != null && pins.length == 2) {
        final a = pins.firstWhere((p) => p.terminal == 'A').lead;
        final k = pins.firstWhere((p) => p.terminal == 'K').lead;
        if (a != k && a != Lead.none && k != Lead.none) {
          return PnIvParams(anode: a, cathode: k);
        }
      }
      return const PnIvParams();
  }
}

sealed class SweepEvent {
  const SweepEvent();
}

class SweepTraceStarted extends SweepEvent {
  const SweepTraceStarted(this.index, this.label);
  final int index;
  final String label;
}

class SweepPoint extends SweepEvent {
  const SweepPoint(this.trace, this.x, this.y);
  final int trace;
  final double x, y;
}

class SweepProgress extends SweepEvent {
  const SweepProgress(this.percent);
  final double percent;
}

class SweepMessage extends SweepEvent {
  const SweepMessage(this.text);
  final String text;
}

class SweepTrace {
  SweepTrace(this.index, this.label);
  final int index;
  final String label;
  final List<({double x, double y})> points = [];
}

/// Accumulates [SweepEvent]s into traces; the shape that gets plotted and
/// stored.
class SweepCollector {
  SweepCollector(this.params);
  final SweepParams params;
  final List<SweepTrace> traces = [];
  double progress = 0;
  final List<String> messages = [];

  void add(SweepEvent e) {
    switch (e) {
      case SweepTraceStarted(:final index, :final label):
        traces.add(SweepTrace(index, label));
      case SweepPoint(:final trace, :final x, :final y):
        traces[trace].points.add((x: x, y: y));
      case SweepProgress(:final percent):
        progress = percent;
      case SweepMessage(:final text):
        messages.add(text);
    }
  }

  int get pointCount => traces.fold(0, (n, t) => n + t.points.length);

  /// `trace,x,y` CSV, same as the reference client's export.
  String toCsv() {
    final sb = StringBuffer('trace,x,y\n');
    for (final t in traces) {
      for (final p in t.points) {
        sb.writeln('"${t.label}",${p.x},${p.y}');
      }
    }
    return sb.toString();
  }
}
