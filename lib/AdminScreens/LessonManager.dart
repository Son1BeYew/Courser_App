import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';

class LessonManager extends StatefulWidget {
  const LessonManager({super.key});

  @override
  State<LessonManager> createState() => _LessonManagerState();
}

class _LessonManagerState extends State<LessonManager> {
  List lessons = [];
  List courses = [];
  bool isLoading = true;
  String? errorMessage;
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController videoUrlCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();
  final TextEditingController orderCtrl = TextEditingController();
  String? selectedCourseId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([fetchLessons(), fetchCourses()]);
  }

  Future<void> fetchCourses() async {
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
          } else if (data is Map && data.containsKey('data')) {
            courses = data['data'];
          } else {
            courses = [];
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi tải khóa học: Status ${res.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối khóa học: $e")),
        );
      }
    }
  }

  Future<void> fetchLessons() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/lessons"),
      );
      
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        
        setState(() {
          if (data is List) {
            lessons = data;
          } else if (data is Map && data.containsKey('items')) {
            lessons = data['items'];
          } else if (data is Map && data.containsKey('lessons')) {
            lessons = data['lessons'];
          } else if (data is Map && data.containsKey('data')) {
            lessons = data['data'];
          } else {
            lessons = [];
          }
          isLoading = false;
          errorMessage = null;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Lỗi tải bài học: Status ${res.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Lỗi kết nối: $e";
      });
    }
  }

  Future<void> createLesson() async {
    if (titleCtrl.text.isEmpty || videoUrlCtrl.text.isEmpty || selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    final headers = await AuthService.getAuthHeaders();
    try {
      final res = await http.post(
        Uri.parse("http://10.0.2.2:5000/api/lessons"),
        headers: headers,
        body: json.encode({
          "course": selectedCourseId,
          "title": titleCtrl.text,
          "videoUrl": videoUrlCtrl.text,
          "content": contentCtrl.text,
          "order": int.tryParse(orderCtrl.text) ?? 1,
        }),
      );
      if (res.statusCode == 201) {
        fetchLessons();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã thêm bài học")),
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

  Future<void> updateLesson(String id) async {
    if (titleCtrl.text.isEmpty || videoUrlCtrl.text.isEmpty || selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin")),
      );
      return;
    }

    final headers = await AuthService.getAuthHeaders();
    try {
      final res = await http.patch(
        Uri.parse("http://10.0.2.2:5000/api/lessons/$id"),
        headers: headers,
        body: json.encode({
          "course": selectedCourseId,
          "title": titleCtrl.text,
          "videoUrl": videoUrlCtrl.text,
          "content": contentCtrl.text,
          "order": int.tryParse(orderCtrl.text) ?? 1,
        }),
      );
      if (res.statusCode == 200) {
        fetchLessons();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã cập nhật bài học")),
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

  Future<void> deleteLesson(String id) async {
    final headers = await AuthService.getAuthHeaders();
    final res = await http.delete(
      Uri.parse("http://10.0.2.2:5000/api/lessons/$id"),
      headers: headers,
    );
    if (res.statusCode == 200) {
      fetchLessons();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã xóa bài học")),
      );
    }
  }

  void _showLessonDialog({String? id, Map? lesson}) {
    if (lesson != null) {
      titleCtrl.text = lesson["title"]?.toString() ?? "";
      videoUrlCtrl.text = lesson["videoUrl"]?.toString() ?? "";
      contentCtrl.text = lesson["content"]?.toString() ?? "";
      orderCtrl.text = lesson["order"]?.toString() ?? "1";
      
      final courseData = lesson["course"];
      if (courseData is Map) {
        selectedCourseId = courseData["_id"]?.toString();
      } else if (courseData is String) {
        selectedCourseId = courseData;
      } else {
        selectedCourseId = courses.isNotEmpty ? courses[0]["_id"]?.toString() : null;
      }
    } else {
      titleCtrl.clear();
      videoUrlCtrl.clear();
      contentCtrl.clear();
      orderCtrl.text = "1";
      selectedCourseId = courses.isNotEmpty ? courses[0]["_id"]?.toString() : null;
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          final courseItems = courses.map<DropdownMenuItem<String>>((course) {
            final c = course as Map<String, dynamic>;
            return DropdownMenuItem(
              value: c["_id"]?.toString() ?? "",
              child: Text(c["title"]?.toString() ?? "N/A"),
            );
          }).toList();
          
          final validCourseIds = courseItems.map((item) => item.value).toSet();
          if (selectedCourseId != null && !validCourseIds.contains(selectedCourseId)) {
            selectedCourseId = courseItems.isNotEmpty ? courseItems.first.value : null;
          }
          
          return AlertDialog(
            title: Text(id == null ? "Thêm bài học" : "Sửa bài học"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCourseId,
                    decoration: const InputDecoration(
                      labelText: "Khóa học",
                      border: OutlineInputBorder(),
                    ),
                    items: courseItems,
                    onChanged: (val) {
                      setDialogState(() => selectedCourseId = val);
                    },
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: "Tiêu đề bài học",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoUrlCtrl,
                  decoration: const InputDecoration(
                    labelText: "Video URL",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Nội dung",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: orderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Thứ tự",
                    border: OutlineInputBorder(),
                  ),
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
                  createLesson();
                } else {
                  updateLesson(id);
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
        content: Text("Bạn có chắc muốn xóa bài học '$title'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteLesson(id);
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
        title: const Text("Quản lý bài học"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLessonDialog(),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text("Thử lại"),
                      ),
                    ],
                  ),
                )
              : lessons.isEmpty
                  ? const Center(child: Text("Chưa có bài học nào"))
                  : ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (_, i) {
                    final l = lessons[i] as Map<String, dynamic>;
                    final lessonId = l["_id"]?.toString() ?? "";
                    final lessonTitle = l["title"]?.toString() ?? "N/A";
                    final lessonOrder = l["order"]?.toString() ?? (i + 1).toString();
                    final courseTitle = (l["course"] is Map ? l["course"]["title"] : null)?.toString() ?? "N/A";
                    final videoUrl = l["videoUrl"]?.toString() ?? "N/A";
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            lessonOrder,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          lessonTitle,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Khóa học: $courseTitle\nVideo: $videoUrl",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _showLessonDialog(id: lessonId, lesson: l),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(lessonId, lessonTitle),
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
