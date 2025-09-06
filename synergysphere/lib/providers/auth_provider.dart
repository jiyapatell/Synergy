import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize authentication';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await AuthService.login(email, password);
      if (success) {
        _currentUser = await AuthService.getCurrentUser();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await AuthService.register(name, email, password);
      if (success) {
        _currentUser = await AuthService.getCurrentUser();
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await AuthService.forgotPassword(email);
      if (success) {
        return true;
      } else {
        _errorMessage = 'Failed to send reset email. Please try again.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to send reset email. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Logout failed. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
