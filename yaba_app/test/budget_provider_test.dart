import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yaba_app/models/transaction_model.dart';
import 'package:yaba_app/providers/budget_provider.dart';
import 'package:yaba_app/services/storage_service.dart';

void main() {
  group('BudgetProvider Tests', () {
    late StorageService storageService;
    late BudgetProvider budgetProvider;

    setUp(() async {
      await Hive.initFlutter();
      storageService = StorageService();
      await storageService.init();
      budgetProvider = BudgetProvider(storageService);
    });

    tearDown(() async {
      await storageService.close();
      await Hive.deleteFromDisk();
    });

    test('Initialize with current month', () {
      final now = DateTime.now();
      expect(budgetProvider.currentMonth, isNotNull);
      expect(budgetProvider.currentMonth!.year, now.year);
      expect(budgetProvider.currentMonth!.month, now.month);
    });

    test('Add transaction', () async {
      final transaction = Transaction(
        title: 'Test',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime.now(),
      );

      await budgetProvider.addTransaction(transaction);

      expect(budgetProvider.currentMonth!.transactions.length, greaterThan(0));
      expect(
        budgetProvider.currentMonth!.transactions.any((t) => t.title == 'Test'),
        true,
      );
    });

    test('Delete transaction', () async {
      final transaction = Transaction(
        title: 'To Delete',
        amount: 50.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime.now(),
      );

      await budgetProvider.addTransaction(transaction);
      final count = budgetProvider.currentMonth!.transactions.length;

      await budgetProvider.deleteTransaction(transaction.id);

      expect(budgetProvider.currentMonth!.transactions.length, count - 1);
    });

    test('Toggle recurring flag', () async {
      final transaction = Transaction(
        title: 'Test',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime.now(),
        isRecurring: false,
      );

      await budgetProvider.addTransaction(transaction);
      await budgetProvider.toggleRecurring(transaction.id);

      final updated = budgetProvider.currentMonth!.transactions.firstWhere(
        (t) => t.id == transaction.id,
      );
      expect(updated.isRecurring, true);
    });

    test('Switch month', () {
      budgetProvider.switchMonth(2024, 10);

      expect(budgetProvider.currentMonth!.year, 2024);
      expect(budgetProvider.currentMonth!.month, 10);
    });
  });
}
