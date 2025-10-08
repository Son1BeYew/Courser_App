import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserManager extends StatefulWidget {
  const UserManager({super.key});

  @override
  State<UserManager> createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  List users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final res = await http.get(Uri.parse("http://10.0.2.2:5000/api/users"));
    if (res.statusCode == 200) {
      setState(() => users = json.decode(res.body));
    }
  }

  Future<void> deleteUser(String id) async {
    await http.delete(Uri.parse("http://10.0.2.2:5000/api/users/$id"));
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý người dùng")),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i];
          return Card(
            child: ListTile(
              title: Text(u["fullname"]),
              subtitle: Text(u["email"]),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteUser(u["_id"]),
              ),
            ),
          );
        },
      ),
    );
  }
}
