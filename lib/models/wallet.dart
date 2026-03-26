import 'package:flutter/material.dart';

class Wallet {
  final int? id;
  final String name;
  final String type;
  final int colorValue;

  Wallet({
    this.id,
    required this.name,
    required this.type,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'colorValue': colorValue,
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      colorValue: map['colorValue'],
    );
  }

  Wallet copyWith({
    int? id,
    String? name,
    String? type,
    int? colorValue,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
