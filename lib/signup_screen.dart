import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool isLoading = false;

  Future<void> handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/users/register"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": nameCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "password": passCtrl.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        _showMessage("Đăng ký thành công, vui lòng đăng nhập!");
        Navigator.pop(context); // quay lại màn login
      } else {
        final err = json.decode(response.body);
        _showMessage(err["msg"] ?? "Đăng ký thất bại");
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
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.person_add, size: 64, color: Colors.blue),
                      SizedBox(height: 8),
                      Text(
                        "TẠO TÀI KHOẢN",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  "Đăng ký tài khoản mới",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: "Họ và tên",
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) => val == null || val.isEmpty
                      ? "Vui lòng nhập họ tên"
                      : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    hintText: "Email",
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

                TextFormField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Mật khẩu",
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

                // 🔹 Nút đăng ký
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
                    onPressed: handleSignup,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Đăng ký",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // về lại login
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Đã có tài khoản? ",
                        style: TextStyle(color: Colors.black54),
                        children: [
                          TextSpan(
                            text: "ĐĂNG NHẬP",
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
}
