import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class CourseManager extends StatefulWidget {
  const CourseManager({super.key});

  @override
  State<CourseManager> createState() => _CourseManagerState();
}

class _CourseManagerState extends State<CourseManager> {
  List courses = [];
  List categories = [];
  bool isLoading = true;
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([fetchCourses(), fetchCategories()]);
  }

  Future<void> fetchCategories() async {
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/categories"),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          if (data is List) {
            categories = data;
          } else if (data is Map && data.containsKey('categories')) {
            categories = data['categories'];
          } else {
            categories = [];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải danh mục: $e")),
        );
      }
    }
  }

  Future<void> fetchCourses() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/courses"),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          if (data is List) {
            courses = data;
          } else if (data is Map && data.containsKey('courses')) {
            courses = data['courses'];
          } else {
            courses = [];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải khóa học: $e")),
        );
      }
    }
  }

  Future<void> createCourse() async {
    if (titleCtrl.text.isEmpty || priceCtrl.text.isEmpty || selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    final headers = await AuthService.getAuthHeaders();
    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/courses"),
        headers: headers,
        body: json.encode({
          "title": titleCtrl.text,
          "price": int.tryParse(priceCtrl.text) ?? 0,
          "category": selectedCategoryId,
        }),
      );
      if (res.statusCode == 201) {
        fetchCourses();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã thêm khóa học")),
        );
      } else {
        try {
          final err = json.decode(res.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${err is Map ? err['msg'] ?? err['message'] ?? res.statusCode : res.statusCode}")),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: Status ${res.statusCode}")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  Future<void> updateCourse(String id) async {
    if (titleCtrl.text.isEmpty || priceCtrl.text.isEmpty || selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    final headers = await AuthService.getAuthHeaders();
    try {
      final res = await http.put(
        Uri.parse("http://10.0.2.2:5000/api/courses/$id"),
        headers: headers,
        body: json.encode({
          "title": titleCtrl.text,
          "price": int.tryParse(priceCtrl.text) ?? 0,
          "category": selectedCategoryId,
        }),
      );
      if (res.statusCode == 200) {
        fetchCourses();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã cập nhật khóa học")),
        );
      } else {
        try {
          final err = json.decode(res.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${err is Map ? err['msg'] ?? err['message'] ?? res.statusCode : res.statusCode}")),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: Status ${res.statusCode}")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  Future<void> deleteCourse(String id) async {
    final headers = await AuthService.getAuthHeaders();
    final res = await http.delete(
      Uri.parse("http://10.0.2.2:5000/api/courses/$id"),
      headers: headers,
    );
    if (res.statusCode == 200) {
      fetchCourses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa khóa học")),
      );
    }
  }

  void _showCourseDialog({String? id, Map? course}) {
    if (course != null) {
      titleCtrl.text = course["title"]?.toString() ?? "";
      priceCtrl.text = course["price"]?.toString() ?? "";
      
      final categoryData = course["category"];
      if (categoryData is Map) {
        selectedCategoryId = categoryData["_id"]?.toString();
      } else if (categoryData is String) {
        selectedCategoryId = categoryData;
      } else {
        selectedCategoryId = categories.isNotEmpty ? categories[0]["_id"]?.toString() : null;
      }
    } else {
      titleCtrl.clear();
      priceCtrl.clear();
      selectedCategoryId = categories.isNotEmpty ? categories[0]["_id"]?.toString() : null;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final categoryItems = categories.map<DropdownMenuItem<String>>((cat) {
            final c = cat as Map<String, dynamic>;
            return DropdownMenuItem(
              value: c["_id"]?.toString() ?? "",
              child: Text(c["name"]?.toString() ?? "N/A"),
            );
          }).toList();
          
          final validCategoryIds = categoryItems.map((item) => item.value).toSet();
          if (selectedCategoryId != null && !validCategoryIds.contains(selectedCategoryId)) {
            selectedCategoryId = categoryItems.isNotEmpty ? categoryItems.first.value : null;
          }
          
          return AlertDialog(
            title: Text(id == null ? "Thêm khóa học" : "Sửa khóa học"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: "Tên khóa học",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Giá (VND)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: "Danh mục",
                      border: OutlineInputBorder(),
                    ),
                    items: categoryItems,
                    onChanged: (val) {
                      setDialogState(() => selectedCategoryId = val);
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
              onPressed: () {
                if (id == null) {
                  createCourse();
                } else {
                  updateCourse(id);
                }
              },
              child: const Text("Lưu"),
            ),
          ],
        );
        },
      ),
    );
  }

  void _confirmDelete(String id, String title) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc muốn xóa khóa học '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteCourse(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý khóa học"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCourseDialog(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const Center(child: Text("Chưa có khóa học nào"))
              : ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (_, i) {
                    final c = courses[i] as Map<String, dynamic>;
                    final courseId = c["_id"]?.toString() ?? "";
                    final courseTitle = c["title"]?.toString() ?? "N/A";
                    final coursePrice = c["price"]?.toString() ?? "0";
                    final categoryName = (c["category"] is Map ? c["category"]["name"] : null)?.toString() ?? "N/A";
                    final imageUrl = c["image"]?.toString();
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.book, size: 40),
                              )
                            : const Icon(Icons.book, size: 40),
                        title: Text(
                          courseTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Giá: $coursePrice VND\nDanh mục: $categoryName",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showCourseDialog(id: courseId, course: c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(courseId, courseTitle),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
