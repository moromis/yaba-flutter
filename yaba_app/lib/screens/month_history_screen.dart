import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/month_data.dart';
import '../providers/budget_provider.dart';
import '../services/export_service.dart';

class MonthHistoryScreen extends StatefulWidget {
  const MonthHistoryScreen({super.key});

  @override
  State<MonthHistoryScreen> createState() => _MonthHistoryScreenState();
}

class _MonthHistoryScreenState extends State<MonthHistoryScreen> {
  final _exportService = ExportService();
  final Set<String> _selectedMonths = {};
  bool _isCompareMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Month History'),
        actions: [
          if (_selectedMonths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.compare),
              onPressed: _compareSelectedMonths,
              tooltip: 'Compare',
            ),
          IconButton(
            icon: Icon(
              _isCompareMode ? Icons.check_box : Icons.check_box_outline_blank,
            ),
            onPressed: () {
              setState(() {
                _isCompareMode = !_isCompareMode;
                if (!_isCompareMode) {
                  _selectedMonths.clear();
                }
              });
            },
            tooltip: 'Select Mode',
          ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          final months = provider.allMonths;

          if (months.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No month history yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = _selectedMonths.contains(month.monthKey);

              return _MonthCard(
                monthData: month,
                onTap: () => _handleMonthTap(provider, month),
                onExport: () => _exportMonth(month),
                isSelectable: _isCompareMode,
                isSelected: isSelected,
                onSelect: () => _toggleSelection(month.monthKey),
              );
            },
          );
        },
      ),
    );
  }

  void _handleMonthTap(BudgetProvider provider, MonthData month) {
    if (_isCompareMode) {
      _toggleSelection(month.monthKey);
    } else {
      provider.switchMonth(month.year, month.month);
      Navigator.pop(context);
    }
  }

  void _toggleSelection(String monthKey) {
    setState(() {
      if (_selectedMonths.contains(monthKey)) {
        _selectedMonths.remove(monthKey);
      } else {
        _selectedMonths.add(monthKey);
      }
    });
  }

  Future<void> _exportMonth(MonthData month) async {
    final path = await _exportService.exportMonthToCsv(month);
    if (mounted && path != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to $path')));
    }
  }

  void _compareSelectedMonths() {
    if (_selectedMonths.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least 2 months to compare')),
      );
      return;
    }

    final provider = Provider.of<BudgetProvider>(context, listen: false);
    final selectedMonthsData = provider.allMonths
        .where((m) => _selectedMonths.contains(m.monthKey))
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonthComparisonScreen(months: selectedMonthsData),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  final MonthData monthData;
  final VoidCallback onTap;
  final VoidCallback onExport;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback onSelect;

  const _MonthCard({
    required this.monthData,
    required this.onTap,
    required this.onExport,
    this.isSelectable = false,
    this.isSelected = false,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat(
      'MMMM yyyy',
    ).format(DateTime(monthData.year, monthData.month));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: isSelectable
            ? Checkbox(value: isSelected, onChanged: (_) => onSelect())
            : CircleAvatar(
                child: Text(
                  monthData.month.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
        title: Row(
          children: [
            Text(monthName),
            if (monthData.isFrozen) ...[
              const SizedBox(width: 8),
              const Icon(Icons.lock, size: 16, color: Colors.grey),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Income',
                    value: monthData.totalIncome,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: 'Expenses',
                    value: monthData.totalExpenses,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: 'Balance',
                    value: monthData.balance,
                    color: monthData.balance >= 0 ? Colors.blue : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${monthData.transactions.length} transactions',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: monthData.isFrozen
            ? IconButton(
                icon: const Icon(Icons.file_download),
                onPressed: onExport,
                tooltip: 'Export',
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(
          '\$${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class MonthComparisonScreen extends StatelessWidget {
  final List<MonthData> months;
  final _exportService = ExportService();

  MonthComparisonScreen({super.key, required this.months}) {
    months.sort((a, b) {
      final dateA = DateTime(a.year, a.month);
      final dateB = DateTime(b.year, b.month);
      return dateA.compareTo(dateB);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Month Comparison'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () => _exportComparison(context),
            tooltip: 'Export Comparison',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildComparisonTable(),
          const SizedBox(height: 24),
          _buildAverages(),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Month')),
            DataColumn(label: Text('Income'), numeric: true),
            DataColumn(label: Text('Expenses'), numeric: true),
            DataColumn(label: Text('Balance'), numeric: true),
            DataColumn(label: Text('Trans.'), numeric: true),
          ],
          rows: months.map((month) {
            final monthName = DateFormat(
              'MMM yyyy',
            ).format(DateTime(month.year, month.month));
            return DataRow(
              cells: [
                DataCell(Text(monthName)),
                DataCell(Text('\$${month.totalIncome.toStringAsFixed(2)}')),
                DataCell(Text('\$${month.totalExpenses.toStringAsFixed(2)}')),
                DataCell(
                  Text(
                    '\$${month.balance.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: month.balance >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataCell(Text(month.transactions.length.toString())),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAverages() {
    final avgIncome =
        months.fold<double>(0, (sum, month) => sum + month.totalIncome) /
        months.length;
    final avgExpenses =
        months.fold<double>(0, (sum, month) => sum + month.totalExpenses) /
        months.length;
    final avgBalance = avgIncome - avgExpenses;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Averages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAverageStat('Average Income', avgIncome, Colors.green),
            const SizedBox(height: 8),
            _buildAverageStat('Average Expenses', avgExpenses, Colors.red),
            const SizedBox(height: 8),
            _buildAverageStat(
              'Average Balance',
              avgBalance,
              avgBalance >= 0 ? Colors.blue : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageStat(String label, double value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Future<void> _exportComparison(BuildContext context) async {
    final path = await _exportService.exportComparisonToCsv(months);
    if (context.mounted && path != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comparison exported to $path')));
    }
  }
}
