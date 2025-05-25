import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'expense';
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Food',
    'Transportation',
    'Housing',
    'Utilities',
    'Entertainment',
    'Shopping',
    'Healthcare',
    'Education',
    'Other',
  ];

  final List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Gifts',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final transaction = ExpenseTransaction(
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate,
        type: _selectedType,
      );

      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      await transactionProvider.addTransaction(transaction);
      
      // Check for low balance notification after adding expense
      if (_selectedType == 'expense') {
        await transactionProvider.checkLowBalanceNotification(
          userName: settingsProvider.userName,
          notificationsEnabled: settingsProvider.notificationsEnabled,
          threshold: settingsProvider.lowBalanceThreshold,
          message: settingsProvider.notificationMessage,
          currencySymbol: settingsProvider.currencySymbol,
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'expense',
                        label: Text('Expense'),
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text('Income'),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                    selected: {_selectedType},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedType = newSelection.first;
                        _selectedCategory = _selectedType == 'expense'
                            ? _expenseCategories.first
                            : _incomeCategories.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '${settingsProvider.currencySymbol} ',
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: (_selectedType == 'expense'
                            ? _expenseCategories
                            : _incomeCategories)
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      DateFormat('MMM d, y').format(_selectedDate),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Add Transaction',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 