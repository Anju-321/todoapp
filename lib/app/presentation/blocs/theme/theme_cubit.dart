import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/local/shared_preference_helper.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferencesHelper _prefsHelper;

  ThemeCubit(this._prefsHelper) : super(ThemeMode.light) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeString = _prefsHelper.getThemeMode();
    final themeMode = themeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
    emit(themeMode);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _prefsHelper.setThemeMode(newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(newMode);
  }
}