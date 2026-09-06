import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/format.dart';
import '../../services/providers.dart';
import '../../widgets/curve_plot.dart';
import 'sweep_controller.dart';

class CurvesScreen extends ConsumerStatefulWidget {
  const CurvesScreen({super.key, this.sweepId});

  /// When given, the saved sweep is loaded as an overlay.
  final int? sweepId;

  @override
  ConsumerState<CurvesScreen> createState() => _CurvesScreenState();
}

/// Sweeps that apply to the identified component, in menu order. The
/// two-lead PN sweep needs no identify and is always offered last.
List<SweepKind> sweepKindsFor(IdentifyResult? last) =>
    SweepKind.values.where((k) => k.canRun(last)).toList();

class _CurvesScreenState extends ConsumerState<CurvesScreen> {
  SweepKind _kind = SweepKind.icvce;
  SweepParams _params = const IcVceParams();
  final _plotKey = GlobalKey();
  bool _saveWithReading = true;
  int? _defaultsFor;

  /// Saved sweeps overlaid on the plot.
  final Map<int, SweepDetail> _overlays = {};
  List<SweepRow> _saved = const [];

  @override
  void initState() {
    super.initState();
    if (widget.sweepId != null) _loadOverlay(widget.sweepId!);
    _refreshSaved();
  }

  @override
  void didUpdateWidget(CurvesScreen old) {
    super.didUpdateWidget(old);
    if (widget.sweepId != null && widget.sweepId != old.sweepId) {
      _loadOverlay(widget.sweepId!);
    }
  }

  Future<void> _loadOverlay(int id) async {
    final repo = await ref.read(repositoryProvider.future);
    final d = await repo.loadSweep(id);
    if (!mounted || d == null) return;
    setState(() {
      _overlays[id] = d;
      _kind = d.params.kind;
      _params = d.params;
    });
  }

  Future<void> _refreshSaved() async {
    final repo = await ref.read(repositoryProvider.future);
    final last = ref.read(lastResultProvider);
    final rows = last?.readingId != null
        ? await repo.listSweeps(readingId: last!.readingId)
        : await repo.listSweeps(limit: 30);
    if (!mounted) return;
    setState(() => _saved = rows);
  }

  void _applyDefaults(IdentifyResult? last) {
    setState(() => _params = defaultsFor(_kind, last));
  }

