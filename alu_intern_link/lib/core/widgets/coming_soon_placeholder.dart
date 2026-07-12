import 'package:flutter/material.dart';

/// Placeholder body for tabs that will be built in a later milestone
/// (opportunities, applications, etc). Keeps the navigation shell demoable
/// end-to-end while those features are still being built.
class ComingSoonPlaceholder extends StatelessWidget {
  const ComingSoonPlaceholder({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Coming in a future milestone'),
        ],
      ),
    );
  }
}
