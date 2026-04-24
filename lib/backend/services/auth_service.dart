import '../models/user.dart';
import '../repositories/user_repository.dart';

class AuthResult {
  final bool success;
  final String? error;
  final User? user;

  const AuthResult({required this.success, this.error, this.user});
}

class AuthService {
  final UserRepository _userRepo = UserRepository();

  Future<AuthResult> login(String email, String password) async {
    try {
      if (email.trim().isEmpty) {
        return const AuthResult(success: false, error: 'Email is required');
      }
      if (!_isValidEmail(email)) {
        return const AuthResult(success: false, error: 'Enter a valid email');
      }
      if (password.isEmpty) {
        return const AuthResult(success: false, error: 'Password is required');
      }
      if (password.length < 4) {
        return const AuthResult(
            success: false, error: 'Password must be at least 4 characters');
      }

      final ok = await _userRepo.login(email.trim(), password);
      if (!ok) {
        return const AuthResult(success: false, error: 'Login failed');
      }
      final user = await _userRepo.getUser();
      return AuthResult(success: true, user: user);
    } catch (e) {
      return AuthResult(success: false, error: 'An error occurred: $e');
    }
  }

  Future<AuthResult> signup(
      String name, String email, String password) async {
    try {
      if (name.trim().isEmpty) {
        return const AuthResult(success: false, error: 'Name is required');
      }
      if (!_isValidEmail(email)) {
        return const AuthResult(success: false, error: 'Enter a valid email');
      }
      if (password.length < 6) {
        return const AuthResult(
            success: false, error: 'Password must be at least 6 characters');
      }

      final ok = await _userRepo.signup(name.trim(), email.trim(), password);
      if (!ok) {
        return const AuthResult(success: false, error: 'Signup failed');
      }
      final user = await _userRepo.getUser();
      return AuthResult(success: true, user: user);
    } catch (e) {
      return AuthResult(success: false, error: 'An error occurred: $e');
    }
  }

  Future<void> logout() => _userRepo.logout();

  Future<bool> isLoggedIn() => _userRepo.isLoggedIn();

  Future<User> getCurrentUser() => _userRepo.getUser();

  Future<AuthResult> changePassword(String current, String newPass) async {
    try {
      if (newPass.length < 6) {
        return const AuthResult(
            success: false, error: 'New password must be at least 6 characters');
      }
      await _userRepo.changePassword(current, newPass);
      return const AuthResult(success: true);
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }
}
