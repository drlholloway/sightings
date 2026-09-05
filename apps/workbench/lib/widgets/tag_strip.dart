import 'dart:async';

import 'package:dca75_store/dca75_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/providers.dart';

/// Part / bin / label / notes / star editor. Works on a saved reading (writes
/// through immediately) or on a draft (holds values until [onChanged] is
/// used by the caller to save them).
class TagValues {
  const TagValues({
    this.partId,
    this.binId,
    this.label,
    this.notes,
    this.starred = false,
  });
  final int? partId;
  final int? binId;
  final String? label;
  final String? notes;
  final bool starred;

  TagValues copyWith({
    int? partId,
    int? binId,
    String? label,
    String? notes,
    bool? starred,
    bool clearPart = false,
    bool clearBin = false,
  }) => TagValues(
    partId: clearPart ? null : (partId ?? this.partId),
    binId: clearBin ? null : (binId ?? this.binId),
    label: label ?? this.label,
    notes: notes ?? this.notes,
    starred: starred ?? this.starred,
  );

  bool get isEmpty =>
      partId == null &&
      binId == null &&
      (label?.isEmpty ?? true) &&
      (notes?.isEmpty ?? true) &&
      !starred;
}

class TagStrip extends ConsumerStatefulWidget {
  const TagStrip({
    super.key,
    required this.value,
    required this.onChanged,
    this.family,
  });
  final TagValues value;
  final ValueChanged<TagValues> onChanged;

  /// Component family used when auto-creating a part.
  final String? family;

  @override
  ConsumerState<TagStrip> createState() => _TagStripState();
}

class _TagStripState extends ConsumerState<TagStrip> {
  late final _label = TextEditingController(text: widget.value.label ?? '');
  late final _notes = TextEditingController(text: widget.value.notes ?? '');
  Timer? _debounce;

  @override
  void didUpdateWidget(TagStrip old) {
    super.didUpdateWidget(old);
    if (old.value.label != widget.value.label &&
        _label.text != (widget.value.label ?? '')) {
      _label.text = widget.value.label ?? '';
    }
    if (old.value.notes != widget.value.notes &&
        _notes.text != (widget.value.notes ?? '')) {
      _notes.text = widget.value.notes ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _label.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _text() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onChanged(
        widget.value.copyWith(label: _label.text, notes: _notes.text),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final repoAsync = ref.watch(repositoryProvider);
    final v = widget.value;
    return repoAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Text('database error: $e'),
      data: (repo) => Wrap(
        spacing: 10,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 220,
            child: _PartPicker(
              repo: repo,
              partId: v.partId,
              family: widget.family,
              onChanged: (id) => widget.onChanged(
                id == null
                    ? v.copyWith(clearPart: true, clearBin: true)
                    : v.copyWith(partId: id, clearBin: v.partId != id),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: _BinPicker(
              repo: repo,
              partId: v.partId,
              binId: v.binId,
              onChanged: (id) => widget.onChanged(
                id == null ? v.copyWith(clearBin: true) : v.copyWith(binId: id),
              ),
            ),
          ),
          SizedBox(
            width: 160,
            child: TextField(
              controller: _label,
              decoration: const InputDecoration(
                labelText: 'Label',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _text(),
            ),
          ),
          SizedBox(
            width: 260,
            child: TextField(
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _text(),
            ),
          ),
          IconButton(
            tooltip: v.starred ? 'Unstar' : 'Star',
            icon: Icon(
              v.starred ? Icons.star : Icons.star_border,
              color: v.starred ? Colors.amber.shade700 : null,
            ),
            onPressed: () => widget.onChanged(v.copyWith(starred: !v.starred)),
          ),
        ],
      ),
    );
  }
}

class _PartPicker extends StatefulWidget {
  const _PartPicker({
    required this.repo,
    required this.partId,
    required this.onChanged,
    this.family,
  });
  final ReadingsRepository repo;
  final int? partId;
  final String? family;
  final ValueChanged<int?> onChanged;

  @override
  State<_PartPicker> createState() => _PartPickerState();
}

class _PartPickerState extends State<_PartPicker> {
  List<PartRow> _parts = const [];
  StreamSubscription<List<PartRow>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.repo.watchParts().listen((p) => setState(() => _parts = p));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _parts.where((p) => p.id == widget.partId).firstOrNull;
    return Autocomplete<PartRow>(
      key: ValueKey(widget.partId),
      initialValue: TextEditingValue(text: current?.partNumber ?? ''),
      displayStringForOption: (p) => p.displayName,
      optionsBuilder: (t) {
        final q = t.text.trim().toLowerCase();
        return _parts.where(
          (p) => q.isEmpty || p.partNumber.toLowerCase().contains(q),
        );
      },
      onSelected: (p) => widget.onChanged(p.id),
      fieldViewBuilder: (context, ctl, focus, onSubmit) => TextField(
        controller: ctl,
        focusNode: focus,
        decoration: InputDecoration(
          labelText: 'Part number',
          isDense: true,
          border: const OutlineInputBorder(),
          suffixIcon: widget.partId == null
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 16),
                  onPressed: () => widget.onChanged(null),
                ),
        ),
        onSubmitted: (text) async {
          final t = text.trim();
          if (t.isEmpty) {
            widget.onChanged(null);
            return;
          }
          final existing = _parts
              .where((p) => p.partNumber.toLowerCase() == t.toLowerCase())
              .firstOrNull;
          final id =
              existing?.id ??
              await widget.repo.upsertPart(
                partNumber: t,
                family: widget.family,
              );
          widget.onChanged(id);
        },
      ),
    );
  }
}

