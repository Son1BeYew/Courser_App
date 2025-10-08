import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _baseUrl = 'http://10.0.2.2:5000';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
  );

  static Future<void> saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await _googleSignIn.signOut();
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return {"success": false, "message": "Đăng nhập bị hủy"};
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        return {"success": false, "message": "Không lấy được token từ Google"};
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/api/users/google-login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"idToken": idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String token = data["token"] ?? "";
        String role = data["user"]?["role"] ?? "hocsinh";
        String userName = data["user"]?["name"] ?? googleUser.displayName ?? "Người dùng";

        await saveToken(token, role);

        return {
          "success": true,
          "userName": userName,
          "role": role,
        };
      } else {
        final err = json.decode(response.body);
        return {"success": false, "message": err["msg"] ?? "Đăng nhập thất bại"};
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi: $e"};
    }
  }
}
