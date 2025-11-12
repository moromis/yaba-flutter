import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaba_app/models/transaction_model.dart';
import 'package:yaba_app/widgets/transaction_list_item.dart';

void main() {
  group('TransactionListItem Widget Tests', () {
    testWidgets('Displays transaction information', (
      WidgetTester tester,
    ) async {
      final transaction = Transaction(
        title: 'Groceries',
        amount: 50.0,
        type: TransactionType.expense,
        category: 'groceries',
        date: DateTime(2024, 11, 12),
        notes: 'Weekly shopping',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionListItem(
              transaction: transaction,
              onEdit: () {},
              onDelete: () {},
              onToggleRecurring: () {},
            ),
          ),
        ),
      );

      expect(find.text('Groceries'), findsWidgets);
      expect(find.text('-\$50.00'), findsOneWidget);
    });

    testWidgets('Shows recurring icon when transaction is recurring', (
      WidgetTester tester,
    ) async {
      final transaction = Transaction(
        title: 'Rent',
        amount: 1500.0,
        type: TransactionType.expense,
        category: 'utilities',
        date: DateTime(2024, 11, 1),
        isRecurring: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionListItem(
              transaction: transaction,
              onEdit: () {},
              onDelete: () {},
              onToggleRecurring: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.repeat), findsOneWidget);
    });

    testWidgets('Income shows positive amount', (WidgetTester tester) async {
      final transaction = Transaction(
        title: 'Salary',
        amount: 5000.0,
        type: TransactionType.income,
        category: 'salary',
        date: DateTime(2024, 11, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionListItem(
              transaction: transaction,
              onEdit: () {},
              onDelete: () {},
              onToggleRecurring: () {},
            ),
          ),
        ),
      );

      expect(find.text('+\$5000.00'), findsOneWidget);
    });
  });
}
