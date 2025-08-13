import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'ui/app_theme.dart';
import 'screens/terms_consent_screen.dart';
import 'screens/wizard_screen.dart';
import 'screens/memo_screen.dart';
import 'screens/reservation_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/success_screen.dart';
import 'screens/simple_admin_screen.dart';
import 'screens/webhook_settings_screen.dart';
import 'services/supabase_service.dart';
import 'config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase if configured
  if (Env.isConfigured) {
    await SupabaseService().initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  } else {
    print('⚠️ Supabase not configured. Running in offline mode.');
    print('To enable Supabase, run with:');
    print('flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key');
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '행정도우미',
      theme: AppTheme.lightTheme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TermsConsentScreen(),
    ),
    GoRoute(
      path: '/wizard',
      builder: (context, state) => const WizardScreen(),
    ),
    GoRoute(
      path: '/memo',
      builder: (context, state) => const MemoScreen(),
    ),
    GoRoute(
      path: '/reservation',
      builder: (context, state) => const ReservationScreen(),
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) => const SummaryScreen(),
    ),
    GoRoute(
      path: '/contact',
      builder: (context, state) => const ContactScreen(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) => const SuccessScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const SimpleAdminScreen(),
    ),
    GoRoute(
      path: '/admin/webhooks',
      builder: (context, state) => const WebhookSettingsScreen(),
    ),
  ],
);