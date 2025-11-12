import 'package:flutter_test/flutter_test.dart';
import 'package:yaba_app/models/month_data.dart';
import 'package:yaba_app/models/transaction_model.dart';

void main() {
  group('Transaction Model Tests', () {
    test('Create transaction with all fields', () {
      final transaction = Transaction(
        title: 'Groceries',
        amount: 50.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime(2024, 11, 12),
        isRecurring: true,
        notes: 'Weekly shopping',
      );

      expect(transaction.title, 'Groceries');
      expect(transaction.amount, 50.0);
      expect(transaction.type, TransactionType.expense);
      expect(transaction.category, 'groceries');
      expect(transaction.isRecurring, true);
      expect(transaction.notes, 'Weekly shopping');
    });

    test('Transaction serialization', () {
      final transaction = Transaction(
        title: 'Salary',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salary',
        date: DateTime(2024, 11, 1),
      );

      final json = transaction.toJson();
      final restored = Transaction.fromJson(json);

      expect(restored.title, transaction.title);
      expect(restored.amount, transaction.amount);
      expect(restored.type, transaction.type);
      expect(restored.category, transaction.category);
    });

    test('Transaction copyWith', () {
      final original = Transaction(
        title: 'Gas',
        amount: 30.0,
        type: TransactionType.expense,
        category: 'transportation',
        date: DateTime(2024, 11, 12),
      );

      final updated = original.copyWith(amount: 35.0, isRecurring: true);

      expect(updated.title, original.title);
      expect(updated.amount, 35.0);
      expect(updated.isRecurring, true);
    });
  });

  group('MonthData Model Tests', () {
    test('Calculate total income', () {
      final monthData = MonthData(
        year: 2024,
        month: 11,
        transactions: [
          Transaction(
            title: 'Salary',
            amount: 5000.0,
            type: TransactionType.income,
            category: 'salary',
            date: DateTime(2024, 11, 1),
          ),
          Transaction(
            title: 'Freelance',
            amount: 500.0,
            type: TransactionType.income,
            category: 'freelance',
            date: DateTime(2024, 11, 15),
          ),
        ],
      );

      expect(monthData.totalIncome, 5500.0);
    });

    test('Calculate total expenses', () {
      final monthData = MonthData(
        year: 2024,
        month: 11,
        transactions: [
          Transaction(
            title: 'Groceries',
            amount: 200.0,
            type: TransactionType.expense,
            category: 'groceries',
            date: DateTime(2024, 11, 5),
          ),
          Transaction(
            title: 'Gas',
            amount: 50.0,
            type: TransactionType.expense,
            category: 'transportation',
            date: DateTime(2024, 11, 10),
          ),
        ],
      );

      expect(monthData.totalExpenses, 250.0);
    });

    test('Calculate balance', () {
      final monthData = MonthData(
        year: 2024,
        month: 11,
        transactions: [
          Transaction(
            title: 'Salary',
            amount: 5000.0,
            type: TransactionType.income,
            category: 'salary',
            date: DateTime(2024, 11, 1),
          ),
          Transaction(
            title: 'Rent',
            amount: 1500.0,
            type: TransactionType.expense,
            category: 'utilities',
            date: DateTime(2024, 11, 1),
          ),
        ],
      );

      expect(monthData.balance, 3500.0);
    });

    test('Expenses by category', () {
      final monthData = MonthData(
        year: 2024,
        month: 11,
        transactions: [
          Transaction(
            title: 'Groceries 1',
            amount: 100.0,
            type: TransactionType.expense,
            category: 'groceries',
            date: DateTime(2024, 11, 5),
          ),
          Transaction(
            title: 'Groceries 2',
            amount: 50.0,
            type: TransactionType.expense,
            category: 'groceries',
            date: DateTime(2024, 11, 10),
          ),
          Transaction(
            title: 'Gas',
            amount: 40.0,
            type: TransactionType.expense,
            category: 'transportation',
            date: DateTime(2024, 11, 8),
          ),
        ],
      );

      final breakdown = monthData.expensesByCategory;
      expect(breakdown['groceries'], 150.0);
      expect(breakdown['transportation'], 40.0);
    });

    test('MonthData serialization', () {
      final original = MonthData(
        year: 2024,
        month: 11,
        transactions: [
          Transaction(
            title: 'Test',
            amount: 100.0,
            type: TransactionType.expense,
            category: 'other',
            date: DateTime(2024, 11, 12),
          ),
        ],
        isFrozen: true,
      );

      final json = original.toJson();
      final restored = MonthData.fromJson(json);

      expect(restored.year, original.year);
      expect(restored.month, original.month);
      expect(restored.isFrozen, original.isFrozen);
      expect(restored.transactions.length, original.transactions.length);
    });

    test('Month key generation', () {
      final monthData = MonthData(year: 2024, month: 3, transactions: []);

      expect(monthData.monthKey, '2024-03');
    });
  });
}
