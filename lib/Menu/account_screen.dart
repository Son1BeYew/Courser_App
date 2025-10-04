import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// cai nay chua chay duoc

class User {
  final String name;
  final String email;
  final String avatarUrl;

  User({required this.name, required this.email, required this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['fullname'] ?? '',
      email: json['email'] ?? '',
      avatarUrl:
          json['avatarUrl'] ??
          'https://i.imgur.com/BoN9kdC.png', // mặc định nếu chưa có
    );
  }
}

// Hàm lấy profile user từ API (cần truyền token)
Future<User> fetchUserProfile(String token) async {
  final response = await http.get(
    Uri.parse('http://localhost:5000/api/users/profile'),
    headers: {'Authorization': 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return User.fromJson(data['user']);
  } else {
    throw Exception('Không lấy được dữ liệu user');
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const token = 'YOUR_JWT_TOKEN'; // Thay bằng token thực tế

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản của tôi'), centerTitle: true),
      body: FutureBuilder<User>(
        future: fetchUserProfile(token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi tải dữ liệu'));
          }
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(user.email),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Chỉnh sửa thông tin'),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Đăng xuất'),
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
