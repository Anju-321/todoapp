import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../domain/entity/user_entity.dart';
import '../../local/database_helper.dart';
import '../../local/shared_preference_helper.dart';

class AuthRepository {
  final DatabaseHelper _dbHelper;
  final SharedPreferencesHelper _prefsHelper;

  AuthRepository(this._dbHelper, this._prefsHelper);

  Future<User?> getCurrentUser() async {
    final userId = _prefsHelper.getLoggedInUserId();
    if (userId == null) return null;
    return await _dbHelper.getUserById(userId);
  }

  Future<bool> isLoggedIn() async {
    final userId = _prefsHelper.getLoggedInUserId();
    return userId != null;
  }
  bool getRememberMe() => _prefsHelper.getRememberMe();
String? getSavedUsername() => _prefsHelper.getSavedUsername();
String? getSavedPassword() => _prefsHelper.getSavedPassword();


  Future<User> register({
    required String username,
    required String fullName,
    required String password,
    required DateTime dateOfBirth,
    String? profilePicturePath,
  }) async {
    // Check if username exists
    final exists = await _dbHelper.usernameExists(username);
    if (exists) {
      throw Exception('Username already exists');
    }

    // Validate password strength
    if (!_isPasswordStrong(password)) {
      throw Exception('Password must be at least 8 characters with uppercase, lowercase, and number');
    }

    // Save profile picture if provided
    String? savedPicturePath;
    if (profilePicturePath != null) {
      savedPicturePath = await _saveProfilePicture(profilePicturePath);
    }

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      fullName: fullName,
      password: password, // In production, hash this!
      dateOfBirth: dateOfBirth,
      profilePicturePath: savedPicturePath,
      createdAt: DateTime.now(),
    );

    await _dbHelper.createUser(user);
    return user;
  }

  Future<User> login({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    // Check for account lockout
    final failedAttempts = await _dbHelper.getRecentFailedAttempts(
      username,
      const Duration(minutes: 15),
    );

    if (failedAttempts >= 5) {
      throw Exception('Account temporarily locked due to multiple failed attempts. Try again in 15 minutes.');
    }

    final user = await _dbHelper.getUserByUsername(username);

    if (user == null || user.password != password) {
      await _dbHelper.recordLoginAttempt(username, false);
      throw Exception('Invalid username or password');
    }

    // Successful login
    await _dbHelper.recordLoginAttempt(username, true);
    await _dbHelper.clearLoginAttempts(username);
    
    await _prefsHelper.setLoggedInUserId(user.id);
    await _prefsHelper.setRememberMe(rememberMe);

    if (rememberMe) {
    await _prefsHelper.saveCredentials(username, password);
  } else {
    await _prefsHelper.clearCredentials();
  }

    return user.copyWith(rememberMe: rememberMe);
  }

  Future<void> logout() async {
  final rememberMe = _prefsHelper.getRememberMe();

  if (!rememberMe) {
    // Full logout
    await _prefsHelper.clearAuth();
    await _prefsHelper.clearCredentials();
  }
  // else: do nothing → auto login next time
}



  Future<User> updateProfile({
    required String userId,
    String? username,
    String? fullName,
    DateTime? dateOfBirth,
    String? profilePicturePath,
  }) async {
    final user = await _dbHelper.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    // Check username uniqueness if changed
    if (username != null && username != user.username) {
      final exists = await _dbHelper.usernameExists(username);
      if (exists) {
        throw Exception('Username already taken');
      }
    }

    // Save new profile picture if provided
    String? savedPicturePath = user.profilePicturePath;
    if (profilePicturePath != null && profilePicturePath != user.profilePicturePath) {
      savedPicturePath = await _saveProfilePicture(profilePicturePath);
      
      // Delete old picture
      if (user.profilePicturePath != null) {
        try {
          await File(user.profilePicturePath!).delete();
        } catch (e) {
          // Ignore if file doesn't exist
        }
      }
    }

    final updatedUser = user.copyWith(
      username: username,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      profilePicturePath: savedPicturePath,
    );

    await _dbHelper.updateUser(updatedUser);
    return updatedUser;
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    
    return hasUppercase && hasLowercase && hasDigit;
  }

  Future<String> _saveProfilePicture(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
    final savedPath = path.join(appDir.path, 'profile_pictures', fileName);
    
    // Create directory if it doesn't exist
    await Directory(path.dirname(savedPath)).create(recursive: true);
    
    // Copy file
    await File(sourcePath).copy(savedPath);
    
    return savedPath;
  }
}