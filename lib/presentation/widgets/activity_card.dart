import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVITY $number',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
