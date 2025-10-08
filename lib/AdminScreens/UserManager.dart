import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class UserManager extends StatefulWidget {
  const UserManager({super.key});

  @override
  State<UserManager> createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  List users = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  String selectedRole = 'hocsinh';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final headers = await AuthService.getAuthHeaders();
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/users"),
        headers: headers,
      );

      if (res.statusCode == 200) {
        final responseBody = res.body;
        final data = json.decode(responseBody);
        setState(() {
          if (data is List) {
            users = data;
          } else if (data is Map && data.containsKey('users')) {
            users = data['users'];
          } else if (data is Map && data.containsKey('data')) {
            users = data['data'];
          } else {
            users = [data];
          }
          isLoading = false;
        });
      } else {
        final err = json.decode(res.body);
        setState(() {
          errorMessage = err["msg"] ?? "Lỗi: ${res.statusCode}";
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        errorMessage = "Lỗi: $e";
        isLoading = false;
      });
    }
  }

  Future<void> updateUser(String id) async {
    final headers = await AuthService.getAuthHeaders();
    final body = <String, dynamic>{
      "fullname": nameCtrl.text,
      "email": emailCtrl.text,
      "role": selectedRole,
    };
    if (passCtrl.text.isNotEmpty) {
      body["password"] = passCtrl.text;
    }

    final res = await http.put(
      Uri.parse("http://10.0.2.2:5000/api/users/$id"),
      headers: headers,
      body: json.encode(body),
    );
    if (res.statusCode == 200) {
      fetchUsers();
      Navigator.pop(context);
    }
  }

  Future<void> deleteUser(String id) async {
    final headers = await AuthService.getAuthHeaders();
    await http.delete(
      Uri.parse("http://10.0.2.2:5000/api/users/$id"),
      headers: headers,
    );
    fetchUsers();
  }

  void _showEditDialog(dynamic user) {
    nameCtrl.text = user["fullname"] ?? "";
    emailCtrl.text = user["email"] ?? "";
    passCtrl.text = "";
    selectedRole = user["role"] ?? "hocsinh";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Sửa người dùng"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Họ tên"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Mật khẩu mới (để trống nếu không đổi)",
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: "Vai trò"),
                  items: const [
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    DropdownMenuItem(
                        value: 'giangvien', child: Text('Giảng viên')),
                    DropdownMenuItem(value: 'hocsinh', child: Text('Học sinh')),
                  ],
                  onChanged: (val) {
                    setDialogState(() => selectedRole = val!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Huỷ"),
            ),
            ElevatedButton(
              onPressed: () => updateUser(user["_id"]),
              child: const Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý người dùng"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUsers,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: fetchUsers,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Thử lại"),
                      ),
                    ],
                  ),
                )
              : users.isEmpty
                  ? const Center(child: Text("Chưa có người dùng nào"))
                  : ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (_, i) {
                        final u = users[i];
                        return Card(
                          child: ListTile(
                            title: Text(u["fullname"] ?? "N/A"),
                            subtitle: Text("${u["email"] ?? "N/A"} - ${u["role"] ?? "N/A"}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.orange),
                                  onPressed: () => _showEditDialog(u),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteUser(u["_id"]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
