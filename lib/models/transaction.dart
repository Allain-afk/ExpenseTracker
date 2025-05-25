import 'package:intl/intl.dart';

class ExpenseTransaction {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String? imagePath; // Optional receipt image path

  ExpenseTransaction({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'description': description,
      'date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      'type': type,
      'imagePath': imagePath,
    };
  }

  factory ExpenseTransaction.fromMap(Map<String, dynamic> map) {
    return ExpenseTransaction(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      description: map['description'],
      date: DateFormat('yyyy-MM-dd HH:mm:ss').parse(map['date']),
      type: map['type'],
      imagePath: map['imagePath'],
    );
  }
} 