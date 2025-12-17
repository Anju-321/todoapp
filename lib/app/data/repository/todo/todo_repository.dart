import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/services/api_client.dart';
import '../../../domain/entity/todo_entity.dart';
import '../../local/database_helper.dart';

class TodoRepository {
  final ApiClient apiClient;
  final DatabaseHelper databaseHelper;

  TodoRepository(this.apiClient, this.databaseHelper);

  Future<List<Todo>> fetchTodos({int start = 0, int limit = 20}) async {
    try {
      // Check connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        // Fetch from API
        final response = await apiClient.get(
          path: 'https://jsonplaceholder.typicode.com/todos',
          queryParams: {
            '_start': start.toString(),
            '_limit': limit.toString(),
          },
          noBaseUrl: true,
        );

        if (response is List) {
          final todos = response.map((json) => Todo.fromJson(json)).toList();
          
          // Cache the todos locally
          await databaseHelper.insertTodos(todos);
          
          return todos;
        }
        return [];
      } else {
        // Fetch from local database when offline
        return await databaseHelper.getTodos(limit: limit, offset: start);
      }
    } catch (e) {
      // If API fails, try to get cached data
      return await databaseHelper.getTodos(limit: limit, offset: start);
    }
  }

  Future<List<Todo>> searchTodos(String query) async {
    return await databaseHelper.searchTodos(query);
  }

  Future<void> toggleFavorite(Todo todo) async {
    final updatedTodo = todo.copyWith(isFavorite: !todo.isFavorite);
    await databaseHelper.updateTodo(updatedTodo);
  }

  Future<void> toggleCompleted(Todo todo) async {
    final updatedTodo = todo.copyWith(completed: !todo.completed);
    await databaseHelper.updateTodo(updatedTodo);
  }

  Future<List<Todo>> getCachedTodos({int limit = 20, int offset = 0}) async {
    return await databaseHelper.getTodos(limit: limit, offset: offset);
  }

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}