import 'package:hive/hive.dart';

enum AppDateFormat { mmddyyyy, ddmmyyyy, yyyymmdd }

class SettingsService {
  static const String _boxName = 'settings';
  static const String _dateFormatKey = 'dateFormat';

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  AppDateFormat getDateFormat() {
    final value = _box?.get(_dateFormatKey, defaultValue: 'mmddyyyy');
    switch (value) {
      case 'ddmmyyyy':
        return AppDateFormat.ddmmyyyy;
      case 'yyyymmdd':
        return AppDateFormat.yyyymmdd;
      default:
        return AppDateFormat.mmddyyyy;
    }
  }

  Future<void> setDateFormat(AppDateFormat format) async {
    String value;
    switch (format) {
      case AppDateFormat.mmddyyyy:
        value = 'mmddyyyy';
        break;
      case AppDateFormat.ddmmyyyy:
        value = 'ddmmyyyy';
        break;
      case AppDateFormat.yyyymmdd:
        value = 'yyyymmdd';
        break;
    }
    await _box?.put(_dateFormatKey, value);
  }

  String formatDate(DateTime date, AppDateFormat format) {
    switch (format) {
      case AppDateFormat.mmddyyyy:
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case AppDateFormat.ddmmyyyy:
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case AppDateFormat.yyyymmdd:
        return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }

  String getDateFormatLabel(AppDateFormat format) {
    switch (format) {
      case AppDateFormat.mmddyyyy:
        return 'MM/DD/YYYY';
      case AppDateFormat.ddmmyyyy:
        return 'DD/MM/YYYY';
      case AppDateFormat.yyyymmdd:
        return 'YYYY/MM/DD';
    }
  }
}
