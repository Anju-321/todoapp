part of 'todo_bloc.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<Todo> todos;
  final bool hasReachedMax;
  final bool isSearching;
  final bool isOffline;

  const TodoLoaded({
    required this.todos,
    this.hasReachedMax = false,
    this.isSearching = false,
    this.isOffline = false,
  });

  TodoLoaded copyWith({
    List<Todo>? todos,
    bool? hasReachedMax,
    bool? isSearching,
    bool? isOffline,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isSearching: isSearching ?? this.isSearching,
      isOffline: isOffline ?? this.isOffline,
    );
  }

  @override
  List<Object?> get props => [todos, hasReachedMax, isSearching, isOffline];
}

class TodoLoadingMore extends TodoState {
  final List<Todo> currentTodos;

  const TodoLoadingMore(this.currentTodos);

  @override
  List<Object?> get props => [currentTodos];
}

class TodoError extends TodoState {
  final String message;
  final bool hasCachedData;
  final List<Todo> cachedTodos;

  const TodoError({
    required this.message,
    this.hasCachedData = false,
    this.cachedTodos = const [],
  });

  @override
  List<Object?> get props => [message, hasCachedData, cachedTodos];
}

class TodoEmpty extends TodoState {
  final bool isSearching;

  const TodoEmpty({this.isSearching = false});

  @override
  List<Object?> get props => [isSearching];
}

class UserLoaded extends TodoState {
  final User? user;

  const UserLoaded({ this.user});

  @override
  List<Object?> get props => [user];
}


// class TodoSearching extends TodoState {
//   final List<Todo> searchResults;

//   const TodoSearching(this.searchResults);

//   @override
//   List<Object?> get props => [searchResults];
// }

// class TodoSearchEmpty extends TodoState {}
// class TodoSearchError extends TodoState {
//   final String message;

//   const TodoSearchError(this.message);

//   @override
//   List<Object?> get props => [message];
// }