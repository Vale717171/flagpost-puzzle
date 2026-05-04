import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'puzzle/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode') ?? 'system';
  themeNotifier.value = savedTheme == 'dark'
      ? ThemeMode.dark
      : savedTheme == 'light'
          ? ThemeMode.light
          : ThemeMode.system;

  runApp(const FindPaesanoApp());
}

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

class FindPaesanoApp extends StatefulWidget {
  const FindPaesanoApp({super.key});

  @override
  State<FindPaesanoApp> createState() => _FindPaesanoAppState();
}

class _FindPaesanoAppState extends State<FindPaesanoApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'FlagPost: Puzzle',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          home: const HomeScreen(),
        );
      },
    );
  }
}
