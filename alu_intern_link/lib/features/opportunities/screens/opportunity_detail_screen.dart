import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../opportunity.dart';

class OpportunityDetailScreen extends StatelessWidget {
  const OpportunityDetailScreen({super.key, required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(opportunity.startupName)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(opportunity.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('Posted by ${opportunity.startupName}', style: Theme.of(context).textTheme.bodyMedium),
            if (opportunity.createdAt != null) ...[
              const SizedBox(height: 4),
              Text(
                timeago.format(opportunity.createdAt!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                Chip(label: Text(opportunity.category.label)),
                Chip(label: Text(opportunity.location.label)),
              ],
            ),
            const SizedBox(height: 24),
            Text('Description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(opportunity.description),
            if (opportunity.skillsRequired.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text('Skills required', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opportunity.skillsRequired.map((s) => Chip(label: Text(s))).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
