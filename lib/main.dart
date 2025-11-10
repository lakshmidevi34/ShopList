import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Correct absolute imports (based on your pubspec.yaml name: shopmind)
import 'package:shopmind/data/local_storage.dart';
import 'package:shopmind/screens/login_screen.dart';
import 'package:shopmind/screens/home_screen.dart';
import 'package:shopmind/utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await LocalStorage.registerAdapters();
  await LocalStorage.initBoxes();
  runApp(const ShopMindApp());
}

class ShopMindApp extends StatefulWidget {
  const ShopMindApp({super.key});

  @override
  State<ShopMindApp> createState() => _ShopMindAppState();
}

class _ShopMindAppState extends State<ShopMindApp> {
  ThemeMode _themeMode = ThemeMode.light;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  /// 🔹 Loads theme + login state from SharedPreferences
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
    (prefs.getBool('isDark') ?? false) ? ThemeMode.dark : ThemeMode.light;
    _loggedIn = prefs.getBool('loggedIn') ?? false;
    if (mounted) setState(() {});
  }

  /// 🔹 Toggles between light/dark themes
  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = _themeMode == ThemeMode.dark;
    await prefs.setBool('isDark', !isDark);
    setState(() => _themeMode = !isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// 🔹 Updates login state and stores it locally
  void _onLoginChanged(bool logged) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loggedIn', logged);
    setState(() => _loggedIn = logged);
  }

  @override
  Widget build(BuildContext context) {
    // 🌤️ Light Mode Theme
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundTop,
      cardColor: AppColors.card,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.success,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.header,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: AppColors.header),
      ),
    );

    // 🌙 Dark Mode Theme
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardColor: AppColors.darkCard,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.success,
      ),
      useMaterial3: true,
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopMind Pro',
      themeMode: _themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: _loggedIn
          ? HomeScreen(
        onLogout: () => _onLoginChanged(false),
        onToggleTheme: _toggleTheme,
      )
          : LoginScreen(onLoggedIn: () => _onLoginChanged(true)),
    );
  }
}
