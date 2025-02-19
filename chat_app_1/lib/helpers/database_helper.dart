import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:chat_app_1/models/local_message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'messages.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE messages (
        message_id TEXT PRIMARY KEY,
        sender_user_id TEXT,
        receiver_user_id TEXT,
        room_id TEXT,
        content TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> insertMessage(LocalMessage message) async {
    final db = await database;
    await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
  }

  Future<List<LocalMessage>> getMessages(String roomId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
    return List.generate(maps.length, (i) {
      return LocalMessage.fromMap(maps[i]);
    });
  }

  Future<void> deleteMessages(String roomId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'room_id = ?',
      whereArgs: [roomId],
    );
  }


  Future<bool> messageExists(String messageId) async {
  final db = await database;
  final result = await db.rawQuery(
      'SELECT 1 FROM messages WHERE message_id = ? LIMIT 1', [messageId]); // Daha hızlı
  return result.isNotEmpty;
}

}