  /// Keep [_kind] within the applicable set, switching to the first
  /// applicable sweep (and its defaults) when the component changes.
  void _selectKindFor(IdentifyResult? last) {
    final kinds = sweepKindsFor(last);
    if (!kinds.contains(_kind)) _kind = kinds.first;
    _params = defaultsFor(_kind, last);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = ref.watch(statusProvider);
    final last = ref.watch(lastResultProvider);
    final sweep = ref.watch(sweepProvider);
    final lastResult = last?.result;

    // Auto-fill parameters when a new identify result arrives.
    final key = last?.readingId ?? last?.draft?.seq;
    if (key != null && key != _defaultsFor) {
      _defaultsFor = key;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _selectKindFor(lastResult));
          _refreshSaved();
        }
      });
    }

    final canRun =
        status.state == ConnectionState.idle &&
        !sweep.running &&
        _kind.canRun(lastResult);
    final traces = <PlotTrace>[
      if (sweep.collector != null && sweep.collector!.params.kind == _kind)
        ...PlotTrace.fromSweep(sweep.collector!.traces),
      for (final (i, o) in _overlays.values.indexed)
        if (o.params.kind == _kind)
          ...PlotTrace.fromSweep(
            o.traces,
            colorOffset: 3 * (i + 1),
            prefix: '#${o.row.id} ',
          ),
    ];

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownMenu<SweepKind>(
              key: ValueKey('${lastResult?.typeCode}-${_kind.name}'),
              initialSelection: _kind,
              label: const Text('Curve'),
              dropdownMenuEntries: [
                for (final k in sweepKindsFor(lastResult))
                  DropdownMenuEntry(value: k, label: k.title),
              ],
              onSelected: (k) {
                if (k == null) return;
                setState(() {
                  _kind = k;
                  _params = defaultsFor(k, lastResult);
                });
              },
            ),
            ..._paramFields(),
            TextButton(
              onPressed: () => _applyDefaults(lastResult),
              child: const Text('Defaults'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _kind.hint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (lastResult != null)
          Text(
            'Based on: ${lastResult.name}${last!.readingId != null
                ? ' (#${last.readingId})'
                : last.isDraft
                ? ' (draft)'
                : ''}',
            style: theme.textTheme.bodySmall,
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            FilledButton.icon(
              onPressed: sweep.running
                  ? ref.read(sweepProvider.notifier).cancel
                  : canRun
                  ? () => ref
                        .read(sweepProvider.notifier)
                        .start(
                          _params,
                          last: lastResult,
                          readingId: _saveWithReading ? last?.readingId : null,
                        )
                        .then((_) => _refreshSaved())
                  : null,
              icon: Icon(sweep.running ? Icons.stop : Icons.play_arrow),
              label: Text(sweep.running ? 'Stop' : 'Start'),
            ),
            const SizedBox(width: 12),
            if (sweep.running)
              SizedBox(
                width: 180,
                child: LinearProgressIndicator(
                  value: (sweep.collector?.progress ?? 0) / 100,
                ),
              ),
            if (!sweep.running && sweep.collector != null)
              Text(
                '${sweep.collector!.pointCount} points in ${((sweep.duration?.inMilliseconds ?? 0) / 1000).toStringAsFixed(1)} s'
                '${sweep.savedId != null ? ' · saved sweep #${sweep.savedId}' : ''}'
                '${sweep.error != null ? ' · ${sweep.error}' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: sweep.error != null ? theme.colorScheme.error : null,
                ),
              ),
            const Spacer(),
            if (last?.readingId != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _saveWithReading,
                    onChanged: (v) =>
                        setState(() => _saveWithReading = v ?? true),
                  ),
                  Text(
                    'link to reading #${last!.readingId}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            IconButton(
              tooltip: 'Clear plot',
              icon: const Icon(Icons.layers_clear_outlined),
              onPressed: () {
                ref.read(sweepProvider.notifier).clear();
                setState(_overlays.clear);
              },
            ),
            IconButton(
              tooltip: 'Export CSV',
              icon: const Icon(Icons.table_chart_outlined),
              onPressed: traces.isEmpty ? null : () => _exportCsv(traces),
            ),
            IconButton(
              tooltip: 'Export PNG',
              icon: const Icon(Icons.image_outlined),
              onPressed: traces.isEmpty ? null : _exportPng,
            ),
          ],
        ),
        const SizedBox(height: 10),
        RepaintBoundary(
          key: _plotKey,
          child: CurvePlot(
            traces: traces,
            xLabel: _kind.xLabel,
            yLabel: _kind.yLabel,
          ),
        ),
        const SizedBox(height: 12),
        if (_saved.isNotEmpty) ...[
          Text(
            'SAVED SWEEPS${last?.readingId != null ? ' FOR READING #${last!.readingId}' : ''} — tick to overlay',
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 0.8,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          for (final s in _saved)
            CheckboxListTile(
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              value: _overlays.containsKey(s.id),
              title: Text('#${s.id} ${s.kind.title}'),
              subtitle: Text(
                '${fmtDateTime(s.startedAt)} · ${s.traceCount} traces · ${s.pointCount} pts${s.cancelled ? ' · cancelled' : ''}',
              ),
              secondary: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  final repo = await ref.read(repositoryProvider.future);
                  await repo.deleteSweep(s.id);
                  _overlays.remove(s.id);
                  await _refreshSaved();
                },
              ),
              onChanged: (on) {
                if (on == true) {
                  _loadOverlay(s.id);
                } else {
                  setState(() => _overlays.remove(s.id));
                }
              },
            ),
        ],
      ],
    );
  }

  List<Widget> _paramFields() {
    Widget num(
      String label,
      double value,
      void Function(double) set, {
      bool integer = false,
    }) => SizedBox(
      width: 96,
      child: TextFormField(
        key: ValueKey('$label-${_params.kind.name}-$value'),
        initialValue: integer ? value.toInt().toString() : tick(value),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        onFieldSubmitted: (s) {
          final v = double.tryParse(s);
          if (v != null) setState(() => set(v));
        },
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    );
    Widget lead(String label, Lead value, void Function(Lead) set) =>
        DropdownMenu<Lead>(
          initialSelection: value,
          label: Text(label),
          width: 120,
          dropdownMenuEntries: [
            for (final l in [Lead.red, Lead.green, Lead.blue])
              DropdownMenuEntry(value: l, label: l.label),
          ],
          onSelected: (l) => l == null ? null : setState(() => set(l)),
        );
    switch (_params) {
      case IcVceParams p:
        return [
          num('Vce min', p.vcMin, (v) => _params = p.copyWith(vcMin: v)),
          num('Vce max', p.vcMax, (v) => _params = p.copyWith(vcMax: v)),
          num(
            'Points',
            p.points.toDouble(),
            (v) => _params = p.copyWith(points: v.toInt()),
            integer: true,
          ),
          num(
            'Traces',
            p.traces.toDouble(),
            (v) => _params = p.copyWith(traces: v.toInt()),
            integer: true,
          ),
          num('Ib min µA', p.ibMinUa, (v) => _params = p.copyWith(ibMinUa: v)),
          num('Ib max µA', p.ibMaxUa, (v) => _params = p.copyWith(ibMaxUa: v)),
        ];
      case HfeIcParams p:
        return [
          num('Vce (V)', p.vce, (v) => _params = p.copyWith(vce: v)),
          num(
            'Points',
            p.points.toDouble(),
            (v) => _params = p.copyWith(points: v.toInt()),
            integer: true,
          ),
          num('Ib min µA', p.ibMinUa, (v) => _params = p.copyWith(ibMinUa: v)),
          num('Ib max µA', p.ibMaxUa, (v) => _params = p.copyWith(ibMaxUa: v)),
        ];
      case IdVdsParams p:
        return [
          num('Vds min', p.vdsMin, (v) => _params = p.copyWith(vdsMin: v)),
          num('Vds max', p.vdsMax, (v) => _params = p.copyWith(vdsMax: v)),
          num(
            'Points',
            p.points.toDouble(),
            (v) => _params = p.copyWith(points: v.toInt()),
            integer: true,
          ),
          num(
            'Traces',
            p.traces.toDouble(),
            (v) => _params = p.copyWith(traces: v.toInt()),
            integer: true,
          ),
          num('Vgs min', p.vgsMin, (v) => _params = p.copyWith(vgsMin: v)),
          num('Vgs max', p.vgsMax, (v) => _params = p.copyWith(vgsMax: v)),
        ];
      case IdVgsParams p:
        return [
          num('Vds (V)', p.vds, (v) => _params = p.copyWith(vds: v)),
          num(
            'Points',
            p.points.toDouble(),
            (v) => _params = p.copyWith(points: v.toInt()),
            integer: true,
          ),
          num('Vgs min', p.vgsMin, (v) => _params = p.copyWith(vgsMin: v)),
          num('Vgs max', p.vgsMax, (v) => _params = p.copyWith(vgsMax: v)),
        ];
      case PnIvParams p:
        return [
          num('V min', p.vMin, (v) => _params = p.copyWith(vMin: v)),
          num('V max', p.vMax, (v) => _params = p.copyWith(vMax: v)),
          num(
            'Points',
            p.points.toDouble(),
            (v) => _params = p.copyWith(points: v.toInt()),
            integer: true,
          ),
          lead('Anode', p.anode, (l) => _params = p.copyWith(anode: l)),
          lead('Cathode', p.cathode, (l) => _params = p.copyWith(cathode: l)),
          DropdownMenu<ThirdLead>(
            initialSelection: p.thirdLead,
            label: const Text('Third lead'),
            width: 170,
            dropdownMenuEntries: [
              for (final t in ThirdLead.values)
                DropdownMenuEntry(value: t, label: t.label),
            ],
            onSelected: (t) => t == null
                ? null
                : setState(() => _params = p.copyWith(thirdLead: t)),
          ),
          DropdownMenu<bool>(
            initialSelection: p.forward,
            label: const Text('Bias'),
            width: 130,
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: true, label: 'Forward'),
              DropdownMenuEntry(value: false, label: 'Reverse'),
            ],
            onSelected: (f) => f == null
                ? null
                : setState(() => _params = p.copyWith(forward: f)),
          ),
        ];
    }
  }

  Future<void> _exportCsv(List<PlotTrace> traces) async {
    final sb = StringBuffer('trace,x,y\n');
    for (final t in traces) {
      for (final p in t.points) {
        sb.writeln('"${t.label}",${p.x},${p.y}');
      }
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(sb.toString().codeUnits),
            mimeType: 'text/csv',
            name:
                'dca-${_kind.name}-${DateTime.now().millisecondsSinceEpoch}.csv',
          ),
        ],
      ),
    );
  }

  Future<void> _exportPng() async {
    final boundary =
        _plotKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes.buffer.asUint8List(),
            mimeType: 'image/png',
            name:
                'dca-${_kind.name}-${DateTime.now().millisecondsSinceEpoch}.png',
          ),
        ],
      ),
    );
  }
}
