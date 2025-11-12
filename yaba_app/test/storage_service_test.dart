import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:yaba_app/models/month_data.dart';
import 'package:yaba_app/models/transaction_model.dart';
import 'package:yaba_app/services/storage_service.dart';

void main() {
  group('StorageService Tests', () {
    late StorageService storageService;

    setUp(() async {
      // Initialize Hive with a temporary directory for testing
      await Hive.initFlutter();
      storageService = StorageService();
      await storageService.init();
    });

    tearDown(() async {
      // Clean up
      await storageService.close();
      await Hive.deleteFromDisk();
    });

    test('Save and retrieve month data', () async {
      final monthData = MonthData(
        year: 2024,
        month: 11,
        transactions: [
          Transaction(
            title: 'Test Transaction',
            amount: 100.0,
            type: TransactionType.expense,
            category: 'groceries',
            date: DateTime(2024, 11, 12),
          ),
        ],
      );

      await storageService.saveMonth(monthData);
      final retrieved = storageService.getMonth(2024, 11);

      expect(retrieved, isNotNull);
      expect(retrieved!.year, 2024);
      expect(retrieved.month, 11);
      expect(retrieved.transactions.length, 1);
    });

    test('Add transaction to month', () async {
      final transaction = Transaction(
        title: 'Groceries',
        amount: 50.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime(2024, 11, 12),
      );

      await storageService.addTransaction(2024, 11, transaction);
      final monthData = storageService.getMonth(2024, 11);

      expect(monthData, isNotNull);
      expect(monthData!.transactions.length, 1);
      expect(monthData.transactions.first.title, 'Groceries');
    });

    test('Update transaction', () async {
      final original = Transaction(
        title: 'Original',
        amount: 100.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime(2024, 11, 12),
      );

      await storageService.addTransaction(2024, 11, original);

      final updated = original.copyWith(title: 'Updated', amount: 150.0);
      await storageService.updateTransaction(2024, 11, original.id, updated);

      final monthData = storageService.getMonth(2024, 11);
      expect(monthData!.transactions.first.title, 'Updated');
      expect(monthData.transactions.first.amount, 150.0);
    });

    test('Delete transaction', () async {
      final transaction = Transaction(
        title: 'To Delete',
        amount: 50.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime(2024, 11, 12),
      );

      await storageService.addTransaction(2024, 11, transaction);
      var monthData = storageService.getMonth(2024, 11);
      expect(monthData!.transactions.length, 1);

      await storageService.deleteTransaction(2024, 11, transaction.id);
      monthData = storageService.getMonth(2024, 11);
      expect(monthData!.transactions.length, 0);
    });

    test('Freeze month', () async {
      final monthData = MonthData(year: 2024, month: 10, transactions: []);

      await storageService.saveMonth(monthData);
      await storageService.freezeMonth(2024, 10);

      final frozen = storageService.getMonth(2024, 10);
      expect(frozen!.isFrozen, true);
    });

    test('Get all months sorted', () async {
      await storageService.saveMonth(
        MonthData(year: 2024, month: 11, transactions: []),
      );
      await storageService.saveMonth(
        MonthData(year: 2024, month: 9, transactions: []),
      );
      await storageService.saveMonth(
        MonthData(year: 2024, month: 10, transactions: []),
      );

      final allMonths = storageService.getAllMonths();
      expect(allMonths.length, 3);
      expect(allMonths[0].month, 11); // Most recent first
      expect(allMonths[1].month, 10);
      expect(allMonths[2].month, 9);
    });
  });
}
