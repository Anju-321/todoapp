import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String password;
  final String? profilePicturePath;
  final DateTime dateOfBirth;
  final DateTime createdAt;
  final bool rememberMe;

  const User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.password,
    this.profilePicturePath,
    required this.dateOfBirth,
    required this.createdAt,
    this.rememberMe = false,
  });

  User copyWith({
    String? id,
    String? username,
    String? fullName,
    String? password,
    String? profilePicturePath,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    bool? rememberMe,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      password: password ?? this.password,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'password': password,
      'profilePicturePath': profilePicturePath,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'rememberMe': rememberMe ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      username: map['username'] as String,
      fullName: map['fullName'] as String,
      password: map['password'] as String,
      profilePicturePath: map['profilePicturePath'] as String?,
      dateOfBirth: DateTime.parse(map['dateOfBirth'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      rememberMe: (map['rememberMe'] as int) == 1,
    );
  }

  double get profileCompleteness {
    int completed = 0;
    int total = 5;

    if (username.isNotEmpty) completed++;
    if (fullName.isNotEmpty) completed++;
    if (profilePicturePath != null && profilePicturePath!.isNotEmpty) completed++;
    if (dateOfBirth.isBefore(DateTime.now())) completed++;
    completed++; // Password always exists

    return (completed / total) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        fullName,
        password,
        profilePicturePath,
        dateOfBirth,
        createdAt,
        rememberMe,
      ];
}