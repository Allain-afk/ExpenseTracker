import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/expense_group.dart';

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
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 2, // Increment version for new schema
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Create expense groups table
    await db.execute('''
      CREATE TABLE expense_groups (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create transactions table with groupId support
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        imagePath TEXT,
        groupId INTEGER,
        FOREIGN KEY (groupId) REFERENCES expense_groups (id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        // Add groupId column to existing transactions table
        // Check if column already exists to avoid error
        final columns = await db.rawQuery('PRAGMA table_info(transactions)');
        final hasGroupId = columns.any((column) => column['name'] == 'groupId');
        
        if (!hasGroupId) {
          await db.execute('ALTER TABLE transactions ADD COLUMN groupId INTEGER');
        }
      }
    } catch (e) {
      debugPrint('Error upgrading database: $e');
      rethrow;
    }
  }

  // Expense Groups CRUD operations
  Future<int> insertExpenseGroup(ExpenseGroup group) async {
    final db = await database;
    return await db.insert('expense_groups', group.toMap());
  }

  Future<List<ExpenseGroup>> getAllExpenseGroups() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('expense_groups', orderBy: 'createdAt DESC');
      return List.generate(maps.length, (i) => ExpenseGroup.fromMap(maps[i]));
    } catch (e) {
      debugPrint('Error getting expense groups: $e');
      rethrow;
    }
  }

  Future<ExpenseGroup?> getExpenseGroupById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expense_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return ExpenseGroup.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExpenseGroup(ExpenseGroup group) async {
    final db = await database;
    return await db.update(
      'expense_groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteExpenseGroup(int id) async {
    final db = await database;
    // First, remove groupId from all transactions in this group
    await db.update(
      'transactions',
      {'groupId': null},
      where: 'groupId = ?',
      whereArgs: [id],
    );
    // Then delete the group
    return await db.delete(
      'expense_groups',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get transactions for a specific group
  Future<List<ExpenseTransaction>> getTransactionsByGroup(int groupId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'groupId = ?',
      whereArgs: [groupId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => ExpenseTransaction.fromMap(maps[i]));
  }

  // Get total amount for a specific group
  Future<double> getGroupTotal(int groupId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE groupId = ?',
      [groupId],
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  // Get groups with their totals
  Future<List<Map<String, dynamic>>> getGroupsWithTotals() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        eg.id,
        eg.name,
        eg.description,
        eg.createdAt,
        eg.updatedAt,
        COALESCE(SUM(t.amount), 0) as total
      FROM expense_groups eg
      LEFT JOIN transactions t ON eg.id = t.groupId
      GROUP BY eg.id
      ORDER BY eg.createdAt DESC
    ''');
    return result;
  }

  // Existing transaction methods (updated to support groupId)
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
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<Map<String, double>> getCategoryTotals(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions WHERE type = ? GROUP BY category',
      [type],
    );
    
    Map<String, double> categoryTotals = {};
    for (var row in result) {
      categoryTotals[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return categoryTotals;
  }
} 