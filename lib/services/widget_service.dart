import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../providers/settings_provider.dart';

class WidgetService {
  static const String _widgetName = 'ExpenseTrackerWidget';
  static const String _androidWidgetName = 'ExpenseTrackerWidgetProvider';

  static Future<void> initializeWidget() async {
    await HomeWidget.setAppGroupId('group.expense_tracker');
  }

  static Future<void> updateWidget({
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required String currencySymbol,
    required List<Map<String, dynamic>> recentTransactions,
  }) async {
    try {
      // Update widget data
      await HomeWidget.saveWidgetData<String>('currency_symbol', currencySymbol);
      await HomeWidget.saveWidgetData<String>('total_income', NumberFormat.currency(symbol: currencySymbol).format(totalIncome));
      await HomeWidget.saveWidgetData<String>('total_expense', NumberFormat.currency(symbol: currencySymbol).format(totalExpense));
      await HomeWidget.saveWidgetData<String>('balance', NumberFormat.currency(symbol: currencySymbol).format(balance));
      
      // Save recent transactions (limit to 3 for widget display)
      final limitedTransactions = recentTransactions.take(3).toList();
      for (int i = 0; i < 3; i++) {
        if (i < limitedTransactions.length) {
          final transaction = limitedTransactions[i];
          await HomeWidget.saveWidgetData<String>('transaction_${i}_description', transaction['description'] ?? '');
          await HomeWidget.saveWidgetData<String>('transaction_${i}_amount', 
            NumberFormat.currency(symbol: currencySymbol).format(transaction['amount'] ?? 0.0));
          await HomeWidget.saveWidgetData<String>('transaction_${i}_type', transaction['type'] ?? '');
        } else {
          // Clear unused transaction slots
          await HomeWidget.saveWidgetData<String>('transaction_${i}_description', '');
          await HomeWidget.saveWidgetData<String>('transaction_${i}_amount', '');
          await HomeWidget.saveWidgetData<String>('transaction_${i}_type', '');
        }
      }

      // Update the widget
      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  static Future<void> updateWidgetFromDatabase() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      
      // Get totals
      final totalIncome = await dbHelper.getTotalByType('income');
      final totalExpense = await dbHelper.getTotalByType('expense');
      final balance = totalIncome - totalExpense;
      
      // Get recent transactions
      final transactions = await dbHelper.getAllTransactions();
      final recentTransactions = transactions.take(3).map((t) => {
        'description': t.description,
        'amount': t.amount,
        'type': t.type,
      }).toList();

      // Default currency symbol (you might want to get this from settings)
      const currencySymbol = '₱';

      await updateWidget(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: balance,
        currencySymbol: currencySymbol,
        recentTransactions: recentTransactions,
      );
    } catch (e) {
      print('Error updating widget from database: $e');
    }
  }

  static Future<void> registerBackgroundCallback() async {
    await HomeWidget.registerBackgroundCallback(backgroundCallback);
  }
}

@pragma("vm:entry-point")
void backgroundCallback(Uri? uri) async {
  if (uri?.host == 'updatewidget') {
    await WidgetService.updateWidgetFromDatabase();
  }
} 