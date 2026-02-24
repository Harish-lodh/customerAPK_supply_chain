import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/services/secure_storage_service.dart';
import 'core/services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/drawdown_provider.dart';
import 'providers/loans_provider.dart';
import 'providers/transactions_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/profile_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize services
  final secureStorage = SecureStorageService();
  await secureStorage.init();
  
  final apiService = ApiService(secureStorage: secureStorage);
  
  runApp(
    MultiProvider(
      providers: [
        Provider<SecureStorageService>.value(value: secureStorage),
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiService: apiService,
            secureStorage: secureStorage,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DashboardProvider>(
          create: (_) => DashboardProvider(apiService: apiService),
          update: (_, auth, dashboard) => dashboard ?? DashboardProvider(apiService: apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DrawdownProvider>(
          create: (_) => DrawdownProvider(apiService: apiService),
          update: (_, auth, drawdown) => drawdown ?? DrawdownProvider(apiService: apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, LoansProvider>(
          create: (_) => LoansProvider(apiService: apiService),
          update: (_, auth, loans) => loans ?? LoansProvider(apiService: apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransactionsProvider>(
          create: (_) => TransactionsProvider(apiService: apiService),
          update: (_, auth, transactions) => transactions ?? TransactionsProvider(apiService: apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationsProvider>(
          create: (_) => NotificationsProvider(apiService: apiService),
          update: (_, auth, notifications) => notifications ?? NotificationsProvider(apiService: apiService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) => ProfileProvider(apiService: apiService),
          update: (_, auth, profile) => profile ?? ProfileProvider(apiService: apiService),
        ),
      ],
      child: const FintreeApp(),
    ),
  );
}

class FintreeApp extends StatefulWidget {
  const FintreeApp({super.key});

  @override
  State<FintreeApp> createState() => _FintreeAppState();
}

class _FintreeAppState extends State<FintreeApp> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fintree SCF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _appRouter.router,
    );
  }
}
