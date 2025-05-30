import 'package:health/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // User roles constants
  static const String ROLE_PATIENT = 'patient';
  static const String ROLE_DOCTOR = 'doctor';
  static const String ROLE_ADMIN = 'admin';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('health_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Incremented version for role-based system
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create all tables
    await _createUserTable(db);
    await _createDoctorProfileTable(db);
    await _createAppointmentTable(db);
    await _createMessageTable(db);
    await _createHealthInfoTable(db);
    await _createScheduleTable(db);
    await _createAdminControlsTable(db);

    // Insert initial admin account
    await _insertInitialAdmin(db);
    await _insertSampleDoctors(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createScheduleTable(db);
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE users ADD COLUMN role TEXT DEFAULT "patient"',
      );
      await _createDoctorProfileTable(db);
      await _createAdminControlsTable(db);
      await _insertInitialAdmin(db);
      await _insertSampleDoctors(db);
    }
  }

  // Table creation methods
  Future<void> _createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone_number TEXT,
        date_of_birth TEXT,
        blood_type TEXT,
        gender TEXT,  
        marital_status TEXT,
        height REAL,
        weight REAL,
        role TEXT DEFAULT '$ROLE_PATIENT', 
        is_verified INTEGER DEFAULT 0,  -- 0 = not verified, 1 = verified
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _createDoctorProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE doctor_profiles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE,
        specialty TEXT NOT NULL,
        description TEXT,
        license_number TEXT UNIQUE,
        hospital TEXT,
        experience_years INTEGER,
        rating REAL DEFAULT 0.0,
        consultation_fee REAL,
        available_for_video INTEGER DEFAULT 1, -- 0 = no, 1 = yes
      available_for_sms INTEGER DEFAULT 1,   -- 0 = no, 1 = yes
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createAppointmentTable(Database db) async {
    await db.execute('''
      CREATE TABLE appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        doctor_id INTEGER,
        appointment_date TEXT NOT NULL,
        appointment_time TEXT NOT NULL,
        status TEXT DEFAULT 'pending',  -- pending, confirmed, cancelled, completed
        reason TEXT,
        notes TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (doctor_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _createMessageTable(Database db) async {
    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id INTEGER,
        receiver_id INTEGER,
        message_text TEXT NOT NULL,
        is_read INTEGER DEFAULT 0,  -- 0 = unread, 1 = read
        sent_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (sender_id) REFERENCES users (id),
        FOREIGN KEY (receiver_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _createHealthInfoTable(Database db) async {
    await db.execute('''
      CREATE TABLE health_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE,
        height REAL,
        weight REAL,
        blood_pressure TEXT,
        allergies TEXT,
        chronic_conditions TEXT,
        medications TEXT,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createScheduleTable(Database db) async {
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        doctor_id INTEGER,
        day_of_week TEXT NOT NULL,  -- Monday, Tuesday, etc.
        start_time TEXT NOT NULL,    -- 09:00
        end_time TEXT NOT NULL,      -- 17:00
        is_recurring INTEGER DEFAULT 1,  -- 1 = recurring, 0 = one-time
        FOREIGN KEY (doctor_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createAdminControlsTable(Database db) async {
    await db.execute('''
      CREATE TABLE admin_controls (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        setting_name TEXT UNIQUE NOT NULL,
        setting_value TEXT,
        description TEXT,
        last_updated TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Insert initial data
  Future<void> _insertInitialAdmin(db) async {
    await db.insert('users', {
      'full_name': 'System Admin',
      'email': 'admin@healthapp.com',
      'password': 'admin123', // In production, use hashed password
      'role': ROLE_ADMIN,
      'is_verified': 1,
    });
  }

  Future<void> _insertSampleDoctors(db) async {
    // First create doctor user accounts
    final drSarahId = await db.insert('users', {
      'full_name': 'Dr. Sarah Johnson',
      'email': 'sarah@hospital.com',
      'password': 'doctor123',
      'role': ROLE_DOCTOR,
      'is_verified': 1,
    });

    final drMichaelId = await db.insert('users', {
      'full_name': 'Dr. Michael Chen',
      'email': 'michael@hospital.com',
      'password': 'doctor123',
      'role': ROLE_DOCTOR,
      'is_verified': 1,
    });

    // Then create their doctor profiles
    await db.insert('doctor_profiles', {
      'user_id': drSarahId,
      'specialty': 'Cardiology',
      'description': 'Specializes in heart conditions with 10 years experience',
      'license_number': 'MD-12345',
      'hospital': 'City General Hospital',
      'experience_years': 10,
      'consultation_fee': 50.00,
    });

    await db.insert('doctor_profiles', {
      'user_id': drMichaelId,
      'specialty': 'Pediatrics',
      'description': 'Child specialist with gentle approach',
      'license_number': 'MD-67890',
      'hospital': 'Children\'s Medical Center',
      'experience_years': 7,
      'consultation_fee': 45.00,
    });
  }

  // ========== USER OPERATIONS ========== //
  Future<int> registerUser(
    Map<String, dynamic> userData, {
    String role = ROLE_PATIENT,
  }) async {
    final db = await database;
    userData['role'] = role;
    return await db.insert('users', userData);
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

  Future<int> updateUserProfile(
    int userId,
    Map<String, dynamic> updates,
  ) async {
    final db = await database;
    return await db.update(
      'users',
      updates,
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }
  Future<bool> checkUserExists(String email) async {
  final db = await database;
  final result = await db.query(
    'users',
    where: 'email = ?',
    whereArgs: [email],
  );
  return result.isNotEmpty;
}

  // ========== DOCTOR OPERATIONS ========== //

  Future<int> registerDoctor(
    Map<String, dynamic> userData,
    Map<String, dynamic> doctorProfile,
  ) async {
    final db = await database;
    return await db.transaction((txn) async {
      final userId = await txn.insert('users', {
        ...userData,
        'role': ROLE_DOCTOR,
      });
      await txn.insert('doctor_profiles', {
        ...doctorProfile,
        'user_id': userId,
      });
      return userId;
    });
  }

  Future<List<Map<String, dynamic>>> getVerifiedDoctors() async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT u.id, u.full_name, u.email, u.phone_number, 
             d.specialty, d.description, d.hospital, d.experience_years, d.rating
      FROM users u
      JOIN doctor_profiles d ON u.id = d.user_id
      WHERE u.role = ? AND u.is_verified = 1
    ''',
      [ROLE_DOCTOR],
    );
  }

  Future<Map<String, dynamic>?> getDoctorProfile(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT u.*, d.* 
      FROM users u
      LEFT JOIN doctor_profiles d ON u.id = d.user_id
      WHERE u.id = ? AND u.role = ?
    ''',
      [userId, ROLE_DOCTOR],
    );
    return result.isNotEmpty ? result.first : null;
  }

 Future<List<Map<String, dynamic>>> getAvailableDoctors(String communicationType) async {
  final db = await database;
  return await db.rawQuery(
    '''
    SELECT u.id, u.full_name, u.phone_number, d.specialty, d.hospital, 
           d.experience_years, d.available_for_video, d.available_for_sms
    FROM users u
    JOIN doctor_profiles d ON u.id = d.user_id
    WHERE u.role = ? 
      AND (d.available_for_${communicationType} = 1)
      AND u.is_verified = 1
    ''',
    [ROLE_DOCTOR],
  );
}

  Future<String?> getDoctorPhoneNumber(int doctorId) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['phone_number'],
      where: 'id = ?',
      whereArgs: [doctorId],
    );
    return result.isNotEmpty ? result.first['phone_number'] as String? : null;
  }

  // ========== ADMIN OPERATIONS ========== //
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> updateUserRole(int userId, String newRole) async {
    final db = await database;
    return await db.update(
      'users',
      {'role': newRole},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<int> verifyDoctor(int userId) async {
    final db = await database;
    return await db.update(
      'users',
      {'is_verified': 1},
      where: 'id = ? AND role = ?',
      whereArgs: [userId, ROLE_DOCTOR],
    );
  }

  Future<int> updateSystemSetting(
    String settingName,
    String settingValue,
  ) async {
    final db = await database;
    return await db.update(
      'admin_controls',
      {'setting_value': settingValue},
      where: 'setting_name = ?',
      whereArgs: [settingName],
    );
  }

  Future<Map<String, dynamic>> getCurrentPatientUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      throw Exception('No patient user logged in');
    }

    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ? AND role = ?',
      whereArgs: [userId, ROLE_PATIENT],
    );

    if (result.isEmpty) {
      throw Exception('Patient user not found');
    }

    return result.first;
  }

  Future<List<Map<String, dynamic>>> getPatientAppointments(
    int patientId,
  ) async {
    final db = await database;
    return await db.query(
      'appointments',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'appointment_date DESC',
    );
  }

  // ========== APPOINTMENT OPERATIONS ========== //
  Future<int> bookAppointment(Map<String, dynamic> appointmentData) async {
    final db = await database;
    return await db.insert('appointments', appointmentData);
  }

  Future<void> createAppointment(Map<String, dynamic> appointment) async {
    final db = await database;
    await db.insert('appointments', appointment);
  }

  Future<List<Map<String, dynamic>>> getUserAppointments(int userId) async {
    final db = await database;
    return await db.query(
      'appointments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'appointment_date, appointment_time',
    );
  }

  Future<List<Map<String, dynamic>>> getDoctorAppointments(int doctorId) async {
    final db = await database;
    return await db.query(
      'appointments',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'appointment_date, appointment_time',
    );
  }

  Future<int> updateAppointmentStatus(int appointmentId, String status) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  // ========== MESSAGE OPERATIONS ==========

  Future<int> sendMessage(Map<String, dynamic> messageData) async {
    final db = await database;
    try {
      return await db.insert('messages', messageData);
    } catch (e) {
      print('Error sending message: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getConversation(
    int user1Id,
    int user2Id,
  ) async {
    final db = await database;
    try {
      return await db.query(
        'messages',
        where:
            '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
        whereArgs: [user1Id, user2Id, user2Id, user1Id],
        orderBy: 'sent_at',
      );
    } catch (e) {
      print('Error getting conversation: $e');
      return [];
    }
  }

  // Add these to your DatabaseHelper class

  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }

  Future<List<Message>> getMessagesBetweenUsers(
    String user1Id,
    String user2Id,
  ) async {
    final db = await database;
    try {
      final result = await db.query(
        'messages',
        where:
            '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
        whereArgs: [user1Id, user2Id, user2Id, user1Id],
        orderBy: 'timestamp ASC',
      );
      return Message.fromList(result);
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  Future<List<Object>> getConversationsForUser(int userId) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        '''
      SELECT m.* FROM messages m
      INNER JOIN (
        SELECT MAX(id) as last_message_id
        FROM messages
        WHERE sender_id = ? OR receiver_id = ?
        GROUP BY 
          CASE 
            WHEN sender_id = ? THEN receiver_id 
            ELSE sender_id 
          END
      ) lm ON m.id = lm.last_message_id
      ORDER BY m.sent_at DESC
    ''',
        [userId, userId, userId],
      );

      return result.map((map) => Message.fromMap(map)).toList();
    } catch (e) {
      print('Error getting conversations for user: $e');
      return [];
    }
  }

  Future<int> markMessagesAsRead(int senderId, int receiverId) async {
    final db = await database;
    try {
      return await db.update(
        'messages',
        {'is_read': 1},
        where: 'sender_id = ? AND receiver_id = ? AND is_read = 0',
        whereArgs: [senderId, receiverId],
      );
    } catch (e) {
      print('Error marking messages as read: $e');
      return 0;
    }
  }

  Future<void> saveFcmToken(String userId, String token) async {
    final db = await database;
    await db.insert('user_tokens', {
      'user_id': userId,
      'token': token,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getFcmToken(String userId) async {
    final db = await database;
    final result = await db.query(
      'user_tokens',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isEmpty ? null : result.first['token'] as String?;
  }

  // ========== HEALTH INFO OPERATIONS ========== //
  Future<int> updateHealthInfo(
    int userId,
    Map<String, dynamic> healthData,
  ) async {
    final db = await database;
    final existing = await db.query(
      'health_info',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'health_info',
        healthData,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } else {
      healthData['user_id'] = userId;
      return await db.insert('health_info', healthData);
    }
  }

  Future<Map<String, dynamic>?> getHealthInfo(int userId) async {
    final db = await database;
    final result = await db.query(
      'health_info',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // ========== SCHEDULE OPERATIONS ========== //
  Future<int> addDoctorSchedule(
    int doctorId,
    Map<String, dynamic> scheduleData,
  ) async {
    final db = await database;
    return await db.insert('schedules', {
      ...scheduleData,
      'doctor_id': doctorId,
    });
  }

  Future<List<Map<String, dynamic>>> getDoctorSchedules(int doctorId) async {
    final db = await database;
    return await db.query(
      'schedules',
      where: 'doctor_id = ?',
      whereArgs: [doctorId],
      orderBy: 'day_of_week, start_time',
    );
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    // Implement logic to get current logged in user
    // This might come from your auth system or shared preferences
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.first;
  }

  //   Future<List<Map<String, dynamic>>> getUserAppointments(int userId) async {
  //   final db = await database;
  //   return await db.rawQuery('''
  //     SELECT a.*, d.name as doctor_name
  //     FROM appointments a
  //     JOIN users d ON a.doctor_id = d.id
  //     WHERE a.user_id = ?
  //     ORDER BY a.appointment_date, a.appointment_time
  //   ''', [userId]);
  // }

  Future<List<Map<String, dynamic>>> getDoctors() async {
    final db = await database;
    return await db.rawQuery(
      '''
      SELECT u.id, u.full_name, d.specialty, d.hospital, d.experience_years
FROM users u
JOIN doctor_profiles d ON u.id = d.user_id
WHERE u.role = ?

    ''',
      [ROLE_DOCTOR],
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return await db.insert(
      table,
      values,
      nullColumnHack: nullColumnHack,
      conflictAlgorithm: conflictAlgorithm,
    );
  }
}
