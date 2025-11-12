import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../providers/budget_provider.dart';
import '../providers/settings_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _selectedCategory = DefaultCategories.expense.first.id;
  DateTime? _selectedDate;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _notesController.text = widget.transaction!.notes ?? '';
      _type = widget.transaction!.type;
      _selectedCategory = widget.transaction!.category;
      _selectedDate = widget.transaction!.date;
      _isRecurring = widget.transaction!.isRecurring;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final currentMonth = provider.currentMonth;

    // Initialize _selectedDate if not set
    if (_selectedDate == null && currentMonth != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
      final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

      // Use today if it's in the current month, otherwise use the 1st
      if (today.isAfter(firstDay.subtract(const Duration(days: 1))) &&
          today.isBefore(lastDay.add(const Duration(days: 1)))) {
        _selectedDate = today;
      } else {
        _selectedDate = firstDay;
      }
    }

    final categories = _type == TransactionType.expense
        ? DefaultCategories.expense
        : DefaultCategories.income;

    // Ensure selected category is valid for current type
    if (!categories.any((c) => c.id == _selectedCategory)) {
      _selectedCategory = categories.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction == null ? 'Add Transaction' : 'Edit Transaction',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text('Expense'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text('Income'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<TransactionType> newSelection) {
                        setState(() {
                          _type = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Icon(category.icon, color: category.color, size: 20),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              title: const Text('Date'),
              subtitle: Consumer<SettingsProvider>(
                builder: (context, settings, child) {
                  return Text(
                    _selectedDate != null
                        ? settings.formatDate(_selectedDate!)
                        : 'Select date',
                  );
                },
              ),
              leading: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: () async {
                final provider = Provider.of<BudgetProvider>(
                  context,
                  listen: false,
                );
                final currentMonth = provider.currentMonth;

                if (currentMonth == null) return;

                // Calculate first and last day of the current month
                final firstDay = DateTime(
                  currentMonth.year,
                  currentMonth.month,
                  1,
                );
                final lastDay = DateTime(
                  currentMonth.year,
                  currentMonth.month + 1,
                  0,
                );
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                // Determine initial date:
                // - If _selectedDate is within the month range, use it
                // - Otherwise, use today if it's in the current month, or the 1st of the month
                DateTime initialDate;
                if (_selectedDate != null &&
                    _selectedDate!.isAfter(
                      firstDay.subtract(const Duration(days: 1)),
                    ) &&
                    _selectedDate!.isBefore(
                      lastDay.add(const Duration(days: 1)),
                    )) {
                  initialDate = _selectedDate!;
                } else if (today.isAfter(
                      firstDay.subtract(const Duration(days: 1)),
                    ) &&
                    today.isBefore(lastDay.add(const Duration(days: 1)))) {
                  initialDate = today;
                } else {
                  initialDate = firstDay;
                }

                final date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDay,
                  lastDate: lastDay,
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Options
            Card(
              child: SwitchListTile(
                title: const Text('Recurring'),
                subtitle: const Text('Appears in future months'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                widget.transaction == null
                    ? 'Add Transaction'
                    : 'Update Transaction',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a date')));
      return;
    }

    final transaction = Transaction(
      id: widget.transaction?.id,
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      type: _type,
      category: _selectedCategory,
      date: _selectedDate!,
      isRecurring: _isRecurring,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final provider = Provider.of<BudgetProvider>(context, listen: false);

    if (widget.transaction == null) {
      await provider.addTransaction(transaction);
    } else {
      await provider.updateTransaction(widget.transaction!.id, transaction);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
