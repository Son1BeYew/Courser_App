import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryManager extends StatefulWidget {
  const CategoryManager({super.key});

  @override
  State<CategoryManager> createState() => _CategoryManagerState();
}

class _CategoryManagerState extends State<CategoryManager> {
  List categories = [];
  final TextEditingController nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final res = await http.get(
      Uri.parse("http://10.0.2.2:5000/api/categories"),
    );
    if (res.statusCode == 200) {
      setState(() => categories = json.decode(res.body));
    }
  }

  Future<void> createCategory() async {
    final res = await http.post(
      Uri.parse("http://10.0.2.2:5000/api/categories"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": nameCtrl.text}),
    );
    if (res.statusCode == 201) {
      fetchCategories();
      Navigator.pop(context);
    }
  }

  Future<void> updateCategory(String id) async {
    final res = await http.put(
      Uri.parse("http://10.0.2.2:5000/api/categories/$id"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": nameCtrl.text}),
    );
    if (res.statusCode == 200) {
      fetchCategories();
      Navigator.pop(context);
    }
  }

  Future<void> deleteCategory(String id) async {
    await http.delete(Uri.parse("http://10.0.2.2:5000/api/categories/$id"));
    fetchCategories();
  }

  void _showDialog({String? id, String? oldName}) {
    nameCtrl.text = oldName ?? "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? "Thêm danh mục" : "Sửa danh mục"),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: "Tên danh mục"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => id == null ? createCategory() : updateCategory(id),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý danh mục")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final c = categories[i];
          return ListTile(
            title: Text(c["name"]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () =>
                      _showDialog(id: c["_id"], oldName: c["name"]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteCategory(c["_id"]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
