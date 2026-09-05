import 'package:dca75_protocol/dca75_protocol.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';

Color leadColor(Lead l) => switch (l) {
  Lead.red => leadRed,
  Lead.green => leadGreen,
  Lead.blue => leadBlue,
  Lead.none => Colors.grey,
};

/// The three clip colours with their terminal letters, as on the unit.
class PinoutWidget extends StatelessWidget {
  const PinoutWidget({super.key, required this.pins, this.compact = false});
  final List<PinAssignment>? pins;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = pins;
    if (p == null || p.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final size = compact ? 16.0 : 26.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final pin in p)
          Semantics(
            label: '${pin.terminal} on ${pin.lead.label} lead',
            child: Padding(
              padding: EdgeInsets.only(right: compact ? 10 : 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: leadColor(pin.lead),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26, width: 2),
                    ),
                  ),
                  SizedBox(height: compact ? 2 : 5),
                  Text(
                    pin.terminal,
                    style:
                        (compact
                                ? theme.textTheme.labelMedium
                                : theme.textTheme.titleMedium)
                            ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  if (!compact)
                    Text(
                      pin.lead.label.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
