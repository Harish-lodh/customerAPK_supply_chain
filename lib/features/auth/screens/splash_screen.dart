import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/services/session_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    try {
      // Check if user is logged in via SessionService
      final isLoggedIn = await SessionService.isLoggedIn();

      if (!mounted) return;

      // Update AuthProvider state based on session
      final authProvider = context.read<AuthProvider>();

      if (isLoggedIn) {
        // Load user data and set authenticated state
        await authProvider.loadStoredSession();
      } else {
        // Set unauthenticated state
        authProvider.setUnauthenticated();
      }

      if (!mounted) return;

      // Navigate based on login status
      if (isLoggedIn) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    } catch (e) {
      // On error, navigate to login
      if (mounted) {
        context.read<AuthProvider>().setUnauthenticated();
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.account_balance,
                size: 64,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            // App Name
            const Text(
              'Fintree SCF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Supply Chain Finance',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
