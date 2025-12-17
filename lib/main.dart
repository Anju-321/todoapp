import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/app/presentation/blocs/splash/splash_bloc.dart';
import 'package:todo_app/app/presentation/screens/splash/splash_screen.dart';
import 'package:todo_app/core/services/di.dart';
import 'app/data/local/shared_preference_helper.dart';
import 'app/presentation/blocs/auth/auth_bloc.dart';
import 'app/presentation/blocs/theme/theme_cubit.dart';
import 'app/presentation/blocs/todo/todo_bloc.dart';
import 'app/presentation/screens/home/home_screen.dart';
import 'app/presentation/screens/login/login_screen.dart';
import 'app/presentation/screens/profile/profile_screen.dart';
import 'app/presentation/screens/register/register_screen.dart';
import 'app/presentation/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await serviceLocator(); // Add await here
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
         BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>(),
        ),
        BlocProvider<SplashBloc>(
          create: (_) => getIt<SplashBloc>(),
        ),
        // BlocProvider(create: (_) => TodoBloc(getIt<TodoRepository>())),
       BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(getIt<SharedPreferencesHelper>()),
        ),

        BlocProvider(
  create: (context) => getIt<TodoBloc>(),

)
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Todo App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            themeMode: themeMode,
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const HomeScreen(),
             
              '/settings': (_) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
