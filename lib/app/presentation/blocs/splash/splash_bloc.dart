import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/data/local/shared_preference_helper.dart';
import 'package:todo_app/core/services/di.dart';

import '../auth/auth_bloc.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SharedPreferencesHelper _prefs;
    final AuthBloc _authBloc;

  SplashBloc(this._authBloc)
      : _prefs = getIt<SharedPreferencesHelper>(),
        super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(SplashLoading());

    // Artificial delay for animation (UX)
    await Future.delayed(const Duration(seconds: 2));
    final userId = _prefs.getLoggedInUserId();
    final rememberMe = _prefs.getRememberMe();
      _authBloc.add(AuthCheckRequested());

    if (userId != null && rememberMe) {
      emit(SplashNavigateToHome());
    } else {
      emit(SplashNavigateToLogin());
    }
  }
}
