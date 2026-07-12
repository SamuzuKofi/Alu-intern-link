import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/coming_soon_placeholder.dart';
import '../../auth/app_user.dart';
import '../../auth/auth_providers.dart';
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
        middleTab = const ComingSoonPlaceholder(icon: Icons.assignment_rounded, label: 'My applications');
        middleIcon = Icons.assignment_outlined;
        middleLabel = 'Applications';
    }

    final tabs = [
      const ComingSoonPlaceholder(icon: Icons.explore_rounded, label: 'Discover opportunities'),
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            child: Text(
              (appUser.fullName?.isNotEmpty ?? false) ? appUser.fullName![0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Text(appUser.fullName ?? 'No name set', style: Theme.of(context).textTheme.titleLarge),
          Text(appUser.email, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Chip(label: Text(_roleLabel(appUser.role))),
          if (appUser.bio != null && appUser.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
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
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Sign out'),
          ),
        ],
      ),
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
