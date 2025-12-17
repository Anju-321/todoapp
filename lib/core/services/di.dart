import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../app/data/local/database_helper.dart';
import '../../app/data/local/shared_preference_helper.dart';
import '../../app/data/repository/auth/auth_repository.dart';
import '../../app/data/repository/todo/todo_repository.dart';
import '../../app/presentation/blocs/auth/auth_bloc.dart';
import '../../app/presentation/blocs/splash/splash_bloc.dart';
import '../../app/presentation/blocs/todo/todo_bloc.dart';
import 'api_client.dart';

final GetIt getIt = GetIt.instance;

Future<void> serviceLocator()async {
   // Registering Dio instance for API calls
  getIt.registerLazySingleton<Dio>(() => Dio());

  // Registering ApiClient, passing Dio as a dependency
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));

  // SharedPreferences
  final prefsHelper = await SharedPreferencesHelper.getInstance();
  getIt.registerSingleton<SharedPreferencesHelper>(prefsHelper);

  // Database
  final dbHelper = DatabaseHelper.instance;
  getIt.registerSingleton<DatabaseHelper>(dbHelper);


  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
     getIt<DatabaseHelper>(),
     getIt<SharedPreferencesHelper>(),
    ),
  );

  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>()));

  //splash bloc
  getIt.registerFactory(() => SplashBloc());


  // Repository
getIt.registerLazySingleton<TodoRepository>(
  () => TodoRepository(
    getIt<ApiClient>(),
    getIt<DatabaseHelper>(),
  ),
);

// BLoC
getIt.registerFactory(() => TodoBloc(getIt<TodoRepository>(),getIt<AuthRepository>()));


}