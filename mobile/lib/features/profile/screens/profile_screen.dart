import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(authStateProvider).value;
    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(user?.name ?? '', style: Theme.of(context).textTheme.headlineSmall)),
          Center(child: Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 32),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: const Text('Currency'),
            trailing: Text(user?.currency ?? 'MYR'),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Timezone'),
            trailing: Text(user?.timezone ?? '-'),
          ),
          const Divider(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: isLoading
                ? null
                : () async {
                    final confirmed = await _confirmLogout(context);
                    if (confirmed == true) {
                      await ref.read(authStateProvider.notifier).logout();
                    }
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmLogout(BuildContext context) => showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true),  child: const Text('Sign Out')),
          ],
        ),
      );
}
