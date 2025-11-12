import 'package:flutter/foundation.dart';

import '../models/month_data.dart';
import '../models/transaction_model.dart';
import '../services/storage_service.dart';

class BudgetProvider extends ChangeNotifier {
  final StorageService _storage;

  MonthData? _currentMonth;
  List<MonthData> _allMonths = [];

  BudgetProvider(this._storage) {
    _initializeCurrentMonth();
  }

  MonthData? get currentMonth => _currentMonth;
  List<MonthData> get allMonths => _allMonths;

  void _initializeCurrentMonth() {
    final now = DateTime.now();
    _loadMonth(now.year, now.month);
    _loadAllMonths();
    _freezePreviousMonths();
    _copyRecurringTransactions();
  }

  void _loadMonth(int year, int month) {
    _currentMonth =
        _storage.getMonth(year, month) ??
        MonthData(year: year, month: month, transactions: []);
    notifyListeners();
  }

  void _loadAllMonths() {
    _allMonths = _storage.getAllMonths();
    notifyListeners();
  }

  Future<void> _freezePreviousMonths() async {
    final now = DateTime.now();
    final currentMonthDate = DateTime(now.year, now.month);

    for (var monthData in _allMonths) {
      final monthDate = DateTime(monthData.year, monthData.month);
      if (monthDate.isBefore(currentMonthDate) && !monthData.isFrozen) {
        await _storage.freezeMonth(monthData.year, monthData.month);
      }
    }
    _loadAllMonths();
  }

  Future<void> _copyRecurringTransactions() async {
    if (_currentMonth == null || _currentMonth!.transactions.isNotEmpty) {
      return; // Don't copy if current month already has transactions
    }

    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final previousMonthData = _storage.getMonth(
      lastMonth.year,
      lastMonth.month,
    );

    if (previousMonthData != null) {
      final recurringTransactions = previousMonthData.transactions
          .where((t) => t.isRecurring)
          .map(
            (t) => t.copyWith(date: DateTime(now.year, now.month, t.date.day)),
          )
          .toList();

      if (recurringTransactions.isNotEmpty) {
        final updatedMonth = _currentMonth!.copyWith(
          transactions: [
            ..._currentMonth!.transactions,
            ...recurringTransactions,
          ],
        );
        await _storage.saveMonth(updatedMonth);
        _currentMonth = updatedMonth;
        notifyListeners();
      }
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    if (_currentMonth == null) return;

    await _storage.addTransaction(
      _currentMonth!.year,
      _currentMonth!.month,
      transaction,
    );
    _loadMonth(_currentMonth!.year, _currentMonth!.month);
    _loadAllMonths();
  }

  Future<void> updateTransaction(
    String transactionId,
    Transaction updatedTransaction,
  ) async {
    if (_currentMonth == null) return;

    await _storage.updateTransaction(
      _currentMonth!.year,
      _currentMonth!.month,
      transactionId,
      updatedTransaction,
    );
    _loadMonth(_currentMonth!.year, _currentMonth!.month);
    _loadAllMonths();
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (_currentMonth == null) return;

    await _storage.deleteTransaction(
      _currentMonth!.year,
      _currentMonth!.month,
      transactionId,
    );
    _loadMonth(_currentMonth!.year, _currentMonth!.month);
    _loadAllMonths();
  }

  Future<void> toggleRecurring(String transactionId) async {
    if (_currentMonth == null) return;

    final transaction = _currentMonth!.transactions.firstWhere(
      (t) => t.id == transactionId,
    );

    await updateTransaction(
      transactionId,
      transaction.copyWith(isRecurring: !transaction.isRecurring),
    );
  }

  Future<void> updateStartingBalance(double newBalance) async {
    if (_currentMonth == null) return;

    final updatedMonth = _currentMonth!.copyWith(startingBalance: newBalance);
    await _storage.saveMonth(updatedMonth);
    _currentMonth = updatedMonth;
    notifyListeners();
    _loadAllMonths();
  }

  void switchMonth(int year, int month) {
    _loadMonth(year, month);
  }

  MonthData? getMonth(int year, int month) {
    return _storage.getMonth(year, month);
  }
}
