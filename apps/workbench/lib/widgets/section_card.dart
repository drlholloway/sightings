import 'package:flutter/material.dart';

/// An outlined card with a small-caps title, an optional action at the end
/// of the title row, and the card's content below.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    this.action,
    required this.children,
  });

  final String title;

  /// Shown at the end of the title row, such as a Measure button.
  final Widget? action;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.labelMedium?.copyWith(
                      letterSpacing: 1,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// The title-row action of a measurement card: a spinner while [running],
/// otherwise a Measure (or Re‑measure) button when [onMeasure] is given.
class MeasureAction extends StatelessWidget {
  const MeasureAction({
    super.key,
    required this.running,
    required this.measured,
    required this.icon,
    this.onMeasure,
  });

  final bool running;

  /// Whether there are figures already, so the button offers to re-measure.
  final bool measured;
  final IconData icon;

  /// Null when the measurement cannot be started.
  final VoidCallback? onMeasure;

  @override
  Widget build(BuildContext context) {
    if (running) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (onMeasure == null) return const SizedBox.shrink();
    return TextButton.icon(
      onPressed: onMeasure,
      icon: Icon(icon, size: 18),
      label: Text(measured ? 'Re‑measure' : 'Measure'),
    );
  }
}

/// A label with its value in bold at the end of the row.
class ValueRow extends StatelessWidget {
  const ValueRow(this.label, this.value, {super.key});

  final String label, value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small muted text in a card: a description, or with [gap] a footnote set
/// off from the values above it. [error] colors it as a warning.
class CardNote extends StatelessWidget {
  const CardNote(this.text, {super.key, this.gap = false, this.error = false});

  final String text;
  final bool gap, error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: gap ? 6 : 0),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: error
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
