import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService;
  AppDateFormat _dateFormat = AppDateFormat.mmddyyyy;

  SettingsProvider(this._settingsService) {
    _loadSettings();
  }

  AppDateFormat get dateFormat => _dateFormat;

  void _loadSettings() {
    _dateFormat = _settingsService.getDateFormat();
    notifyListeners();
  }

  Future<void> setDateFormat(AppDateFormat format) async {
    _dateFormat = format;
    await _settingsService.setDateFormat(format);
    notifyListeners();
  }

  String formatDate(DateTime date) {
    return _settingsService.formatDate(date, _dateFormat);
  }

  String getDateFormatLabel() {
    return _settingsService.getDateFormatLabel(_dateFormat);
  }
}
