import 'package:flutter/material.dart';

class CourseScreen extends StatelessWidget {
  const CourseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách khóa học"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          "Nội dung các khóa học sẽ hiển thị ở đây",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
