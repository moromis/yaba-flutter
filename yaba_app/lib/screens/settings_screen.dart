import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return ListTile(
                title: const Text('Date Format'),
                subtitle: Text(settingsProvider.getDateFormatLabel()),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDateFormatDialog(context, settingsProvider),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }

  void _showDateFormatDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    final tempService = SettingsService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppDateFormat>(
              title: const Text('MM/DD/YYYY'),
              subtitle: Text(
                tempService.formatDate(DateTime.now(), AppDateFormat.mmddyyyy),
              ),
              value: AppDateFormat.mmddyyyy,
              groupValue: settingsProvider.dateFormat,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDateFormat(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppDateFormat>(
              title: const Text('DD/MM/YYYY'),
              subtitle: Text(
                tempService.formatDate(DateTime.now(), AppDateFormat.ddmmyyyy),
              ),
              value: AppDateFormat.ddmmyyyy,
              groupValue: settingsProvider.dateFormat,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDateFormat(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<AppDateFormat>(
              title: const Text('YYYY/MM/DD'),
              subtitle: Text(
                tempService.formatDate(DateTime.now(), AppDateFormat.yyyymmdd),
              ),
              value: AppDateFormat.yyyymmdd,
              groupValue: settingsProvider.dateFormat,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setDateFormat(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
