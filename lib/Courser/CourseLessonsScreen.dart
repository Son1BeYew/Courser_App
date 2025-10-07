import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CourseLessonsScreen extends StatelessWidget {
  final Map course;
  final bool isPurchased;

  const CourseLessonsScreen({
    super.key,
    required this.course,
    required this.isPurchased,
  });

  Future<List<Map<String, dynamic>>> fetchLessons() async {
    try {
      final res = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/lessons?course=${course["_id"]}"),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print("API Response Status: ${res.statusCode}");
      print("API Response Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data["items"]);
      } else {
        throw Exception("Lỗi tải bài học: ${res.statusCode}");
      }
    } catch (e) {
      print("Error fetching lessons: $e");
      throw Exception("Lỗi kết nối: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bài học: ${course["title"] ?? ""}")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchLessons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final lessons = snapshot.data ?? [];

          if (lessons.isEmpty) {
            return const Center(child: Text("Chưa có bài học nào"));
          }

          return ListView.builder(
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              final isOnlineDay = (index + 1) % 10 == 0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(
                      isPurchased ? Icons.book : Icons.lock,
                      color: isPurchased ? Colors.deepPurple : Colors.grey,
                    ),
                    title: Text("Bài ${index + 1}: ${lesson["title"]}"),
                    enabled: isPurchased,
                    onTap: isPurchased
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Mở bài học ${lesson["title"]}"),
                              ),
                            );
                          }
                        : null,
                  ),
                  if (isOnlineDay)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.video_call, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            "Ngày học online",
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
