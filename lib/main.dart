import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'screens/main_shell.dart';
import 'services/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme color options
class AppTheme {
  final String name;
  final Color primary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onBackground;
  final Color onSurface;
  AppTheme({
    required this.name,
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onBackground,
    required this.onSurface,
  });
}

final appThemes = [
  AppTheme(
    name: 'Blue',
    primary: Color(0xFF3A6FE8),
    accent: Color(0xFFBFD6FF),
    background: Color(0xFF223A5F),
    surface: Color(0xFF223A5F),
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  AppTheme(
    name: 'Purple',
    primary: Color(0xFF7C3AED),
    accent: Color(0xFFD1B3FF),
    background: Color(0xFF2D205F),
    surface: Color(0xFF2D205F),
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  AppTheme(
    name: 'Green',
    primary: Color(0xFF34D399),
    accent: Color(0xFFB9FBC0),
    background: Color(0xFF1B3A2F),
    surface: Color(0xFF1B3A2F),
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  AppTheme(
    name: 'Red',
    primary: Color(0xFFEF4444),
    accent: Color(0xFFFCA5A5),
    background: Color(0xFF3B1F1F),
    surface: Color(0xFF3B1F1F),
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  AppTheme(
    name: 'Pink',
    primary: Color(0xFFEC4899),
    accent: Color(0xFFF9A8D4),
    background: Color(0xFF3A2232),
    surface: Color(0xFF3A2232),
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  AppTheme(
    name: 'Teal',
    primary: Color(0xFF14B8A6),
    accent: Color(0xFF99F6E4),
    background: Color(0xFF183C3A),
    surface: Color(0xFF183C3A),
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  AppTheme(
    name: 'Yellow',
    primary: Color(0xFFFACC15),
    accent: Color(0xFFFEF08A),
    background: Color(0xFF3A341F),
    surface: Color(0xFF3A341F),
    onPrimary: Colors.black,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
  AppTheme(
    name: 'Gray',
    primary: Color(0xFF64748B),
    accent: Color(0xFFCBD5E1),
    background: Color(0xFF23272F),
    surface: Color(0xFF23272F),
    onPrimary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
];

final themeIndexProvider = StateProvider<int>((ref) => 0); // default to Blue

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const ProviderScope(child: HurdoPlusApp()));
}

class HurdoPlusApp extends ConsumerWidget {
  const HurdoPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIndex = ref.watch(themeIndexProvider);
    final theme = appThemes[themeIndex];
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: theme.primary,
      onPrimary: theme.onPrimary,
      secondary: theme.accent,
      onSecondary: theme.onPrimary,
      error: Colors.red.shade200,
      onError: Colors.black,
      background: theme.background,
      onBackground: theme.onBackground,
      surface: theme.surface,
      onSurface: theme.onSurface,
    );
    return MaterialApp(
      title: 'Hurdo+',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: theme.background,
        cardColor: theme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: theme.background,
          foregroundColor: theme.accent,
          elevation: 0,
        ),
      ),
      home: const OnboardingOrMain(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnboardingOrMain extends ConsumerWidget {
  const OnboardingOrMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showOnboarding = ref.watch(showOnboardingProvider);
    if (showOnboarding) {
      return const OnboardingScreen();
    } else {
      return const MainShell();
    }
  }
}
