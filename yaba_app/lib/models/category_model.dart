import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
    );
  }
}

// Default categories
class DefaultCategories {
  static final List<Category> expense = [
    const Category(
      id: 'groceries',
      name: 'Groceries',
      icon: Icons.shopping_cart,
      color: Colors.green,
    ),
    const Category(
      id: 'transportation',
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    const Category(
      id: 'utilities',
      name: 'Utilities',
      icon: Icons.bolt,
      color: Colors.orange,
    ),
    const Category(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.purple,
    ),
    const Category(
      id: 'dining',
      name: 'Dining Out',
      icon: Icons.restaurant,
      color: Colors.red,
    ),
    const Category(
      id: 'healthcare',
      name: 'Healthcare',
      icon: Icons.medical_services,
      color: Colors.teal,
    ),
    const Category(
      id: 'other',
      name: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];

  static final List<Category> income = [
    const Category(
      id: 'salary',
      name: 'Salary',
      icon: Icons.payments,
      color: Colors.green,
    ),
    const Category(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.work,
      color: Colors.blue,
    ),
    const Category(
      id: 'investment',
      name: 'Investment',
      icon: Icons.trending_up,
      color: Colors.purple,
    ),
    const Category(
      id: 'other_income',
      name: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];
}
