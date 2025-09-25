import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  // Placeholder methods for import/export
  void _importData() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Imported')));
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data Exported')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('App Preference', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Notifications'),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkModeEnabled,
            onChanged: (val) {
              setState(() {
                _darkModeEnabled = val;
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          const SizedBox(height: 24),
          const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _importData,
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _exportData,
          ),
          const SizedBox(height: 24),
          const Text('App Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Habit Tracker'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Developed by: AV Interactive'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('App version: v1.0.0.000001 (beta)'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Last updated on: 00.00.01'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
