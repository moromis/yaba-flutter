import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../models/month_data.dart';

class ExportService {
  Future<String?> exportMonthToCsv(MonthData monthData) async {
    try {
      // Create CSV data
      List<List<dynamic>> rows = [
        ['Date', 'Title', 'Category', 'Type', 'Amount', 'Recurring', 'Notes'],
      ];

      for (var transaction in monthData.transactions) {
        rows.add([
          DateFormat('yyyy-MM-dd').format(transaction.date),
          transaction.title,
          transaction.category,
          transaction.type.toString().split('.').last,
          transaction.amount.toStringAsFixed(2),
          transaction.isRecurring ? 'Yes' : 'No',
          transaction.notes ?? '',
        ]);
      }

      // Add summary
      rows.add([]);
      rows.add(['Summary']);
      rows.add(['Total Income', monthData.totalIncome.toStringAsFixed(2)]);
      rows.add(['Total Expenses', monthData.totalExpenses.toStringAsFixed(2)]);
      rows.add(['Balance', monthData.balance.toStringAsFixed(2)]);

      String csv = const ListToCsvConverter().convert(rows);

      // Let user pick save location
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save CSV Export',
        fileName: 'yaba_${monthData.monthKey}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputPath == null) {
        return null; // User cancelled
      }

      // Write to file
      final file = File(outputPath);
      await file.writeAsString(csv);

      return outputPath;
    } catch (e) {
      // Error exporting to CSV
      return null;
    }
  }

  Future<String?> exportComparisonToCsv(List<MonthData> months) async {
    try {
      List<List<dynamic>> rows = [
        [
          'Month',
          'Total Income',
          'Total Expenses',
          'Balance',
          'Transactions Count',
        ],
      ];

      for (var month in months) {
        rows.add([
          month.monthKey,
          month.totalIncome.toStringAsFixed(2),
          month.totalExpenses.toStringAsFixed(2),
          month.balance.toStringAsFixed(2),
          month.transactions.length,
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Comparison Export',
        fileName:
            'yaba_comparison_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputPath == null) {
        return null;
      }

      final file = File(outputPath);
      await file.writeAsString(csv);

      return outputPath;
    } catch (e) {
      // Error exporting comparison
      return null;
    }
  }
}
