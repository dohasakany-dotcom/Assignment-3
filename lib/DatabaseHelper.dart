import 'package:sqflite/sqflite.dart' as sql;

class DatabaseHelper {

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      "tasks.db",
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await database.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            isComplete INTEGER DEFAULT 0,
            userId TEXT,
            createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  // INSERT
  static Future<int> insertTask(String title, String description, String userId) async {
    final db = await DatabaseHelper.db();

    return await db.insert("tasks", {
      'title': title,
      'description': description,
      'isComplete': 0,
      'userId': userId,
    });
  }

  // GET ALL
  static Future<List<Map<String, dynamic>>> getTasks(String userId) async {
    final db = await DatabaseHelper.db();
    return db.query(
      "tasks",
      where: "userId = ?",
      whereArgs: [userId],
      orderBy: "id DESC",
    );
  }

  // GET ONE
  static Future<List<Map<String, dynamic>>> getTask(int id) async {
    final db = await DatabaseHelper.db();
    return db.query("tasks", where: "id = ?", whereArgs: [id]);
  }

  // UPDATE
  static Future<int> updateTask(int id, String title, String description) async {
    final db = await DatabaseHelper.db();

    return await db.update(
      "tasks",
      {
        'title': title,
        'description': description,
      },
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // TOGGLE
  static Future<int> toggleStatus(int id, int isComplete) async {
    final db = await DatabaseHelper.db();

    return await db.update(
      "tasks",
      {'isComplete': isComplete},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // DELETE
  static Future<int> deleteTask(int id) async {
    final db = await DatabaseHelper.db();

    return await db.delete(
      "tasks",
      where: "id = ?",
      whereArgs: [id],
    );
  }
}