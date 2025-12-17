part of 'todo_bloc.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}
 class LoadUserEvent extends TodoEvent {
  final User? user;
  const LoadUserEvent({ this.user});

  @override
  List<Object?> get props => [user];
}

class LoadTodosEvent extends TodoEvent {
  final bool isRefresh;

  const LoadTodosEvent({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreTodosEvent extends TodoEvent {
  const LoadMoreTodosEvent();
}

class SearchTodosEvent extends TodoEvent {
  final String query;

  const SearchTodosEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleFavoriteEvent extends TodoEvent {
  final Todo todo;

  const ToggleFavoriteEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class ToggleCompletedEvent extends TodoEvent {
  final Todo todo;

  const ToggleCompletedEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class RefreshTodosEvent extends TodoEvent {
  const RefreshTodosEvent();
}