import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/utils/responsive.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/expense/screens/expense_list_screen.dart';
import '../features/expense/screens/expense_form_screen.dart';
import '../features/budget/screens/budget_screen.dart';
import '../features/receipt/models/receipt_model.dart';
import '../features/receipt/screens/receipt_scan_screen.dart';
import '../features/profile/screens/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isAuthenticated && !isAuthRoute) return '/auth/login';
      if (isAuthenticated && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/auth/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/expenses',  builder: (_, __) => const ExpenseListScreen()),
          GoRoute(
            path: '/expenses/new',
            builder: (_, state) => ExpenseFormScreen(
              initialData: state.extra as AiReceiptData?,
            ),
          ),
          GoRoute(
            path: '/expenses/:id/edit',
            builder: (_, state) => ExpenseFormScreen(
              expenseId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(path: '/budgets',       builder: (_, __) => const BudgetScreen()),
          GoRoute(path: '/receipt/scan',  builder: (_, __) => const ReceiptScanScreen()),
          GoRoute(path: '/profile',       builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

const _destinations = [
  (icon: Icons.home_outlined,     selectedIcon: Icons.home,                        label: 'Home',     path: '/dashboard'),
  (icon: Icons.receipt_outlined,  selectedIcon: Icons.receipt,                     label: 'Expenses',  path: '/expenses'),
  (icon: Icons.document_scanner_outlined, selectedIcon: Icons.document_scanner,    label: 'Scan',      path: '/receipt/scan'),
  (icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet, label: 'Budget', path: '/budgets'),
  (icon: Icons.person_outlined,   selectedIcon: Icons.person,                      label: 'Profile',   path: '/profile'),
];

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  int _indexFromRoute(String location) {
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/receipt')) return 2;
    if (location.startsWith('/budgets')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _navigate(BuildContext context, int index) => context.go(_destinations[index].path);

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _indexFromRoute(location);

    // Wide screens (tablets, foldables, desktop) get a persistent side rail
    // instead of a bottom bar squished under a large logical width.
    if (context.isExpanded) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => _navigate(context, i),
              labelType: NavigationRailLabelType.all,
              destinations: _destinations
                  .map((d) => NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => _navigate(context, i),
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}
