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
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await loadTransactions();
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
} 