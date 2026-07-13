import 'package:flutter/material.dart';

import 'startup.dart';

/// Small rounded pill showing a startup's verification status. Shared
/// between the startups list and the startup detail screen so they stay
/// visually consistent.
class StartupStatusBadge extends StatelessWidget {
  const StartupStatusBadge({super.key, required this.status});

  final StartupStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StartupStatus.pending => ('Pending', Colors.orange),
      StartupStatus.verified => ('Verified', Colors.green),
      StartupStatus.rejected => ('Rejected', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
