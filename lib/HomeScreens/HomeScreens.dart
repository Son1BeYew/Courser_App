import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreens extends StatefulWidget {
  const HomeScreens({super.key});

  @override
  State<HomeScreens> createState() => _HomeScreensState();
}

class _HomeScreensState extends State<HomeScreens> {
  List categories = [];
  List courses = [];
  bool isLoading = true;
  String? userName;
  String? selectedCategoryId;

  /// Get API categories
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/categories"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categories = data is List ? data : [];
        });
      }
    } catch (e) {
      print("Lỗi API categories: $e");
    }
  }

  /// Get courses by category
  Future<void> fetchCoursesByCategory(String categoryId) async {
    setState(() {
      isLoading = true;
      selectedCategoryId = categoryId;
    });
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/courses/category/$categoryId"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          courses = data is List ? data : [];
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load courses");
      }
    } catch (e) {
      print("Lỗi API: $e");
      setState(() {
        courses = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategories().then((_) {
      if (categories.isNotEmpty) {
        // Mặc định load khóa học của category đầu tiên
        fetchCoursesByCategory(categories[0]["_id"]);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get username from arguments
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args.containsKey("userName")) {
      userName = args["userName"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (userName == null)
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          child: const Text(
                            "Xin chào, Đăng nhập ngay",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        )
                      else
                        Text(
                          "Hi, $userName 👋",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 4),
                      const Text(
                        "What would you like to learn today?",
                        style: TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search bar
              _buildSearchBar(),
              const SizedBox(height: 20),

              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: () {}, child: const Text("See All")),
                ],
              ),
              const SizedBox(height: 10),

              if (categories.isEmpty)
                const Text("Không có danh mục nào ")
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final String id = cat["_id"] ?? "";
                      final bool isSelected = selectedCategoryId == id;
                      return _buildCategoryChip(cat, isSelected);
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 20),

              // Courses
              const Text(
                "Courses",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (courses.isEmpty)
                const Text("Không có khóa học được thêm")
              else
                Column(
                  children: courses.map((course) {
                    return _buildCourseCard(
                      title: course["title"] ?? "No title",
                      price: course["price"]?.toString() ?? "0",
                      category: course["category"]?["name"] ?? "Unknown",
                      // 👇 Ưu tiên đúng tên trường bạn lưu trên BE
                      image:
                          course["imageUrl"] // Cloudinary secure_url
                          ??
                          course["image"] ??
                          course["thumbnail"],
                      rating: (course["rating"] is num)
                          ? (course["rating"] as num).toDouble()
                          : null,
                      students: course["students"] is int
                          ? course["students"] as int
                          : null,
                    );
                  }).toList(),
                ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for..",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Map category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        fetchCoursesByCategory(category["_id"]);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          category["name"] ?? "Unknown",
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildCourseCard({
    required String title,
    required String price,
    required String category,
    String? image,
    double? rating,
    int? students,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh hoặc màu nền
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Container(
              height: 90,
              width: double.infinity,
              color: Colors.black12,
              child: image != null
                  ? Image.network(image, fit: BoxFit.cover)
                  : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category + bookmark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category,
                      style: const TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Icon(Icons.bookmark_border, color: Colors.green),
                  ],
                ),
                const SizedBox(height: 6),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Text(
                      "$price/-",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (rating != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text("$rating", style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    const SizedBox(width: 8),
                    if (students != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 16,
                          ),
                          Text(
                            "$students",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
