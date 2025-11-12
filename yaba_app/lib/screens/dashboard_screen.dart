import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/budget_provider.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/month_history_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/transaction_list_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('YABA - Budget Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthHistoryScreen(),
                ),
              );
            },
            tooltip: 'View History',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          final currentMonth = budgetProvider.currentMonth;

          if (currentMonth == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh data
              budgetProvider.switchMonth(currentMonth.year, currentMonth.month);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMonthSelector(context, budgetProvider, currentMonth),
                const SizedBox(height: 24),
                _buildSummaryCards(currentMonth),
                const SizedBox(height: 24),
                _buildCategoryBreakdown(currentMonth),
                const SizedBox(height: 24),
                _buildTransactionsList(context, budgetProvider, currentMonth),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    BudgetProvider provider,
    currentMonth,
  ) {
    final monthName = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(currentMonth.year, currentMonth.month));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                final previousMonth = DateTime(
                  currentMonth.year,
                  currentMonth.month - 1,
                );
                provider.switchMonth(previousMonth.year, previousMonth.month);
              },
            ),
            Column(
              children: [
                Text(
                  monthName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (currentMonth.isFrozen)
                  const Chip(
                    label: Text('Frozen'),
                    avatar: Icon(Icons.lock, size: 16),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                final now = DateTime.now();
                final currentDate = DateTime(
                  currentMonth.year,
                  currentMonth.month,
                );
                final today = DateTime(now.year, now.month);

                // Don't allow going past current month
                if (currentDate.isBefore(today)) {
                  final nextMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month + 1,
                  );
                  provider.switchMonth(nextMonth.year, nextMonth.month);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(currentMonth) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: 'Income',
            amount: currentMonth.totalIncome,
            color: Colors.green,
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Expenses',
            amount: currentMonth.totalExpenses,
            color: Colors.red,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SummaryCard(
            title: 'Balance',
            amount: currentMonth.balance,
            color: currentMonth.balance >= 0 ? Colors.blue : Colors.orange,
            icon: Icons.account_balance_wallet,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(currentMonth) {
    if (currentMonth.transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No transactions yet')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CategoryBreakdownChart(monthData: currentMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    BudgetProvider provider,
    currentMonth,
  ) {
    final List<Transaction> transactions = List<Transaction>.from(
      currentMonth.transactions,
    );
    transactions.sort(
      (Transaction a, Transaction b) => b.date.compareTo(a.date),
    );

    if (transactions.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Transactions (${transactions.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionListItem(
                transaction: transaction,
                onEdit: () => _editTransaction(context, transaction),
                onDelete: () =>
                    _deleteTransaction(context, provider, transaction),
                onToggleRecurring: () =>
                    provider.toggleRecurring(transaction.id),
                isFrozen: currentMonth.isFrozen,
              );
            },
          ),
        ],
      ),
    );
  }

  void _editTransaction(BuildContext context, Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    BudgetProvider provider,
    Transaction transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text(
          'Are you sure you want to delete "${transaction.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteTransaction(transaction.id);
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
