import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../applications/application_providers.dart';
import '../../applications/application.dart';
import '../../applications/screens/my_applications_screen.dart';
import '../../auth/app_user.dart';
import '../../auth/auth_providers.dart';
import '../../bookmarks/screens/saved_opportunities_screen.dart';
import '../../opportunities/opportunity_providers.dart';
import '../../opportunities/screens/discover_screen.dart';
import '../../startups/startup.dart';
import '../../startups/startup_providers.dart';
import '../../startups/screens/admin_verification_screen.dart';
import '../../startups/screens/my_startup_screen.dart';

/// Main app screen once a user is signed in and onboarded. Holds the
/// bottom navigation bar; each tab's real content gets built out in a
/// later milestone.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.appUser});

  final AppUser appUser;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = widget.appUser.role;

    // The middle tab is different for each role: students track their
    // applications, founders manage their startup, admins review the
    // verification queue. Discover and Profile stay the same for everyone.
    final Widget middleTab;
    final IconData middleIcon;
    final String middleLabel;
    switch (role) {
      case UserRole.startup:
        middleTab = MyStartupScreen(ownerUid: widget.appUser.uid);
        middleIcon = Icons.storefront_outlined;
        middleLabel = 'My Startup';
      case UserRole.admin:
        middleTab = const AdminVerificationScreen();
        middleIcon = Icons.verified_outlined;
        middleLabel = 'Verify';
      case UserRole.student:
      case null:
        middleTab = MyApplicationsScreen(studentUid: widget.appUser.uid);
        middleIcon = Icons.assignment_outlined;
        middleLabel = 'Applications';
    }

    final tabs = [
      const DiscoverScreen(),
      middleTab,
      _ProfileTab(appUser: widget.appUser),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ALU Intern Link')),
      body: tabs[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Discover'),
          NavigationDestination(icon: Icon(middleIcon), label: middleLabel),
          const NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                child: Text(
                  (appUser.fullName?.isNotEmpty ?? false) ? appUser.fullName![0].toUpperCase() : '?',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 12),
              Text(appUser.fullName ?? 'No name set', style: Theme.of(context).textTheme.titleLarge),
              Text(appUser.email, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Chip(label: Text(_roleLabel(appUser.role))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _StatsRow(appUser: appUser),
        if (appUser.bio != null && appUser.bio!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('About', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(appUser.bio!),
        ],
        if (appUser.skills.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Skills', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: appUser.skills.map((s) => Chip(label: Text(s))).toList(),
          ),
        ],
        const SizedBox(height: 24),
        if (appUser.role == UserRole.student)
          _MenuTile(
            icon: Icons.bookmark_border_rounded,
            label: 'Saved opportunities',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SavedOpportunitiesScreen(studentUid: appUser.uid)),
            ),
          ),
        _MenuTile(
          icon: Icons.logout_rounded,
          label: 'Sign out',
          isDestructive: true,
          onTap: () => ref.read(authRepositoryProvider).signOut(),
        ),
      ],
    );
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.startup:
        return 'Startup founder';
      case UserRole.admin:
        return 'ALU Admin';
      case null:
        return 'Unknown';
    }
  }
}

/// Small role-aware row of numbers - only shows stats we can actually
/// compute cheaply from data this user already owns.
class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.appUser});

  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (appUser.role) {
      case UserRole.student:
        final applications = ref.watch(applicationsForStudentProvider(appUser.uid)).value ?? [];
        final inReview = applications
            .where((a) => a.status == ApplicationStatus.pending || a.status == ApplicationStatus.reviewed)
            .length;
        final accepted = applications.where((a) => a.status == ApplicationStatus.accepted).length;
        return Row(
          children: [
            _StatTile(value: '${applications.length}', label: 'Applications'),
            _StatTile(value: '$inReview', label: 'In review'),
            _StatTile(value: '$accepted', label: 'Accepted'),
          ],
        );

      case UserRole.startup:
        final startup = ref.watch(myStartupProvider(appUser.uid)).value;
        if (startup == null) return const SizedBox.shrink();
        final opportunities = ref.watch(opportunitiesForStartupProvider(startup.id)).value ?? [];
        return Row(
          children: [
            _StatTile(value: '${opportunities.length}', label: 'Posted'),
            _StatTile(
              value: startup.status == StartupStatus.verified ? 'Verified' : 'Pending',
              label: 'Startup status',
            ),
          ],
        );

      case UserRole.admin:
        final pending = ref.watch(pendingStartupsProvider).value ?? [];
        return Row(children: [_StatTile(value: '${pending.length}', label: 'Awaiting review')]);

      case null:
        return const SizedBox.shrink();
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Theme.of(context).colorScheme.error : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
