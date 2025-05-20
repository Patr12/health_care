import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE doctors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        specialty TEXT NOT NULL,
        description TEXT,
        image TEXT
      )
    ''');

    await db.insert('doctors', {
      'name': 'Dr. Jane Smith',
      'specialty': 'Dermatologist',
      'description': 'Expert in skin conditions and treatments.',
      'image': 'assets/images/doctor1.png',
    });

    await db.insert('doctors', {
      'name': 'Dr. John Doe',
      'specialty': 'Cardiologist',
      'description': 'Heart specialist with 10+ years experience.',
      'image': 'assets/images/doctor2.png',
    });
  }


  // User methods
  Future<int> registerUser(String email, String password) async {
    final db = await database;
    return await db.insert('users', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getDoctors() async {
    final db = await initDB();
    return await db.query('doctors');
  }


  insertDoctor(Map<String, String> map) {}
  
  initDB() {}

}
