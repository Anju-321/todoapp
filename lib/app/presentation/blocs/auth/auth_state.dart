part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
class AuthLoginPrefilled extends AuthState {
  final String? username;
  final String? password;
  final bool rememberMe;

   AuthLoginPrefilled({
    this.username,
    this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];
}