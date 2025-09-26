import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'HomeScreens/HomeScreens.dart';
import 'Onboarding/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Courser',

      home: const OnboardingScreen(),
      routes: {
        "/login": (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        "/home": (context) => const HomeScreens(),
        "/onboarding": (context) => const OnboardingScreen(),
      },
    );
  }
}
