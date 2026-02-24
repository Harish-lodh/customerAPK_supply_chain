import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/drawdown/screens/drawdown_list_screen.dart';
import '../features/drawdown/screens/drawdown_form_screen.dart';
import '../features/loans/screens/loans_screen.dart';
import '../features/loans/screens/loan_detail_screen.dart';
import '../features/transactions/screens/transactions_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../core/widgets/main_scaffold.dart';

class AppRouter {
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();
  
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoggingIn = state.uri.path == '/login';
      final isOtpRoute = state.uri.path == '/otp';
      
      // Allow OTP route only when coming from login
      if (isOtpRoute) {
        return null;
      }
      
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      // Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // OTP Verification Route
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final mobile = extra?['mobile'] as String? ?? '';
          return OtpScreen(mobileNumber: mobile);
        },
      ),
      
      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          
          // Drawdown
          GoRoute(
            path: '/drawdown',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DrawdownListScreen(),
            ),
          ),
          
          // Loans
          GoRoute(
            path: '/loans',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LoansScreen(),
            ),
          ),
          
          // Transactions
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransactionsScreen(),
            ),
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      
      // Drawdown Form (outside shell)
      GoRoute(
        path: '/drawdown/apply',
        builder: (context, state) => const DrawdownFormScreen(),
      ),
      
      // Loan Detail
      GoRoute(
        path: '/loans/:loanId',
        builder: (context, state) {
          final loanId = state.pathParameters['loanId']!;
          return LoanDetailScreen(loanId: loanId);
        },
      ),
      
      // Notifications
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
}
