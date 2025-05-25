import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const HomeScreenContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, SettingsProvider>(
      builder: (context, provider, settingsProvider, child) {
        final currencySymbol = settingsProvider.currencySymbol;
        
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadTransactions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(provider, currencySymbol),
                const SizedBox(height: 20),
                _buildQuickStats(provider, currencySymbol),
                const SizedBox(height: 20),
                _buildExpenseChart(provider, currencySymbol),
                const SizedBox(height: 20),
                _buildRecentTransactions(provider, currencySymbol),
                const SizedBox(height: 80), // Extra space at bottom for navigation
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(TransactionProvider provider, String currencySymbol) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(symbol: currencySymbol).format(provider.balance),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem('Income', provider.totalIncome, Colors.green, currencySymbol),
                _buildBalanceItem('Expenses', provider.totalExpense, Colors.red, currencySymbol),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, double amount, Color color, String currencySymbol) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: currencySymbol).format(amount),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(TransactionProvider provider, String currencySymbol) {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.trending_up, color: Colors.green, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(symbol: currencySymbol).format(provider.totalIncome),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.trending_down, color: Colors.red, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(symbol: currencySymbol).format(provider.totalExpense),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseChart(TransactionProvider provider, String currencySymbol) {
    final categoryTotals = provider.categoryTotals;
    if (categoryTotals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No expense data available'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '  Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 220,
              width: double.infinity,
              child: PieChart(
                PieChartData(
                  sections: _createPieChartSections(categoryTotals),
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...categoryTotals.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildCategoryItem(
                entry.key,
                entry.value,
                provider.totalExpense,
                currencySymbol,
              ),
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(Map<String, double> categoryTotals) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
    ];

    final totalAmount = categoryTotals.values.reduce((a, b) => a + b);
    
    return categoryTotals.entries.map((entry) {
      final index = categoryTotals.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / totalAmount * 100);
      
      return PieChartSectionData(
        value: entry.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '', // Only show percentage if >= 5%
        color: colors[index % colors.length],
        radius: 85,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black54,
            ),
          ],
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  Widget _buildCategoryItem(String category, double amount, double total, String currencySymbol) {
    final percentage = (amount / total * 100).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${NumberFormat.currency(symbol: currencySymbol).format(amount)} ($percentage%)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider, String currencySymbol) {
    final transactions = provider.transactions.take(5).toList();
    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('No transactions yet'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...transactions.map((transaction) => _buildTransactionItem(transaction, currencySymbol)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(ExpenseTransaction transaction, String currencySymbol) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.type == 'income' ? Colors.green : Colors.red,
        child: Icon(
          transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
          color: Colors.white,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(transaction.category),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            NumberFormat.currency(symbol: currencySymbol).format(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.type == 'income' ? Colors.green : Colors.red,
            ),
          ),
          Text(
            DateFormat('MMM d, y').format(transaction.date),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
} 