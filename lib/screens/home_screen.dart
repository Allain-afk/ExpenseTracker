import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/expense_group_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart';
import 'group_detail_screen.dart';
import 'add_transaction_screen.dart';
import 'add_group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    await Provider.of<ExpenseGroupProvider>(context, listen: false).loadExpenseGroups();
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

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<TransactionProvider, ExpenseGroupProvider, SettingsProvider>(
      builder: (context, provider, groupProvider, settingsProvider, child) {
        final currencySymbol = settingsProvider.currencySymbol;
        
        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadTransactions();
            await groupProvider.loadExpenseGroups();
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
                _buildGroupsSummary(groupProvider, currencySymbol),
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

  Widget _buildGroupsSummary(ExpenseGroupProvider groupProvider, String currencySymbol) {
    final groups = groupProvider.groups;
    
    if (groups.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Expense Groups',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No expense groups yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first expense group to organize your expenses',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddGroupScreen(),
                          ),
                        );
                        if (result == true) {
                          // Refresh groups
                          await groupProvider.loadExpenseGroups();
                        }
                      },
                      icon: const Icon(Icons.create_new_folder),
                      label: const Text('Create Your First Group'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final topGroups = groups.take(3).toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Expense Groups',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Show quick add menu
                        _showQuickAddMenu(context, groupProvider);
                      },
                      icon: const Icon(Icons.add),
                      tooltip: 'Quick Add Transaction',
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to groups screen
                        Navigator.pushNamed(context, '/groups');
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...topGroups.map((group) {
              final total = groupProvider.getGroupTotal(group.id!);
              final transactionCount = groupProvider.getGroupTransactions(group.id!).length;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.folder,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '$transactionCount transaction${transactionCount != 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        NumberFormat.currency(symbol: currencySymbol).format(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionScreen(
                                initialGroupId: group.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                        tooltip: 'Add Transaction to ${group.name}',
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to group detail
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailScreen(group: group),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showQuickAddMenu(BuildContext context, ExpenseGroupProvider groupProvider) {
    final groups = groupProvider.groups;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Add Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Add to General'),
                subtitle: const Text('Transaction without group'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add to Group',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddGroupScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.create_new_folder, size: 16),
                    label: const Text('Create New Group'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (groups.isNotEmpty) ...[
                ...groups.map((group) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Icon(
                      Icons.folder,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                  title: Text(group.name),
                  subtitle: Text(group.description ?? 'No description'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTransactionScreen(
                          initialGroupId: group.id,
                        ),
                      ),
                    );
                  },
                )),
              ] else ...[
                const ListTile(
                  leading: Icon(Icons.folder_open, color: Colors.grey),
                  title: Text('No groups yet'),
                  subtitle: Text('Create your first group to organize expenses'),
                ),
              ],
            ],
          ),
        );
      },
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