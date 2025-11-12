import 'transaction_model.dart';

class MonthData {
  final int year;
  final int month;
  final List<Transaction> transactions;
  final bool isFrozen;

  MonthData({
    required this.year,
    required this.month,
    required this.transactions,
    this.isFrozen = false,
  });

  String get monthKey => '$year-${month.toString().padLeft(2, '0')}';

  DateTime get monthDate => DateTime(year, month);

  double get totalIncome {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpenses;

  Map<String, double> get expensesByCategory {
    final Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return categoryTotals;
  }

  Map<String, double> get incomeByCategory {
    final Map<String, double> categoryTotals = {};

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    return categoryTotals;
  }

  MonthData copyWith({
    int? year,
    int? month,
    List<Transaction>? transactions,
    bool? isFrozen,
  }) {
    return MonthData(
      year: year ?? this.year,
      month: month ?? this.month,
      transactions: transactions ?? this.transactions,
      isFrozen: isFrozen ?? this.isFrozen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'isFrozen': isFrozen,
    };
  }

  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      year: json['year'],
      month: json['month'],
      transactions: (json['transactions'] as List)
          .map((t) => Transaction.fromJson(t))
          .toList(),
      isFrozen: json['isFrozen'] ?? false,
    );
  }
}
