import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
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
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insertTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => ExpenseTransaction.fromMap(maps[i]));
  }

  Future<List<ExpenseTransaction>> getTransactionsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => ExpenseTransaction.fromMap(maps[i]));
  }

  Future<List<ExpenseTransaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => ExpenseTransaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(ExpenseTransaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalByType(String type) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [type],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<Map<String, double>> getCategoryTotals(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE type = ? GROUP BY category',
      [type],
    );
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category'] as String] = row['total'] as double;
    }
    return categoryTotals;
  }
} 