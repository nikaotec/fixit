import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'providers/user_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'services/local_notification_service.dart';
import 'services/push_notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignore missing .env in non-dev environments.
  }
  await Firebase.initializeApp();
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await LocalNotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..tryAutoLogin()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router;
  bool _pushInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _router = GoRouter(
        refreshListenable: userProvider,
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
        ],
        redirect: (context, state) {
          final isLoggingIn = state.uri.toString() == '/login';
          if (!userProvider.isAuthenticated) {
            return isLoggingIn ? null : '/login';
          }
          if (isLoggingIn) {
            return '/';
          }
          return null;
        },
      );
    }
    if (!_pushInitialized) {
      _pushInitialized = true;
      PushNotificationService.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return MaterialApp.router(
      title: 'FixIt',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: userProvider.themeMode,
      locale: userProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
