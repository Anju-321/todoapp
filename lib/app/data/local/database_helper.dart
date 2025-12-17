import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/entity/user_entity.dart';
import '../../domain/entity/todo_entity.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        username $textType UNIQUE,
        fullName $textType,
        password $textType,
        profilePicturePath $textTypeNullable,
        dateOfBirth $textType,
        createdAt $textType,
        rememberMe $intType
      )
    ''');

    await db.execute('''
      CREATE TABLE todos (
        id $intType,
        userId $intType,
        title $textType,
        completed $intType,
        isFavorite $intType,
        cachedAt $textTypeNullable,
        PRIMARY KEY (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE login_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username $textType,
        attemptTime $textType,
        successful $intType
      )
    ''');
  }

  // User Operations
  Future<User> createUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
    return user;
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<User?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // Todo Operations
  Future<void> insertTodos(List<Todo> todos) async {
    final db = await database;
    final batch = db.batch();
    
    for (var todo in todos) {
      batch.insert(
        'todos',
        todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  Future<List<Todo>> getTodos({int limit = 20, int offset = 0}) async {
    final db = await database;
    final maps = await db.query(
      'todos',
      orderBy: 'id ASC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  Future<List<Todo>> searchTodos(String query) async {
    final db = await database;
    final maps = await db.query(
      'todos',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );

    return maps.map((map) => Todo.fromMap(map)).toList();
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> clearTodos() async {
    final db = await database;
    return db.delete('todos');
  }

  // Login Attempts
  Future<void> recordLoginAttempt(String username, bool successful) async {
    final db = await database;
    await db.insert('login_attempts', {
      'username': username,
      'attemptTime': DateTime.now().toIso8601String(),
      'successful': successful ? 1 : 0,
    });
  }

  Future<int> getRecentFailedAttempts(String username, Duration duration) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(duration).toIso8601String();
    
    final result = await db.query(
      'login_attempts',
      where: 'username = ? AND attemptTime > ? AND successful = 0',
      whereArgs: [username, cutoffTime],
    );
    
    return result.length;
  }

  Future<void> clearLoginAttempts(String username) async {
    final db = await database;
    await db.delete(
      'login_attempts',
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}