import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';

class EditTransactionScreen extends StatefulWidget {
  final ExpenseTransaction transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

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
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController = TextEditingController(text: widget.transaction.description);
    _selectedType = widget.transaction.type;
    _selectedCategory = widget.transaction.category;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final updatedTransaction = ExpenseTransaction(
        id: widget.transaction.id,
        amount: double.parse(_amountController.text),
        category: _selectedCategory,
        description: _descriptionController.text,
        date: _selectedDate,
        type: _selectedType,
        imagePath: widget.transaction.imagePath,
      );

      Provider.of<TransactionProvider>(context, listen: false)
          .updateTransaction(updatedTransaction)
          .then((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated successfully')),
        );
      });
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
        title: const Text('Edit Transaction'),
        actions: [
          TextButton(
            onPressed: _submitForm,
            child: const Text('Save'),
          ),
        ],
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
                  Card(
                    child: ListTile(
                      title: const Text('Date'),
                      subtitle: Text(
                        DateFormat('MMM d, y').format(_selectedDate),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Update Transaction',
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