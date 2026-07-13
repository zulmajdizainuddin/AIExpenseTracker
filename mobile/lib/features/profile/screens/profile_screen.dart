import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user      = ref.watch(authStateProvider).value;
    final isLoading = ref.watch(authStateProvider).isLoading;
    final scheme    = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.contentPadding),
        child: ContentWidthLimiter(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(gradient: AppGradients.brand, shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name.substring(0, 1).toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(user?.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: TextStyle(color: scheme.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.currency_exchange_rounded,
                        title: 'Currency',
                        value: user?.currency ?? 'MYR',
                      ),
                      const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                      _ProfileTile(
                        icon: Icons.access_time_rounded,
                        title: 'Timezone',
                        value: user?.timezone ?? '-',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.error,
                      side: BorderSide(color: scheme.error.withOpacity(0.4)),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final confirmed = await _confirmLogout(context);
                            if (confirmed == true) {
                              await ref.read(authStateProvider.notifier).logout();
                            }
                          },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
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

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: scheme.onPrimaryContainer),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(value, style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
    );
  }
}
