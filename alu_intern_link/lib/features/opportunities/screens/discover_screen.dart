import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../opportunity.dart';
import '../opportunity_providers.dart';
import 'opportunity_detail_screen.dart';

/// The Discover tab: browse and search all open opportunities.
///
/// We keep this simple - openOpportunitiesProvider streams every open
/// opportunity from Firestore in real time, and this widget just filters
/// that list in memory as the user types or picks a category. No search
/// backend needed at this scale.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  OpportunityCategory? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Opportunity> _filter(List<Opportunity> opportunities) {
    final query = _searchQuery.trim().toLowerCase();

    return opportunities.where((o) {
      final matchesCategory = _selectedCategory == null || o.category == _selectedCategory;
      if (!matchesCategory) return false;
      if (query.isEmpty) return true;

      final haystack = [o.title, o.description, o.startupName, ...o.skillsRequired]
          .join(' ')
          .toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final opportunitiesState = ref.watch(openOpportunitiesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Search opportunities, startups, skills…',
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _CategoryChip(
                label: 'All',
                selected: _selectedCategory == null,
                onSelected: () => setState(() => _selectedCategory = null),
              ),
              const SizedBox(width: 8),
              for (final category in OpportunityCategory.values) ...[
                _CategoryChip(
                  label: category.label,
                  selected: _selectedCategory == category,
                  onSelected: () => setState(() => _selectedCategory = category),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: opportunitiesState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Something went wrong: $error')),
            data: (opportunities) {
              final filtered = _filter(opportunities);
              if (filtered.isEmpty) {
                return const Center(child: Text('No opportunities match your search.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _OpportunityCard(opportunity: filtered[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onSelected});

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label), selected: selected, onSelected: (_) => onSelected());
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({required this.opportunity});

  final Opportunity opportunity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunity: opportunity)),
        ),
        title: Text(opportunity.title),
        subtitle: Text(
          '${opportunity.startupName} · ${opportunity.category.label} · ${opportunity.location.label}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
