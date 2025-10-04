import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'signup_screen.dart';
import 'HomeScreens/HomeScreens.dart';
import 'Onboarding/onboarding_screen.dart';
import 'HomeScreens/MyCoursesScreen.dart';
import 'Menu/account_screen.dart';

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
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const OnboardingScreen(), // Đổi lại thành OnboardingScreen
      routes: {
        "/login": (context) => const LoginScreen(),
        "/signup": (context) => const SignupScreen(),
        "/home": (context) => const MainPage(),
        "/onboarding": (context) => const OnboardingScreen(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreens(),
    MyCoursesScreen(),
    HistoryScreen(),
    AccountScreen(), // Thay ProfileScreen bằng AccountScreen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Khóa học"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Lịch sử"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Tài khoản"),
        ],
      ),
    );
  }
}

// demo màn hình
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Lịch sử học"));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Tài khoản của tôi"));
  }
}
