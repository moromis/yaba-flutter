import 'package:hive_flutter/hive_flutter.dart';

import '../models/month_data.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const String _monthsBox = 'months';
  static const String _settingsBox = 'settings';

  static Box<Map>? _monthsBoxInstance;
  static Box? _settingsBoxInstance;

  Future<void> init() async {
    await Hive.initFlutter();
    _monthsBoxInstance = await Hive.openBox<Map>(_monthsBox);
    _settingsBoxInstance = await Hive.openBox(_settingsBox);
  }

  Box<Map> get monthsBox => _monthsBoxInstance!;
  Box get settingsBox => _settingsBoxInstance!;

  // Month operations
  Future<void> saveMonth(MonthData monthData) async {
    await monthsBox.put(monthData.monthKey, monthData.toJson());
  }

  MonthData? getMonth(int year, int month) {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    final data = monthsBox.get(key);
    if (data == null) return null;
    return MonthData.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> deleteMonth(int year, int month) async {
    final key = '$year-${month.toString().padLeft(2, '0')}';
    await monthsBox.delete(key);
  }

  List<MonthData> getAllMonths() {
    return monthsBox.values
        .map((data) => MonthData.fromJson(Map<String, dynamic>.from(data)))
        .toList()
      ..sort((a, b) {
        final dateA = DateTime(a.year, a.month);
        final dateB = DateTime(b.year, b.month);
        return dateB.compareTo(dateA); // Most recent first
      });
  }

  // Transaction operations
  Future<void> addTransaction(
    int year,
    int month,
    Transaction transaction,
  ) async {
    final monthData =
        getMonth(year, month) ??
        MonthData(year: year, month: month, transactions: []);

    final updatedTransactions = [...monthData.transactions, transaction];
    await saveMonth(monthData.copyWith(transactions: updatedTransactions));
  }

  Future<void> updateTransaction(
    int year,
    int month,
    String transactionId,
    Transaction updatedTransaction,
  ) async {
    final monthData = getMonth(year, month);
    if (monthData == null) return;

    final updatedTransactions = monthData.transactions.map((t) {
      return t.id == transactionId ? updatedTransaction : t;
    }).toList();

    await saveMonth(monthData.copyWith(transactions: updatedTransactions));
  }

  Future<void> deleteTransaction(
    int year,
    int month,
    String transactionId,
  ) async {
    final monthData = getMonth(year, month);
    if (monthData == null) return;

    final updatedTransactions = monthData.transactions
        .where((t) => t.id != transactionId)
        .toList();

    await saveMonth(monthData.copyWith(transactions: updatedTransactions));
  }

  Future<void> freezeMonth(int year, int month) async {
    final monthData = getMonth(year, month);
    if (monthData == null) return;

    await saveMonth(monthData.copyWith(isFrozen: true));
  }

  Future<void> close() async {
    await _monthsBoxInstance?.close();
    await _settingsBoxInstance?.close();
  }
}
