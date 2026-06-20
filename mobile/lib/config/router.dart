import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/expense/screens/expense_list_screen.dart';
import '../features/expense/screens/expense_form_screen.dart';
import '../features/budget/screens/budget_screen.dart';
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
            builder: (_, __) => const ExpenseFormScreen(),
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

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return NavigationBar(
      selectedIndex: _indexFromRoute(location),
      onDestinationSelected: (i) => _navigate(context, i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined),     selectedIcon: Icon(Icons.home),        label: 'Home'),
        NavigationDestination(icon: Icon(Icons.receipt_outlined),  selectedIcon: Icon(Icons.receipt),     label: 'Expenses'),
        NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner), label: 'Scan'),
        NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Budget'),
        NavigationDestination(icon: Icon(Icons.person_outlined),   selectedIcon: Icon(Icons.person),      label: 'Profile'),
      ],
    );
  }

  int _indexFromRoute(String location) {
    if (location.startsWith('/expenses')) return 1;
    if (location.startsWith('/receipt')) return 2;
    if (location.startsWith('/budgets')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/dashboard');
      case 1: context.go('/expenses');
      case 2: context.go('/receipt/scan');
      case 3: context.go('/budgets');
      case 4: context.go('/profile');
    }
  }
}
