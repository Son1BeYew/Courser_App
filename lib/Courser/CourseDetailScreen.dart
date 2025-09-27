import 'package:flutter/material.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course["title"] ?? "Course Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh
            if (course["imageUrl"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  course["imageUrl"],
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 16),

            // Tên khóa học
            Text(
              course["title"] ?? "No Title",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Giá
            Text(
              "Price: ${course["price"] ?? "0"} VND",
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),

            const SizedBox(height: 8),

            // Danh mục
            Text(
              "Category: ${course["category"]?["name"] ?? "Unknown"}",
              style: const TextStyle(fontSize: 16, color: Colors.deepOrange),
            ),

            const SizedBox(height: 16),

            // Mô tả
            Text(
              course["description"] ?? "No description available",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),

            const Spacer(),

            // Button enroll
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Bạn đã mua khóa học này!")),
                  );
                },
                child: const Text("Mua ngay"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
