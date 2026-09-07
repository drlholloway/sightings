import 'package:dca75_device/dca75_device.dart';
import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/format.dart';
import '../../services/drafts.dart';
import '../../services/providers.dart';
import '../../widgets/dca55_card.dart';
import '../../widgets/histogram.dart';
import '../../widgets/leakage_card.dart';
import '../../widgets/result_card.dart';
import '../../widgets/tag_strip.dart';

class IdentifyScreen extends ConsumerStatefulWidget {
  const IdentifyScreen({super.key});

  @override
  ConsumerState<IdentifyScreen> createState() => _IdentifyScreenState();
}

class _IdentifyScreenState extends ConsumerState<IdentifyScreen> {
  bool _testing = false;
  String? _error;

  /// Tag values being edited for the current draft (kept until Save).
  TagValues _draftTag = const TagValues();
  int? _draftSeq;

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _error = null;
    });
    try {
      await ref.read(controllerProvider).identify();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _saveDraft(Draft d) async {
    final intake = ref.read(intakeProvider);
    final id = await intake.saveDraft(d);
    final tag = _draftTag;
    if (!tag.isEmpty) {
      final repo = await ref.read(repositoryProvider.future);
      await repo.tagReading(
        id,
        partId: tag.partId,
        binId: tag.binId,
        label: tag.label,
        notes: tag.notes,
        starred: tag.starred,
      );
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved reading #$id')));
    }
  }

  Future<void> _saveAllDrafts() async {
    final drafts = List<Draft>.from(ref.read(draftsProvider));
    final tag = _draftTag;
    final intake = ref.read(intakeProvider);
    final repo = await ref.read(repositoryProvider.future);
    var n = 0;
    for (final d in drafts) {
      final id = await intake.saveDraft(d);
      if (!tag.isEmpty) {
        await repo.tagReading(
          id,
          partId: tag.partId,
          binId: tag.binId,
          label: tag.label,
          notes: tag.notes,
          starred: tag.starred,
        );
      }
      n++;
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved $n readings')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(statusProvider);
    final last = ref.watch(lastResultProvider);
    final drafts = ref.watch(draftsProvider);
    final theme = Theme.of(context);
    final canTest = status.state == ConnectionState.idle && !_testing;

    final draft = last?.draft;
    if (draft != null && draft.seq != _draftSeq) {
      _draftSeq = draft.seq;
      _draftTag = _draftTag.copyWith(
        label: '',
        notes: '',
        starred: false,
      ); // keep part/bin for batch tagging
    }

    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.space): const _TestIntent(),
        const SingleActivator(LogicalKeyboardKey.enter): const _SaveIntent(),
        const SingleActivator(LogicalKeyboardKey.backspace):
            const _DiscardIntent(),
        const SingleActivator(LogicalKeyboardKey.delete):
            const _DiscardIntent(),
      },
      child: Actions(
        actions: {
          _TestIntent: _ScreenAction<_TestIntent>(
            enabled: canTest,
            onInvoke: (_) => _test(),
          ),
          _SaveIntent: _ScreenAction<_SaveIntent>(
            enabled: draft != null,
            onInvoke: (_) => _saveDraft(draft!),
          ),
          _DiscardIntent: _ScreenAction<_DiscardIntent>(
            enabled: draft != null,
            onInvoke: (_) => ref.read(intakeProvider).discardDraft(draft!),
          ),
        },
        child: Focus(
          autofocus: true,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: canTest ? _test : null,
                    icon: _testing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bolt),
                    label: Text(_testing ? 'Testing…' : 'Test'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      status.state == ConnectionState.idle
                          ? 'Or press the button on the unit; the result appears here as a draft.'
                          : status.isConnected
                          ? 'Device busy (${status.state.name}).'
                          : 'Connect a DCA75 to test.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              const SizedBox(height: 14),
              if (drafts.length > 1)
                _DraftsTray(
                  drafts: drafts,
                  current: draft,
                  onSaveAll: _saveAllDrafts,
                ),
              LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 900;
                  final card = _buildCard(last, draft);
                  final side = _Sidebar(
                    last: last,
                    draftTag: draft == null ? null : _draftTag,
                  );
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 420, child: card),
                        const SizedBox(width: 18),
                        Expanded(child: side),
                      ],
                    );
                  }
                  return Column(
                    children: [card, const SizedBox(height: 18), side],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(LastResult? last, Draft? draft) {
    final theme = Theme.of(context);
    final r = last?.result;
    Widget? header;
    Widget? trailing;
    if (draft != null) {
      header = Row(
        children: [
          Icon(Icons.edit_note, color: theme.colorScheme.tertiary, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'DRAFT — not saved · unit button · ${fmtTime(draft.event.at)}',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlinedButton(
            onPressed: () => ref.read(intakeProvider).discardDraft(draft),
            child: const Text('Discard'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () => _saveDraft(draft),
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
          ),
        ],
      );
    } else if (last?.readingId != null) {
      header = Text(
        'saved #${last!.readingId} · ${fmtTime(last.event.at)}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResultCard(result: r, header: header, trailing: trailing),
        if (r != null && r.type.isComponent) ...[
          // DCA55-equivalent figures sit directly under the DCA75 result,
          // before the tagging strip.
          if (r.type == ComponentType.bjt && last?.readingId != null) ...[
            const SizedBox(height: 12),
            Dca55Card(
              readingId: last!.readingId!,
              result: r,
              stored: const {},
              canMeasure:
                  ref.watch(statusProvider).state == ConnectionState.idle,
            ),
          ],
          if (r.type == ComponentType.diode && last?.readingId != null) ...[
            const SizedBox(height: 12),
            LeakageCard(
              readingId: last!.readingId!,
              result: r,
              stored: const {},
              canMeasure:
                  ref.watch(statusProvider).state == ConnectionState.idle,
            ),
          ],
          const SizedBox(height: 12),
          if (draft != null)
            TagStrip(
              value: _draftTag,
              family: r.type.name,
              onChanged: (v) => setState(() => _draftTag = v),
            )
          else if (last?.readingId != null)
            SavedReadingTagStrip(
              key: ValueKey(last!.readingId),
              readingId: last.readingId!,
              family: r.type.name,
              onChanged: (_) => setState(() {}),
            ),
        ],
      ],
    );
  }
}

/// Screen-level keyboard action that steps aside whenever a text field has
/// focus, so Enter / Space / Backspace still reach the field. A disabled
/// action leaves the key event unhandled, which lets it propagate.
class _ScreenAction<T extends Intent> extends CallbackAction<T> {
  _ScreenAction({required this.enabled, required super.onInvoke});
  final bool enabled;

  static bool get _textFieldFocused {
    final ctx = FocusManager.instance.primaryFocus?.context;
    if (ctx == null) return false;
    // The focused node belongs to a Focus widget inside the EditableText.
    return ctx.widget is EditableText ||
        ctx.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  @override
  bool isEnabled(T intent) => enabled && !_textFieldFocused;
}

class _TestIntent extends Intent {
  const _TestIntent();
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _DiscardIntent extends Intent {
  const _DiscardIntent();
}

class _DraftsTray extends ConsumerWidget {
  const _DraftsTray({
    required this.drafts,
    required this.current,
    required this.onSaveAll,
  });
  final List<Draft> drafts;
  final Draft? current;
  final Future<void> Function() onSaveAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final d in drafts)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(
                          '${d.result.name} · ${fmtTime(d.event.at)}',
                        ),
                        selected: d.seq == current?.seq,
                        onSelected: (_) {
                          ref.read(draftsProvider.notifier).select(d);
                          ref
                              .read(lastResultProvider.notifier)
                              .set(LastResult(event: d.event, draft: d));
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: onSaveAll,
            child: Text('Save all ${drafts.length}'),
          ),
          TextButton(
            onPressed: () {
              ref.read(draftsProvider.notifier).clear();
              ref.read(lastResultProvider.notifier).set(null);
            },
            child: Text(
              'Discard all',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Where does this fall?" — bin statistics for the current result.
class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.last, required this.draftTag});
  final LastResult? last;
  final TagValues? draftTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = last?.result;
    if (r == null || !r.type.isComponent) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Clip a component in, press Test (or the unit button), then pick a part and bin to see where it falls among its siblings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return _BinContext(
      result: r,
      readingId: last!.readingId,
      draftTag: draftTag,
    );
  }
}

class _BinContext extends ConsumerStatefulWidget {
  const _BinContext({
    required this.result,
    required this.readingId,
    required this.draftTag,
  });
  final IdentifyResult result;
  final int? readingId;
  final TagValues? draftTag;

  @override
  ConsumerState<_BinContext> createState() => _BinContextState();
}

class _BinContextState extends ConsumerState<_BinContext> {
  int? _binId;
  int? _partId;
  Map<String, BinStats> _stats = const {};
  String? _binName;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_BinContext old) {
    super.didUpdateWidget(old);
    _load();
  }

  Future<void> _load() async {
    final repo = await ref.read(repositoryProvider.future);
    int? binId = widget.draftTag?.binId;
    int? partId = widget.draftTag?.partId;
    if (widget.readingId != null) {
      final d = await repo.loadReading(widget.readingId!);
      binId = d?.tag.binId;
      partId = d?.tag.partId;
      _binName = d?.row.binName;
    } else if (binId != null) {
      final bins = await repo.listBins(partId: partId);
      _binName = bins.where((b) => b.id == binId).firstOrNull?.name;
    }
    if (binId == null && partId == null) {
      if (mounted) setState(() => _stats = const {});
      return;
    }
    final keys = headlineKeysFor(widget.result.type)
        .where((k) => widget.result.headline.containsKey(k));
    final out = <String, BinStats>{};
    for (final k in keys) {
      out[k] = await repo.binStats(
        k,
        binId: binId,
        partId: binId == null ? partId : null,
      );
    }
    if (!mounted) return;
    setState(() {
      _binId = binId;
      _partId = partId;
      _stats = out;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_stats.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _binId == null && _partId == null
                ? 'Choose a part (and a bin) to compare this reading with others of the same part.'
                : 'No other readings in this ${_binId != null ? 'bin' : 'part'} yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    final scope = _binId != null ? 'bin “${_binName ?? ''}”' : 'this part';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHERE DOES THIS FALL?',
              style: theme.textTheme.labelMedium?.copyWith(
                letterSpacing: 1,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            for (final e in _stats.entries)
              if (e.value.n > 0) ...[
                Builder(
                  builder: (context) {
                    final v = widget.result.headline[e.key]!;
                    final pct = e.value.percentileOf(v);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${labelFor(e.key)} ${fmtValue(e.key, v)} — ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      '${pct.round()}th percentile of ${e.value.n} in $scope '
                                      '(median ${fmtValue(e.key, e.value.median)}, '
                                      'range ${fmtValue(e.key, e.value.min)} – ${fmtValue(e.key, e.value.max)})',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          HistogramChart(stats: e.value, marker: v, height: 64),
                        ],
                      ),
                    );
                  },
                ),
              ],
          ],
        ),
      ),
    );
  }
}
