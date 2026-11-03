import 'package:flutter/material.dart';

class Activity1Screen extends StatefulWidget {
  const Activity1Screen({super.key});

  @override
  State<Activity1Screen> createState() => _Activity1ScreenState();
}

class _Activity1ScreenState extends State<Activity1Screen> {
  bool completed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Activity 01')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LABORATORY ACTIVITY 01',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Laboratory Activity 1',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This screen is reserved for your first laboratory activity. '
                      'You can replace this content with the activity given by your instructor.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            completed
                                ? Icons.check_circle_rounded
                                : Icons.info_outline_rounded,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              completed
                                  ? 'Activity marked as completed.'
                                  : 'Use the button below to demonstrate local screen state.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            setState(() => completed = !completed),
                        icon: Icon(
                          completed
                              ? Icons.undo_rounded
                              : Icons.check_rounded,
                        ),
                        label: Text(
                          completed ? 'Mark as Incomplete' : 'Mark as Complete',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
