// splash_screen.dart - Displays a splash screen with the app logo and a loading indicator for 3 seconds before navigating to the Login Page.
import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_flow.dart'; // Import the auth file

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Logic: Wait 3 seconds, then go to Login Page
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                  )
                ],
              ),
              clipBehavior: Clip.hardEdge,
              child: Image.asset(
                'assets/logo.png', 
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) => const Icon(Icons.hub, size: 80, color: Color(0xFF2E8B57)),
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: Color(0xFF2E8B57)),
            const SizedBox(height: 10),
            const Text("Loading Mhub...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}