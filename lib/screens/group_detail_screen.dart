import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_group_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/expense_group.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final ExpenseGroup group;

  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadGroupData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadGroupData();
    }
  }

  Future<void> _loadGroupData() async {
    setState(() {
      _isLoading = true;
    });
    await Provider.of<ExpenseGroupProvider>(context, listen: false)
        .loadGroupTransactions(widget.group.id!);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGroupData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GroupDetailContent(group: widget.group),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                initialGroupId: widget.group.id,
              ),
            ),
          );
          if (result == true) {
            _loadGroupData();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GroupDetailContent extends StatefulWidget {
  final ExpenseGroup group;

  const GroupDetailContent({super.key, required this.group});

  @override
  State<GroupDetailContent> createState() => _GroupDetailContentState();
}

class _GroupDetailContentState extends State<GroupDetailContent> {
  @override
  Widget build(BuildContext context) {
    return Consumer3<ExpenseGroupProvider, TransactionProvider, SettingsProvider>(
      builder: (context, groupProvider, transactionProvider, settingsProvider, child) {
        final currencySymbol = settingsProvider.currencySymbol;
        final group = groupProvider.getGroupById(widget.group.id!);
        final transactions = groupProvider.getGroupTransactions(widget.group.id!);
        final total = groupProvider.getGroupTotal(widget.group.id!);
        final double groupIncome = transactions
            .where((t) => t.type == 'income')
            .fold(0.0, (sum, t) => sum + t.amount);
        final double groupExpense = transactions
            .where((t) => t.type == 'expense')
            .fold(0.0, (sum, t) => sum + t.amount);

        if (group == null) {
          return const Center(
            child: Text('Group not found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await groupProvider.loadGroupTransactions(widget.group.id!);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupInfoCard(group, total, currencySymbol),
                const SizedBox(height: 20),
                _buildGroupBalanceCard(groupIncome, groupExpense, currencySymbol),
                const SizedBox(height: 20),
                _buildTransactionsSection(transactions, currencySymbol, groupProvider),
                const SizedBox(height: 80), // Extra space for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupBalanceCard(double income, double expense, String currencySymbol) {
    final double balance = income - expense;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Group Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat.currency(symbol: currencySymbol).format(balance),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem('Income', income, Colors.green, currencySymbol),
                _buildBalanceItem('Expenses', expense, Colors.red, currencySymbol),
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

  Widget _buildGroupInfoCard(ExpenseGroup group, double total, String currencySymbol) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(
                    Icons.folder,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (group.description != null && group.description!.isNotEmpty)
                        Text(
                          group.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: currencySymbol).format(total),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Created',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(group.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsSection(List<ExpenseTransaction> transactions, String currencySymbol, ExpenseGroupProvider groupProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Transactions (${transactions.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (transactions.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // Show all transactions in a separate screen
                },
                icon: const Icon(Icons.list),
                label: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first transaction to this group',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.type == 'income' 
                        ? Colors.green 
                        : Colors.red,
                    child: Icon(
                      transaction.type == 'income' 
                          ? Icons.trending_up 
                          : Icons.trending_down,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(transaction.category),
                      Text(
                        DateFormat('MMM dd, yyyy').format(transaction.date),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(symbol: currencySymbol).format(transaction.amount),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction.type == 'income' 
                              ? Colors.green 
                              : Colors.red,
                        ),
                      ),
                      Text(
                        transaction.type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTransactionScreen(transaction: transaction),
                      ),
                    );
                    if (result == true) {
                      await groupProvider.loadGroupTransactions(widget.group.id!);
                    }
                  },
                ),
              );
            },
          ),
      ],
    );
  }
} 