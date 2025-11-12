import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/month_data.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final MonthData monthData;

  const CategoryBreakdownChart({super.key, required this.monthData});

  @override
  Widget build(BuildContext context) {
    final expensesByCategory = monthData.expensesByCategory;

    if (expensesByCategory.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No expenses to display'),
        ),
      );
    }

    final sortedCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalExpenses = monthData.totalExpenses;

    return Column(
      children: sortedCategories.map((entry) {
        final categoryId = entry.key;
        final amount = entry.value;
        final percentage = totalExpenses > 0
            ? (amount / totalExpenses) * 100
            : 0;
        final category = _findCategory(categoryId);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(category.icon, color: category.color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                color: category.color,
                minHeight: 8,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Category _findCategory(String categoryId) {
    return DefaultCategories.expense.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => DefaultCategories.expense.last,
    );
  }
}
