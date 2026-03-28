import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/expense_group_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart';
import '../widgets/inset_grouped_list.dart';
import 'edit_transaction_screen.dart';
import '../utils/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Income', 'Expense'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Consumer3<
          TransactionProvider,
          ExpenseGroupProvider,
          SettingsProvider
        >(
          builder: (
            context,
            transactionProvider,
            groupProvider,
            settingsProvider,
            child,
          ) {
            final transactions = _getFilteredTransactions(
              transactionProvider.transactions,
            );

            Widget content;
            if (transactions.isEmpty) {
              content = SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFilter == 'All'
                            ? 'Start by adding your first transaction'
                            : 'No ${_selectedFilter.toLowerCase()} transactions found',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              Map<String, List<ExpenseTransaction>> grouped = {};
              for (var t in transactions) {
                String dateStr = DateFormat('EEEE, MMM d').format(t.date);
                if (!grouped.containsKey(dateStr)) {
                  grouped[dateStr] = [];
                }
                grouped[dateStr]!.add(t);
              }

              List<Widget> groupedLists = [];
              for (var entry in grouped.entries) {
                groupedLists.add(
                  InsetGroupedList(
                    headerText: entry.key,
                    children:
                        entry.value
                            .map(
                              (t) => _buildTransactionCard(
                                context,
                                t,
                                settingsProvider.currencySymbol,
                                transactionProvider,
                                groupProvider,
                              ),
                            )
                            .toList(),
                  ),
                );
              }

              content = SliverPadding(
                padding: const EdgeInsets.only(bottom: 104),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => groupedLists[index],
                    childCount: groupedLists.length,
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  primary: false,
                  title: const Text('Transactions'),
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  actions: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                      },
                      itemBuilder:
                          (context) =>
                              _filterOptions.map((filter) {
                                return PopupMenuItem(
                                  value: filter,
                                  child: Row(
                                    children: [
                                      if (_selectedFilter == filter)
                                        const Icon(
                                          Icons.check,
                                          size: 20,
                                          color: AppTheme.primary,
                                        ),
                                      if (_selectedFilter == filter)
                                        const SizedBox(width: 8),
                                      Text(filter),
                                    ],
                                  ),
                                );
                              }).toList(),
                      icon: const Icon(
                        Icons.line_weight_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                content,
              ],
            );
          },
        ),
      ),
    );
  }

  List<ExpenseTransaction> _getFilteredTransactions(
    List<ExpenseTransaction> transactions,
  ) {
    if (_selectedFilter == 'All') {
      return transactions;
    } else if (_selectedFilter == 'Income') {
      return transactions.where((t) => t.type == 'income').toList();
    } else {
      return transactions.where((t) => t.type == 'expense').toList();
    }
  }

  Widget _buildTransactionCard(
    BuildContext context,
    ExpenseTransaction transaction,
    String currencySymbol,
    TransactionProvider provider,
    ExpenseGroupProvider groupProvider,
  ) {
    final group =
        transaction.groupId != null
            ? groupProvider.getGroupById(transaction.groupId!)
            : null;

    final isIncome = transaction.type == 'income';
    final iconColor = isIncome ? Colors.green.shade600 : Colors.red.shade600;
    final bgColor =
        isIncome
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1);

    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isIncome ? Icons.add_rounded : Icons.remove_rounded,
            color: iconColor,
            size: 22,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              transaction.category,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            if (group != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_rounded,
                      size: 10,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              NumberFormat.currency(
                symbol: currencySymbol,
              ).format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isIncome ? Colors.green.shade600 : Colors.black87,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_horiz, color: Colors.grey.shade400),
              onSelected: (value) {
                if (value == 'edit') {
                  _editTransaction(context, transaction);
                } else if (value == 'delete') {
                  _deleteTransaction(context, transaction, provider);
                }
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red,
                          ),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }

  void _editTransaction(BuildContext context, ExpenseTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTransactionScreen(transaction: transaction),
      ),
    );
  }

  void _deleteTransaction(
    BuildContext context,
    ExpenseTransaction transaction,
    TransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text(
            'Are you sure you want to delete "${transaction.description}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.deleteTransaction(transaction.id!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
