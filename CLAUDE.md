# Coding Guidelines - Courser App

## Project Overview
Flutter mobile application for online learning platform with role-based access (admin, giangvien, hocsinh).

## AI Assistant Rules

### Documentation
- ❌ **NEVER** create or update documentation files (README.md, docs, guides) unless explicitly requested by user
- ❌ **NEVER** add comments to code unless explicitly requested
- ✅ Only create/update code files that are functional parts of the application
- ✅ Focus on implementing features, not documenting them

## Architecture & Structure

### Directory Structure
```
lib/
├── services/           # Shared services (auth, API)
├── AdminScreens/       # Admin management screens
├── HomeScreens/        # Main app screens
├── Menu/              # Navigation and account screens
├── Courser/           # Course-related screens
├── Onboarding/        # Onboarding screens
├── main.dart          # App entry point
├── login_screen.dart
└── signup_screen.dart
```

### Naming Conventions
- **Files**: Use `snake_case` for new files (e.g., `auth_service.dart`)
- **Existing files**: Keep PascalCase if already exists (e.g., `AdminDashboard.dart`)
- **Classes**: PascalCase (e.g., `AuthService`, `CategoryManager`)
- **Variables/Functions**: camelCase (e.g., `userRole`, `fetchCategories`)

## API Integration

### Base URL
- Development: `http://10.0.2.2:5000` (Android Emulator)
- API endpoints: `/api/users`, `/api/categories`, `/api/courses`, `/api/lessons`

### Authentication
Always include Authorization header for protected routes:
```dart
final headers = await AuthService.getAuthHeaders();
// Returns: { 'Content-Type': 'application/json', 'Authorization': 'Bearer <token>' }
```

### API Permissions
| Resource | GET | POST | PUT/PATCH | DELETE |
|----------|-----|------|-----------|--------|
| Users | admin | public (register) | admin | admin |
| Categories | public | admin | admin | admin |
| Courses | public | admin/giangvien | admin/giangvien | admin |
| Lessons | public | admin/giangvien | admin/giangvien | admin |

## State Management

### StatefulWidget vs StatelessWidget
- Use `StatefulWidget` when:
  - Need to load data from API
  - Need to check user permissions
  - Need to manage local state
- Use `StatelessWidget` for static/presentation-only widgets

### Async Operations
```dart
Future<void> fetchData() async {
  final headers = await AuthService.getAuthHeaders();
  final res = await http.get(url, headers: headers);
  if (res.statusCode == 200) {
    setState(() => data = json.decode(res.body));
  }
}
```

## Role-Based Access Control

### User Roles
1. **admin**: Full system access
2. **giangvien**: Can create/edit courses and lessons
3. **hocsinh**: View-only access

### Implementing Permissions
```dart
// Check role before showing UI elements
final role = await AuthService.getRole();
if (role == 'admin') {
  // Show admin features
}

// Protect entire screens
@override
void initState() {
  super.initState();
  _checkAuthorization();
}

Future<void> _checkAuthorization() async {
  final role = await AuthService.getRole();
  if (role != 'admin') {
    // Show error and navigate back
  }
}
```

## UI/UX Guidelines

### Error Handling
- Show user-friendly SnackBar messages
- Always handle network errors
- Validate user input before API calls

### Loading States
```dart
bool isLoading = true;

@override
void initState() {
  super.initState();
  _loadData();
}

@override
Widget build(BuildContext context) {
  if (isLoading) {
    return const Center(child: CircularProgressIndicator());
  }
  // ... normal UI
}
```

### Confirmation Dialogs
Always confirm destructive actions (delete):
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text("Xác nhận xóa"),
    content: Text("Bạn có chắc muốn xóa '$name'?"),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text("Huỷ")),
      ElevatedButton(onPressed: _performDelete, child: const Text("Xóa")),
    ],
  ),
);
```

## Common Patterns

### CRUD Operations
```dart
// CREATE
Future<void> create() async {
  final headers = await AuthService.getAuthHeaders();
  await http.post(url, headers: headers, body: json.encode(data));
}

// READ
Future<void> fetch() async {
  final res = await http.get(url);
  if (res.statusCode == 200) {
    setState(() => items = json.decode(res.body));
  }
}

// UPDATE
Future<void> update(String id) async {
  final headers = await AuthService.getAuthHeaders();
  await http.put(Uri.parse("$url/$id"), headers: headers, body: json.encode(data));
}

// DELETE
Future<void> delete(String id) async {
  final headers = await AuthService.getAuthHeaders();
  await http.delete(Uri.parse("$url/$id"), headers: headers);
}
```

### Navigation
```dart
// Push new screen
Navigator.push(context, MaterialPageRoute(builder: (_) => TargetScreen()));

// Replace current screen
Navigator.pushReplacementNamed(context, '/login');

// Pop back
Navigator.pop(context);
```

## Security Best Practices

### Token Management
- ✅ Save token after login
- ✅ Clear token on logout
- ✅ Always send token in Authorization header for protected routes
- ❌ Never hardcode tokens
- ❌ Never log tokens to console

### Data Validation
- Validate email format
- Check password strength
- Sanitize user input
- Handle null/undefined values safely

## Testing & Quality

### Before Committing
1. Run `flutter analyze` to check for issues
2. Test CRUD operations
3. Test with different roles (admin, giangvien, hocsinh)
4. Test error scenarios (network failure, unauthorized access)

### Code Quality
- Remove unused imports
- Remove debug `print()` statements
- Use `const` constructors when possible
- Handle `BuildContext` async warnings (use `mounted` check)

## Dependencies

### Current Packages
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.1
  shared_preferences: ^2.5.3
  cupertino_icons: ^1.0.8
```

### Adding New Packages
1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Import in Dart files
4. Update this guide if it's a major dependency

## API Response Handling

### Success Response
```dart
if (response.statusCode == 200 || response.statusCode == 201) {
  final data = json.decode(response.body);
  // Process data
}
```

### Error Response
```dart
else {
  final err = json.decode(response.body);
  _showMessage(err["msg"] ?? "Đã có lỗi xảy ra");
}
```

### Network Errors
```dart
try {
  // API call
} catch (e) {
  _showMessage("Lỗi kết nối server: $e");
}
```

## Common Issues & Solutions

### Issue: "BuildContext across async gaps"
**Solution**: Check if widget is still mounted
```dart
if (mounted) {
  Navigator.pop(context);
}
```

### Issue: Token not sent in requests
**Solution**: Always use `AuthService.getAuthHeaders()`
```dart
final headers = await AuthService.getAuthHeaders();
await http.post(url, headers: headers, ...);
```

### Issue: Unauthorized access to admin features
**Solution**: Always check role before showing/accessing admin features
```dart
final role = await AuthService.getRole();
if (role != 'admin') {
  // Deny access
}
```

## Development Workflow

1. **Check API permissions** in `API_PERMISSIONS.md` before implementing
2. **Create/Update screens** with proper authorization checks
3. **Use AuthService** for all authenticated requests
4. **Test with different roles**
5. **Run flutter analyze** before committing
6. **Document major changes** in git commit messages

## Contact & Support

For questions about:
- **API endpoints**: Check `D:\Work\LT_DiDong\edu_app\Courser_Server\API_PERMISSIONS.md`
- **Backend issues**: Contact backend team
- **Flutter/Dart**: Check Flutter documentation

---

Last updated: 2024
