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
    // Map common icon code points to const icons
    final iconCode = json['icon'] as int;
    IconData iconData;
    
    switch (iconCode) {
      case 0xe59c: // shopping_cart
        iconData = Icons.shopping_cart;
        break;
      case 0xe531: // directions_car
        iconData = Icons.directions_car;
        break;
      case 0xe0ca: // bolt
        iconData = Icons.bolt;
        break;
      case 0xe405: // movie
        iconData = Icons.movie;
        break;
      case 0xe56c: // restaurant
        iconData = Icons.restaurant;
        break;
      case 0xe3f3: // medical_services
        iconData = Icons.medical_services;
        break;
      case 0xe5d3: // payments
        iconData = Icons.payments;
        break;
      case 0xe8f9: // work
        iconData = Icons.work;
        break;
      case 0xe8e5: // trending_up
        iconData = Icons.trending_up;
        break;
      case 0xe5d4: // more_horiz
        iconData = Icons.more_horiz;
        break;
      default:
        iconData = Icons.category; // Default fallback
    }
    
    return Category(
      id: json['id'],
      name: json['name'],
      icon: iconData,
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
