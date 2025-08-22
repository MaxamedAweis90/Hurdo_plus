import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/global_audio.dart';

void main() {
  runApp(const HurdoPlusApp());
}

class HurdoPlusApp extends StatefulWidget {
  const HurdoPlusApp({super.key});

  @override
  State<HurdoPlusApp> createState() => _HurdoPlusAppState();
}

class _HurdoPlusAppState extends State<HurdoPlusApp> {
  int _themeIndex = 0;
  final _globalAudio = AppAudioController();

  static final List<ThemeData> themes = [
    // Ocean Blue (keep existing palette)
    ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF1976D2), // Vivid blue
        secondary: Color(0xFF00B8D4), // Cyan accent
        surface: Color(0xFF1A2236),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF101624),
      cardColor: Color(0xFF1A2236),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF151C2C),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    // Sunset Orange (new)
    ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFFF7043), // Deep orange
        secondary: Color(0xFFFFC400), // Amber accent
        surface: Color(0xFF2A1E18),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1410),
      cardColor: const Color(0xFF2A1E18),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2A1E18),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    // Forest Green (new)
    ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF00BFA5), // Teal green
        secondary: Color(0xFFB2FF59), // Lime accent
        surface: Color(0xFF18332A),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF10201A),
      cardColor: const Color(0xFF18332A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF18332A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    // Purple Night (new)
    ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF7C4DFF), // Deep purple
        secondary: Color(0xFF00E676), // Green accent
        surface: Color(0xFF241A3A),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1333),
      cardColor: const Color(0xFF241A3A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF241A3A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
    // Teal Dream (keep existing palette)
    ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF00B8A9), // Cyber teal
        secondary: Color(0xFFFF5252), // Red accent
        surface: Color(0xFF183A3A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF102222),
      cardColor: const Color(0xFF183A3A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF183A3A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ),
  ];

  void _setTheme(int index) {
    setState(() {
      _themeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppAudioScope(
      controller: _globalAudio,
      child: MaterialApp(
        title: 'Hurdo+',
        theme: themes[_themeIndex],
        home: HomeScreen(onThemeChanged: _setTheme, selectedTheme: _themeIndex),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
