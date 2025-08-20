import 'package:intl/intl.dart';

class ExpenseTransaction {
  final int? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String? imagePath; // Optional receipt image path
  final int? groupId; // Optional reference to expense group

  ExpenseTransaction({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.type,
    this.imagePath,
    this.groupId,
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
      'groupId': groupId,
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
      groupId: map['groupId'],
    );
  }

  ExpenseTransaction copyWith({
    int? id,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
    String? type,
    String? imagePath,
    int? groupId,
  }) {
    return ExpenseTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      description: description ?? this.description,
      date: date ?? this.date,
      type: type ?? this.type,
      imagePath: imagePath ?? this.imagePath,
      groupId: groupId ?? this.groupId,
    );
  }
} 