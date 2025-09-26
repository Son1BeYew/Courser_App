import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/users/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": emailCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String userName = data["user"]?["name"] ?? "Người dùng";

        Navigator.pushReplacementNamed(
          context,
          "/home",
          arguments: {"userName": userName},
        );
      } else {
        final err = json.decode(response.body);
        _showMessage(err["msg"] ?? "Đăng nhập thất bại");
      }
    } catch (e) {
      _showMessage("Lỗi kết nối server: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Logo
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.school, size: 64, color: Colors.blue),
                      SizedBox(height: 8),
                      Text(
                        "EDUPRO",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        "HỌC TẬP MỌI LÚC",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  "Chào mừng bạn quay lại!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Đăng nhập để tiếp tục học",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),

                // 🔹 Email
                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    hintText: "Nhập email",
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Vui lòng nhập email" : null,
                ),
                const SizedBox(height: 16),

                // 🔹 Password
                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Nhập mật khẩu",
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? "Vui lòng nhập mật khẩu"
                      : null,
                ),
                const SizedBox(height: 20),

                // 🔹 Nút đăng nhập
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: handleLogin,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Đăng nhập",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                const Center(child: Text("Hoặc đăng nhập với")),
                const SizedBox(height: 16),

                // 🔹 Social login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(Icons.g_mobiledata, Colors.red),
                    const SizedBox(width: 20),
                    _buildSocialButton(Icons.apple, Colors.black),
                  ],
                ),
                const SizedBox(height: 30),

                // 🔹 Chuyển sang signup
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, "/signup");
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Chưa có tài khoản? ",
                        style: TextStyle(color: Colors.black54),
                        children: [
                          TextSpan(
                            text: "ĐĂNG KÝ",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
