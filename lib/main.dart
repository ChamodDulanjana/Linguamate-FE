import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/grammar_screen.dart';
import 'screens/activities_screen.dart';

void main() {
  runApp(const LinguaMateApp());
}

class LinguaMateApp extends StatelessWidget {
  const LinguaMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LINGUAMATE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
          secondary: Colors.grey,
        ),
        scaffoldBackgroundColor: const Color(
          0xFFF5F7FB,
        ), // Light greyish background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Defaulting to Roboto, typical for Android
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const ChatScreen(),
        '/grammar': (context) => const GrammarScreen(),
        '/activities': (context) => const ActivitiesScreen(),
      },
    );
  }
}
