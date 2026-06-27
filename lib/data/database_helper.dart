import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/watched_item.dart';
import 'models/user.dart';

/// Singleton database helper for the Watched app.
/// Manages the SQLite `watched.db` database with full CRUD operations.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'watched.db');

    // Incremented version to 3 to trigger onUpgrade (status column)
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        profile_photo_path TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create watched table
    await db.execute('''
      CREATE TABLE watched (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        genre TEXT NOT NULL,
        season INTEGER,
        episode INTEGER,
        synopsis TEXT,
        rating REAL,
        review TEXT,
        poster_path TEXT,
        status TEXT DEFAULT 'Sudah Nonton',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop existing tables and recreate to apply new schema with user_id
      await db.execute('DROP TABLE IF EXISTS watched');
      await db.execute('DROP TABLE IF EXISTS users');
      await _onCreate(db, newVersion);
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE watched ADD COLUMN status TEXT DEFAULT 'Sudah Nonton'",
      );
    }
  }

  // --- Auth & User Methods ---

  Future<int> registerUser(User user) async {
    final db = await database;
    try {
      return await db.insert('users', user.toMap());
    } catch (e) {
      // Return -1 if unique constraint fails
      return -1;
    }
  }

  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<int> updateProfilePhoto(int userId, String photoPath) async {
    final db = await database;
    return await db.update(
      'users',
      {'profile_photo_path': photoPath},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // --- Watched Items Methods ---

  Future<int> insertItem(WatchedItem item) async {
    final db = await database;
    return await db.insert(
      'watched',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<WatchedItem>> getAllItems(int userId) async {
    final db = await database;
    final maps = await db.query(
      'watched',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => WatchedItem.fromMap(map)).toList();
  }

  Future<WatchedItem?> getItemById(int id) async {
    final db = await database;
    final maps = await db.query(
      'watched',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return WatchedItem.fromMap(maps.first);
  }

  Future<int> updateItem(WatchedItem item) async {
    final db = await database;
    return await db.update(
      'watched',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'watched',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCountByCategory(int userId, String category) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM watched WHERE user_id = ? AND category = ?',
      [userId, category],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
