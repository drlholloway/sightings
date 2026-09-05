import 'package:dca75_transport/dca75_transport.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../services/providers.dart';

final logStreamProvider = StreamProvider<List<TransportLogEntry>>((ref) {
  final log = ref.watch(transportLogProvider);
  return log.stream.map((_) => log.entries).startWith(log.entries);
});

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({super.key});

  @override
  ConsumerState<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends ConsumerState<LogScreen> {
  bool _errorsOnly = false;

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(logStreamProvider).value ?? const [];
    final log = ref.read(transportLogProvider);
    final theme = Theme.of(context);
    final shown = _errorsOnly ? entries.where((e) => !e.ok).toList() : entries;
    final lat = log.latency();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
          child: Row(
            children: [
              Text('USB log', style: theme.textTheme.titleLarge),
              const SizedBox(width: 16),
              Text(
                '${lat.n} ok · p50 ${lat.p50.inMicroseconds / 1000} ms · p95 ${lat.p95.inMicroseconds / 1000} ms',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              FilterChip(
                label: const Text('Errors only'),
                selected: _errorsOnly,
                onSelected: (v) => setState(() => _errorsOnly = v),
              ),
              IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy),
                onPressed: () => Clipboard.setData(
                  ClipboardData(
                    text: shown.map((e) => e.toString()).join('\n'),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Export capture (.dcalog)',
                icon: const Icon(Icons.download_outlined),
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    files: [
                      XFile.fromData(
                        Uint8List.fromList(encodeCapture(entries).codeUnits),
                        mimeType: 'text/plain',
                        name:
                            'session-${DateTime.now().millisecondsSinceEpoch}.dcalog',
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () => setState(log.clear),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final e = shown[shown.length - 1 - i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 1,
                ),
                child: Text(
                  e.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    color: e.ok ? null : theme.colorScheme.error,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

extension<T> on Stream<T> {
  Stream<T> startWith(T first) async* {
    yield first;
    yield* this;
  }
}
