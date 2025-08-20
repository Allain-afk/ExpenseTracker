import 'package:intl/intl.dart';

class ExpenseGroup {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseGroup({
    this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
      'updatedAt': DateFormat('yyyy-MM-dd HH:mm:ss').format(updatedAt),
    };
  }

  factory ExpenseGroup.fromMap(Map<String, dynamic> map) {
    return ExpenseGroup(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateFormat('yyyy-MM-dd HH:mm:ss').parse(map['createdAt']),
      updatedAt: DateFormat('yyyy-MM-dd HH:mm:ss').parse(map['updatedAt']),
    );
  }

  ExpenseGroup copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 