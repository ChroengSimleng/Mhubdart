// main.dart - Entry point of the Mhub app, setting up the MaterialApp and theme.
import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MhubApp());
}

class MhubApp extends StatelessWidget {
  const MhubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mhub App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Colors extracted from your logo
        primaryColor: const Color(0xFF2E8B57), // Sea Green
        scaffoldBackgroundColor: Colors.white,
        
        // Defining the color scheme for buttons and accents
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8B57),
          secondary: const Color(0xFFF4C430), // Yellow/Gold from logo
          surface: Colors.white,
        ),
        
        // Modern Material 3 design
        useMaterial3: true,
        
        // distinct app bar style
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E8B57),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}