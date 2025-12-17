import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/app/domain/entity/user_entity.dart';

import '../../../data/repository/auth/auth_repository.dart';
import '../../../data/repository/todo/todo_repository.dart';
import '../../../domain/entity/todo_entity.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository repository;
  //  final AuthRepository _authRepository;
  final int pageSize = 20;
  int currentPage = 0;
  List<Todo> allTodos = [];
  Timer? _debounceTimer;
  //  User? _currentUser; //

  TodoBloc(this.repository, ) : super(TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<LoadMoreTodosEvent>(_onLoadMoreTodos);
    on<SearchTodosEvent>(_onSearchTodos);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<ToggleCompletedEvent>(_onToggleCompleted);
    on<RefreshTodosEvent>(_onRefreshTodos);
   
  }


  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      if (!event.isRefresh) {
        emit(TodoLoading());
      }

      currentPage = 0;
      final isOnline = await repository.isOnline();
      
      final todos = await repository.fetchTodos(
        start: 0,
        limit: pageSize,
      );

      allTodos = todos;

      if (todos.isEmpty) {
        emit(const TodoEmpty());
      } else {
        emit(TodoLoaded(
          todos: todos,
          hasReachedMax: todos.length < pageSize,
          isOffline: !isOnline,
        ));
      }
    } catch (e) {
      // Try to load cached data on error
      try {
        final cachedTodos = await repository.getCachedTodos(limit: pageSize);
        if (cachedTodos.isNotEmpty) {
          allTodos = cachedTodos;
          emit(TodoError(
            message: 'Failed to load todos. Showing cached data.',
            hasCachedData: true,
            cachedTodos: cachedTodos,
          ));
        } else {
          emit(TodoError(message: 'Failed to load todos: ${e.toString()}'));
        }
      } catch (_) {
        emit(TodoError(message: 'Failed to load todos: ${e.toString()}'));
      }
    }
  }

  Future<void> _onLoadMoreTodos(
    LoadMoreTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    final currentState = state;
    if (currentState is TodoLoaded && !currentState.hasReachedMax) {
      try {
        emit(TodoLoadingMore(currentState.todos));

        currentPage++;
        final newTodos = await repository.fetchTodos(
          start: currentPage * pageSize,
          limit: pageSize,
        );

        allTodos = [...allTodos, ...newTodos];

        emit(TodoLoaded(
          todos: allTodos,
          hasReachedMax: newTodos.length < pageSize,
          isOffline: currentState.isOffline,
        ));
      } catch (e) {
        emit(currentState); // Revert to previous state on error
      }
    }
  }

  Future<void> _onSearchTodos(
  SearchTodosEvent event,
  Emitter<TodoState> emit,
) async {
  final query = event.query.trim().toLowerCase();

  if (query.isEmpty) {
    emit(TodoLoaded(
      todos: allTodos,
      hasReachedMax: allTodos.length < pageSize,
    ));
    return;
  }

  final filtered = allTodos.where((todo) {
    return todo.title.toLowerCase().contains(query);
  }).toList();

  if (filtered.isEmpty) {
    emit(const TodoEmpty(isSearching: true));
  } else {
    emit(TodoLoaded(
      todos: filtered,
      hasReachedMax: true,
      isSearching: true,
    ));
  }
}

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await repository.toggleFavorite(event.todo);
      
      // Update local list
      final updatedTodo = event.todo.copyWith(isFavorite: !event.todo.isFavorite);
      final updatedAllTodos = allTodos.map((todo) {
        return todo.id == updatedTodo.id ? updatedTodo : todo;
      }).toList();
      
      allTodos = updatedAllTodos;

      if (state is TodoLoaded) {
        final currentState = state as TodoLoaded;
        final updatedTodos = currentState.todos.map((todo) {
          return todo.id == updatedTodo.id ? updatedTodo : todo;
        }).toList();

        emit(currentState.copyWith(todos: updatedTodos));
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to update favorite: ${e.toString()}'));
    }
  }

  Future<void> _onToggleCompleted(
    ToggleCompletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    try {
      await repository.toggleCompleted(event.todo);
      
      // Update local list
      final updatedTodo = event.todo.copyWith(completed: !event.todo.completed);
      final updatedAllTodos = allTodos.map((todo) {
        return todo.id == updatedTodo.id ? updatedTodo : todo;
      }).toList();
      
      allTodos = updatedAllTodos;

      if (state is TodoLoaded) {
        final currentState = state as TodoLoaded;
        final updatedTodos = currentState.todos.map((todo) {
          return todo.id == updatedTodo.id ? updatedTodo : todo;
        }).toList();

        emit(currentState.copyWith(todos: updatedTodos));
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to update completion: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshTodos(
    RefreshTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    add(const LoadTodosEvent(isRefresh: true));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
