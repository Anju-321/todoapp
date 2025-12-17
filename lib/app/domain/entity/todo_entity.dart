import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final int userId;
  final String title;
  final bool completed;
  final bool isFavorite;
  final DateTime? cachedAt;

  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.isFavorite = false,
    this.cachedAt,
  });

  Todo copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    bool? isFavorite,
    DateTime? cachedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isFavorite: isFavorite ?? this.isFavorite,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed ? 1 : 0,
      'isFavorite': isFavorite ? 1 : 0,
      'cachedAt': cachedAt?.toIso8601String(),
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as int,
      userId: map['userId'] as int,
      title: map['title'] as String,
      completed: (map['completed'] is int)
          ? (map['completed'] as int) == 1
          : map['completed'] as bool,
      isFavorite: map['isFavorite'] != null
          ? (map['isFavorite'] is int)
              ? (map['isFavorite'] as int) == 1
              : map['isFavorite'] as bool
          : false,
      cachedAt: map['cachedAt'] != null
          ? DateTime.parse(map['cachedAt'] as String)
          : null,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      isFavorite: false,
      cachedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, userId, title, completed, isFavorite, cachedAt];
}