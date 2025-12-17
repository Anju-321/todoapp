part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;
  final bool rememberMe;

  AuthLoginRequested({
    required this.username,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];
}

class AuthRegisterRequested extends AuthEvent {
  final String username;
  final String fullName;
  final String password;
  final DateTime dateOfBirth;
  final String? profilePicturePath;

  AuthRegisterRequested({
    required this.username,
    required this.fullName,
    required this.password,
    required this.dateOfBirth,
    this.profilePicturePath,
  });

  @override
  List<Object?> get props => [username, fullName, password, dateOfBirth, profilePicturePath];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthProfileUpdated extends AuthEvent {
  final User updatedUser;

  AuthProfileUpdated(this.updatedUser);

  @override
  List<Object?> get props => [updatedUser];
}
