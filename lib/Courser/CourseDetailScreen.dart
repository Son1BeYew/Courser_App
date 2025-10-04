import 'package:app_courser/Courser/CourseLessonsScreen.dart';
import 'package:flutter/material.dart';

class CourseDetailScreen extends StatefulWidget {
  final Map course;
  final bool isPurchased; // Trạng thái mua

  const CourseDetailScreen({
    super.key,
    required this.course,
    this.isPurchased = false,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late bool _isPurchased;

  @override
  void initState() {
    super.initState();
    _isPurchased = widget.isPurchased;
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(title: Text(course["title"] ?? "Course Detail")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Text(
              course["title"] ?? "No Title",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Price: ${course["price"] ?? "0"} VND",
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              "Category: ${course["category"]?["name"] ?? "Unknown"}",
              style: const TextStyle(fontSize: 16, color: Colors.deepOrange),
            ),
            const SizedBox(height: 16),
            Text(
              course["description"] ?? "No description available",
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const Spacer(),

            // Button
            if (!_isPurchased)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Mua xong
                    setState(() {
                      _isPurchased = true;
                    });

                    // Chuyển sang màn hình danh sách bài học
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseLessonsScreen(
                          course: course,
                          isPurchased: true,
                        ),
                      ),
                    );
                  },
                  child: const Text("Mua ngay"),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Nếu đã mua, chuyển trực tiếp sang danh sách bài học
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseLessonsScreen(
                          course: course,
                          isPurchased: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Xem danh sách bài học"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
