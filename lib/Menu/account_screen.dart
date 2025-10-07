import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class User {
  final String name;
  final String email;
  final String avatarUrl;

  User({required this.name, required this.email, required this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['fullname'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? 'https://i.imgur.com/BoN9kdC.png',
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Since we don't have a token yet, display a placeholder UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'), 
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://i.imgur.com/BoN9kdC.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Người dùng',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('user@example.com'),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Chỉnh sửa thông tin'),
              onTap: () {
                // Handle edit profile
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
