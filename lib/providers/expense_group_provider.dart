import 'package:flutter/foundation.dart';
import '../models/expense_group.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';

class ExpenseGroupProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ExpenseGroup> _groups = [];
  Map<int, List<ExpenseTransaction>> _groupTransactions = {};
  Map<int, double> _groupTotals = {};

  List<ExpenseGroup> get groups => _groups;
  Map<int, List<ExpenseTransaction>> get groupTransactions => _groupTransactions;
  Map<int, double> get groupTotals => _groupTotals;

  Future<void> loadExpenseGroups() async {
    try {
      _groups = await _dbHelper.getAllExpenseGroups();
      await _loadGroupTotals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading expense groups: $e');
      rethrow;
    }
  }

  Future<void> _loadGroupTotals() async {
    final groupsWithTotals = await _dbHelper.getGroupsWithTotals();
    _groupTotals.clear();
    for (var groupData in groupsWithTotals) {
      final groupId = groupData['id'] as int;
      final total = (groupData['total'] as num).toDouble();
      _groupTotals[groupId] = total;
    }
  }

  Future<void> addExpenseGroup(ExpenseGroup group) async {
    final id = await _dbHelper.insertExpenseGroup(group);
    final newGroup = group.copyWith(id: id);
    _groups.insert(0, newGroup);
    _groupTotals[id] = 0.0;
    _groupTransactions[id] = [];
    notifyListeners();
  }

  Future<void> updateExpenseGroup(ExpenseGroup group) async {
    await _dbHelper.updateExpenseGroup(group);
    final index = _groups.indexWhere((g) => g.id == group.id);
    if (index != -1) {
      _groups[index] = group;
      notifyListeners();
    }
  }

  Future<void> deleteExpenseGroup(int groupId) async {
    await _dbHelper.deleteExpenseGroup(groupId);
    _groups.removeWhere((group) => group.id == groupId);
    _groupTotals.remove(groupId);
    _groupTransactions.remove(groupId);
    notifyListeners();
  }

  Future<void> loadGroupTransactions(int groupId) async {
    final transactions = await _dbHelper.getTransactionsByGroup(groupId);
    _groupTransactions[groupId] = transactions;
    notifyListeners();
  }

  Future<void> addTransactionToGroup(ExpenseTransaction transaction, int groupId) async {
    final transactionWithGroup = transaction.copyWith(groupId: groupId);
    await _dbHelper.insertTransaction(transactionWithGroup);
    await _loadGroupTotals();
    await loadGroupTransactions(groupId);
  }

  Future<void> removeTransactionFromGroup(ExpenseTransaction transaction) async {
    final transactionWithoutGroup = transaction.copyWith(groupId: null);
    await _dbHelper.updateTransaction(transactionWithoutGroup);
    await _loadGroupTotals();
    if (transaction.groupId != null) {
      await loadGroupTransactions(transaction.groupId!);
    }
  }

  Future<void> updateTransactionInGroup(ExpenseTransaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await _loadGroupTotals();
    if (transaction.groupId != null) {
      await loadGroupTransactions(transaction.groupId!);
    }
  }

  Future<void> deleteTransactionFromGroup(int transactionId, int? groupId) async {
    await _dbHelper.deleteTransaction(transactionId);
    await _loadGroupTotals();
    if (groupId != null) {
      await loadGroupTransactions(groupId);
    }
  }

  double getGroupTotal(int groupId) {
    return _groupTotals[groupId] ?? 0.0;
  }

  List<ExpenseTransaction> getGroupTransactions(int groupId) {
    return _groupTransactions[groupId] ?? [];
  }

  ExpenseGroup? getGroupById(int groupId) {
    try {
      return _groups.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }
} 