import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/initial_avatar.dart';
import '../../auth/app_user.dart';
import '../../auth/auth_providers.dart';
import '../../bookmarks/bookmark_button.dart';
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
    final appUser = ref.watch(currentAppUserProvider).value;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        Text(
          appUser?.fullName != null && appUser!.fullName!.isNotEmpty
              ? 'Hello, ${appUser.fullName!.split(' ').first} 👋'
              : 'Hello 👋',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Find meaningful ways to contribute.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            hintText: 'Search opportunities, startups, skills…',
          ),
        ),
        const SizedBox(height: 20),
        Text('Browse by category', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _CategoryCircle(
                icon: Icons.apps_rounded,
                label: 'All',
                selected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
              ),
              for (final category in OpportunityCategory.values)
                _CategoryCircle(
                  icon: category.icon,
                  label: category.label,
                  selected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Opportunities', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        opportunitiesState.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('Something went wrong: $error')),
          ),
          data: (opportunities) {
            final filtered = _filter(opportunities);
            if (filtered.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No opportunities match your search.')),
              );
            }
            return Column(
              children: filtered
                  .map((o) => _OpportunityCard(opportunity: o, appUser: appUser))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCircle extends StatelessWidget {
  const _CategoryCircle({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 64,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: selected ? colorScheme.onPrimary : colorScheme.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  const _OpportunityCard({required this.opportunity, required this.appUser});

  final Opportunity opportunity;
  final AppUser? appUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OpportunityDetailScreen(opportunity: opportunity)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              InitialAvatar(name: opportunity.startupName),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(opportunity.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      opportunity.startupName,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Chip(
                          label: Text(opportunity.category.label, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                        Chip(
                          label: Text(opportunity.location.label, style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (appUser != null && appUser!.role == UserRole.student)
                BookmarkButton(studentUid: appUser!.uid, opportunity: opportunity),
            ],
          ),
        ),
      ),
    );
  }
}
