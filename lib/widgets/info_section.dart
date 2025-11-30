import 'package:flutter/material.dart';
import 'spacing.dart';

class InfoSection extends StatelessWidget {
  final String title;
  final String body;
  final List<Widget> actions;
  const InfoSection({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ReadableWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.hGutter,
          vertical: AppSpacing.v12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.v8),
            Text(body, style: theme.textTheme.bodyMedium),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.v12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ]
          ],
        ),
      ),
    );
  }
}
