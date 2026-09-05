import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pinout.dart';

/// Component name, flags, pinout and parameter table for an identify result.
class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.result,
    this.header,
    this.trailing,
    this.showRaw = true,
  });

  final IdentifyResult? result;
  final Widget? header;
  final Widget? trailing;
  final bool showRaw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = result;
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[header!, const SizedBox(height: 8)],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    r?.name ?? '—',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            if (r != null &&
                !r.type.isComponent &&
                r.type == ComponentType.none)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Check the clips and try again.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            if (r != null && r.flagLabels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final f in r.flagLabels)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.onSurface),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        f,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            if (r?.pins != null) ...[
              const SizedBox(height: 12),
              PinoutWidget(pins: r!.pins),
            ],
            const SizedBox(height: 12),
            if (r == null || r.params.isEmpty)
              Text(
                'No parameters.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ParamTable(params: r.params),
            if (showRaw && r != null) ...[
              const SizedBox(height: 8),
              _RawFrame(r: r),
            ],
          ],
        ),
      ),
    );
  }
}

class ParamTable extends StatelessWidget {
  const ParamTable({super.key, required this.params});
  final List<Param> params;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Table(
      columnWidths: const {1: IntrinsicColumnWidth()},
      children: [
        for (final p in params)
          TableRow(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Text(p.label, style: theme.textTheme.bodyMedium),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Text(
                  p.display,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RawFrame extends StatelessWidget {
  const _RawFrame({required this.r});
  final IdentifyResult r;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text('Raw frame', style: theme.textTheme.bodySmall),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                r.rawHex,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Copy result',
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                final lines = [
                  r.name,
                  ...r.flagLabels,
                  ...(r.pins ?? []).map(
                    (p) => '${p.terminal} = ${p.lead.label}',
                  ),
                  ...r.params.map((p) => '${p.label}: ${p.display}'),
                  '',
                  r.rawHex,
                ];
                Clipboard.setData(ClipboardData(text: lines.join('\n')));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Result copied')));
              },
            ),
          ],
        ),
      ],
    );
  }
}
