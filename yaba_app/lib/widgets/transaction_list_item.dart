import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleRecurring;
  final bool isFrozen;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleRecurring,
    this.isFrozen = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = _findCategory(transaction.category, transaction.type);
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withOpacity(0.2),
          child: Icon(category.icon, color: category.color),
        ),
        title: Row(
          children: [
            Expanded(child: Text(transaction.title)),
            if (transaction.isRecurring)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.repeat, size: 16, color: Colors.blue),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category.name),
            Text(
              DateFormat('MMM dd, yyyy').format(transaction.date),
              style: const TextStyle(fontSize: 12),
            ),
            if (transaction.notes != null && transaction.notes!.isNotEmpty)
              Text(
                transaction.notes!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        onTap: isFrozen ? null : onEdit,
        onLongPress: isFrozen ? null : () => _showOptions(context),
      ),
    );
  }

  Category _findCategory(String categoryId, TransactionType type) {
    final categories = type == TransactionType.expense
        ? DefaultCategories.expense
        : DefaultCategories.income;

    return categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => categories.last, // Return 'Other' as default
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: Icon(
              transaction.isRecurring ? Icons.repeat_on : Icons.repeat,
            ),
            title: Text(
              transaction.isRecurring
                  ? 'Remove Recurring'
                  : 'Mark as Recurring',
            ),
            onTap: () {
              Navigator.pop(context);
              onToggleRecurring();
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
