import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/activities_screen.dart';

import 'utils/theme_manager.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const LinguaMateApp());
}

class LinguaMateApp extends StatelessWidget {
  const LinguaMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeManager.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'LINGUAMATE',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeManager.instance.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.black,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.black,
              primary: Colors.black,
              secondary: Colors.grey,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F7FB),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              primary: Colors.white,
              secondary: Colors.grey,
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => const ChatScreen(),
            '/learning': (context) => const LearningScreen(),
            '/activities': (context) => const ActivitiesScreen(),
          },
        );
      },
    );
  }
}
