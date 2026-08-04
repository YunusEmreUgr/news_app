import 'package:flutter/material.dart';
import '../features/dashboard/main_dashboard_shell.dart';
import '../features/news/pages/news_home_page.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/profile/profile_screen.dart';

class AppRouter {
  static Map<String, WidgetBuilder> get routes => {
        '/': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/dashboard': (_) => const MainDashboardShell(),
        '/news': (_) => const NewsHomePage(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const ProfileScreen(),
      };
}
