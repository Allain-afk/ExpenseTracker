import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../database/database_helper.dart';
import '../services/widget_service.dart';
import '../services/notification_service.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ExpenseTransaction> _transactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  Map<String, double> _categoryTotals = {};
  bool _hasShownLowBalanceNotification = false;

  List<ExpenseTransaction> get transactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  Map<String, double> get categoryTotals => _categoryTotals;
  double get balance => _totalIncome - _totalExpense;

  Future<void> loadTransactions() async {
    _transactions = await _dbHelper.getAllTransactions();
    _totalIncome = await _dbHelper.getTotalByType('income');
    _totalExpense = await _dbHelper.getTotalByType('expense');
    _categoryTotals = await _dbHelper.getCategoryTotals('expense');
    notifyListeners();
    
    // Update widget
    await _updateWidget();
  }

  Future<void> addTransaction(ExpenseTransaction transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await loadTransactions();
    
    // If transaction has a group, refresh group data
    if (transaction.groupId != null) {
      await _refreshGroupData(transaction.groupId!);
    }
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    // Get the old transaction to check if group changed
    final oldTransaction = _transactions.firstWhere((t) => t.id == transaction.id);
    final oldGroupId = oldTransaction.groupId;
    
    await _dbHelper.updateTransaction(transaction);
    await loadTransactions();
    
    // Refresh group data if group changed or if transaction has a group
    if (oldGroupId != transaction.groupId) {
      if (oldGroupId != null) {
        await _refreshGroupData(oldGroupId);
      }
      if (transaction.groupId != null) {
        await _refreshGroupData(transaction.groupId!);
      }
    } else if (transaction.groupId != null) {
      await _refreshGroupData(transaction.groupId!);
    }
  }

  Future<void> deleteTransaction(int id) async {
    // Get the transaction to check its group before deleting
    final transaction = _transactions.firstWhere((t) => t.id == id);
    final groupId = transaction.groupId;
    
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
    
    // Refresh group data if transaction had a group
    if (groupId != null) {
      await _refreshGroupData(groupId);
    }
  }

  Future<void> checkLowBalanceNotification({
    required String userName,
    required bool notificationsEnabled,
    required double threshold,
    required String message,
    required String currencySymbol,
  }) async {
    if (!notificationsEnabled || userName.isEmpty) return;
    
    final currentBalance = balance;
    
    // Show notification if balance is below threshold and we haven't shown it yet
    if (currentBalance <= threshold && !_hasShownLowBalanceNotification) {
      try {
        await NotificationService().showLowBalanceNotification(
          userName: userName,
          customMessage: message,
          currentBalance: currentBalance,
          currencySymbol: currencySymbol,
        );
        _hasShownLowBalanceNotification = true;
      } catch (e) {
        debugPrint('Error showing low balance notification: $e');
      }
    } else if (currentBalance > threshold) {
      // Reset notification flag when balance goes above threshold
      _hasShownLowBalanceNotification = false;
    }
  }

  Future<List<ExpenseTransaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    return await _dbHelper.getTransactionsByDateRange(start, end);
  }

  Future<List<ExpenseTransaction>> getTransactionsByType(String type) async {
    return await _dbHelper.getTransactionsByType(type);
  }

  Future<void> _updateWidget() async {
    try {
      final recentTransactions = _transactions.take(3).map((t) => {
        'description': t.description,
        'amount': t.amount,
        'type': t.type,
      }).toList();

      await WidgetService.updateWidget(
        totalIncome: _totalIncome,
        totalExpense: _totalExpense,
        balance: balance,
        currencySymbol: '₱', // You might want to get this from settings
        recentTransactions: recentTransactions,
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  Future<void> _refreshGroupData(int groupId) async {
    try {
      // Import and refresh ExpenseGroupProvider
      // This is a workaround since we can't directly access other providers
      // The group screens will refresh when they rebuild
      debugPrint('Transaction modified for group $groupId - group data should refresh');
    } catch (e) {
      debugPrint('Error refreshing group data: $e');
    }
  }
} 