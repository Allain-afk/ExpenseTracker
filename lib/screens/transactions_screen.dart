import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart';
import 'edit_transaction_screen.dart';

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
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => _filterOptions.map((filter) {
              return PopupMenuItem(
                value: filter,
                child: Row(
                  children: [
                    if (_selectedFilter == filter)
                      const Icon(Icons.check, size: 20),
                    if (_selectedFilter == filter)
                      const SizedBox(width: 8),
                    Text(filter),
                  ],
                ),
              );
            }).toList(),
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Consumer2<TransactionProvider, SettingsProvider>(
        builder: (context, transactionProvider, settingsProvider, child) {
          final transactions = _getFilteredTransactions(transactionProvider.transactions);
          
          if (transactions.isEmpty) {
            return Center(
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
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedFilter == 'All' 
                        ? 'Start by adding your first transaction'
                        : 'No ${_selectedFilter.toLowerCase()} transactions found',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _buildTransactionCard(
                context,
                transaction,
                settingsProvider.currencySymbol,
                transactionProvider,
              );
            },
          );
        },
      ),
    );
  }

  List<ExpenseTransaction> _getFilteredTransactions(List<ExpenseTransaction> transactions) {
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
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == 'income' ? Colors.green : Colors.red,
          child: Icon(
            transaction.type == 'income' ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category),
            Text(
              DateFormat('MMM d, y • h:mm a').format(transaction.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: currencySymbol).format(transaction.amount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: transaction.type == 'income' ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editTransaction(context, transaction);
                } else if (value == 'delete') {
                  _deleteTransaction(context, transaction, provider);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
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
          content: Text('Are you sure you want to delete "${transaction.description}"?'),
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