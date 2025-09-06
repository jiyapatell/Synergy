import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  static Future<bool> login(String email, String password) async {
    // Simulate API call - in real app, this would call your backend
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock authentication - accept any email/password for demo
    if (email.isNotEmpty && password.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: email.split('@')[0].replaceAll('.', ' ').split(' ').map((word) => 
          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '').join(' '),
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _saveUser(user);
      return true;
    }
    return false;
  }

  static Future<bool> register(String name, String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock registration - accept any valid input for demo
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await _saveUser(user);
      return true;
    }
    return false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<bool> forgotPassword(String email) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    return email.isNotEmpty;
  }
}
