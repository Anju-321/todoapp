import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/repository/auth/auth_repository.dart';
import '../../../domain/entity/user_entity.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthProfileUpdated>(_onAuthProfileUpdated);
    on<AuthLoadSavedLogin>((event, emit) async {
  final rememberMe = _authRepository.getRememberMe();
  final username = _authRepository.getSavedUsername();
  final password = _authRepository.getSavedPassword();

  emit(AuthLoginPrefilled(
    username: username,
    password: password,
    rememberMe: rememberMe,
  ));
});
  }

  

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        username: event.username,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.register(
        username: event.username,
        fullName: event.fullName,
        password: event.password,
        dateOfBirth: event.dateOfBirth,
        profilePicturePath: event.profilePicturePath,
      );
      
      // Auto login after registration
      final loggedInUser = await _authRepository.login(
        username: event.username,
        password: event.password,
        rememberMe: true,
      );
      
      emit(AuthAuthenticated(loggedInUser));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }

 Future<void> _onAuthProfileUpdated(
  AuthProfileUpdated event,
  Emitter<AuthState> emit,
) async {
  emit(AuthLoading());

  try {
    final updatedUser = await _authRepository.updateProfile(
      userId: event.updatedUser.id,
      username: event.updatedUser.username,
      fullName: event.updatedUser.fullName,
      dateOfBirth: event.updatedUser.dateOfBirth,
      profilePicturePath: event.updatedUser.profilePicturePath,
    );

    emit(AuthAuthenticated(updatedUser));
  } catch (e) {
    emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    emit(AuthAuthenticated(event.updatedUser)); // optional fallback
  }
}
}
