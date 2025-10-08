import 'package:flutter/material.dart';
import '../AdminScreens/AdminDashboard.dart'; // 👉 nhớ import dashboard

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
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản của tôi'), centerTitle: true),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('user@example.com'),
            const SizedBox(height: 24),

            // ✅ Nút quản trị admin (thêm mới)
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.deepPurple,
              ),
              title: const Text('Trang quản trị Admin'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueGrey),
              title: const Text('Chỉnh sửa thông tin'),
              onTap: () {
                // TODO: handle edit profile
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
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