class _BinPicker extends StatefulWidget {
  const _BinPicker({
    required this.repo,
    required this.partId,
    required this.binId,
    required this.onChanged,
  });
  final ReadingsRepository repo;
  final int? partId;
  final int? binId;
  final ValueChanged<int?> onChanged;

  @override
  State<_BinPicker> createState() => _BinPickerState();
}

class _BinPickerState extends State<_BinPicker> {
  List<BinRow> _bins = const [];
  StreamSubscription<List<BinRow>>? _sub;

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(_BinPicker old) {
    super.didUpdateWidget(old);
    if (old.partId != widget.partId) _listen();
  }

  void _listen() {
    _sub?.cancel();
    if (widget.partId == null) {
      setState(() => _bins = const []);
      return;
    }
    _sub = widget.repo
        .watchBins(partId: widget.partId)
        .listen((b) => setState(() => _bins = b));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _newBin() async {
    final ctl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('New bin'),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Bin name (lot, bag, date…)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, ctl.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty || widget.partId == null) return;
    final id = await widget.repo.createBin(widget.partId!, name);
    widget.onChanged(id);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.partId != null;
    final value = _bins.any((b) => b.id == widget.binId) ? widget.binId : null;
    return DropdownButtonFormField<int?>(
      key: ValueKey('$value-${_bins.length}'),
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Bin',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('— none —')),
        for (final b in _bins)
          DropdownMenuItem<int?>(value: b.id, child: Text(b.name)),
        const DropdownMenuItem<int?>(value: -1, child: Text('＋ New bin…')),
      ],
      onChanged: !enabled
          ? null
          : (v) {
              if (v == -1) {
                _newBin();
              } else {
                widget.onChanged(v);
              }
            },
    );
  }
}

/// Fetches the current tag of a saved reading and writes changes through.
class SavedReadingTagStrip extends ConsumerStatefulWidget {
  const SavedReadingTagStrip({
    super.key,
    required this.readingId,
    this.family,
    this.onChanged,
  });
  final int readingId;
  final String? family;
  final ValueChanged<TagValues>? onChanged;

  @override
  ConsumerState<SavedReadingTagStrip> createState() =>
      _SavedReadingTagStripState();
}

class _SavedReadingTagStripState extends ConsumerState<SavedReadingTagStrip> {
  TagValues? _v;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(SavedReadingTagStrip old) {
    super.didUpdateWidget(old);
    if (old.readingId != widget.readingId) {
      _v = null;
      _load();
    }
  }

  Future<void> _load() async {
    final repo = await ref.read(repositoryProvider.future);
    final d = await repo.loadReading(widget.readingId);
    if (!mounted || d == null) return;
    setState(
      () => _v = TagValues(
        partId: d.tag.partId,
        binId: d.tag.binId,
        label: d.tag.label,
        notes: d.tag.notes,
        starred: d.tag.starred,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = _v;
    if (v == null) return const SizedBox(height: 48);
    return TagStrip(
      value: v,
      family: widget.family,
      onChanged: (nv) async {
        setState(() => _v = nv);
        final repo = await ref.read(repositoryProvider.future);
        await repo.tagReading(
          widget.readingId,
          partId: nv.partId,
          binId: nv.binId,
          label: nv.label,
          notes: nv.notes,
          starred: nv.starred,
          clearPart: nv.partId == null,
          clearBin: nv.binId == null,
        );
        widget.onChanged?.call(nv);
      },
    );
  }
}
