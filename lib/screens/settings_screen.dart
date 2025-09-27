import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    Future<void> onNotificationToggle(bool value) async {
      if (value) {
        final permissionStatus = await Permission.notification.request();
        if (!permissionStatus.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification permission denied')));
          return;
        }
      }
      settings.setNotificationsEnabled(value);
      // TODO: Add notification scheduling logic here
    }

    void onDarkModeToggle(bool value) {
      settings.setDarkModeEnabled(value);
    }

    Future<void> onImportData() async {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final content = await file.readAsString();
          // TODO: parse content and update provider / app state
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Imported: ${file.path}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to import data: $e')));
      }
    }

    Future<void> onExportData() async {
      try {
        // Request storage permissions
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied')));
          return;
        }

        String? selectedDir = await FilePicker.platform.getDirectoryPath();
        if (selectedDir != null) {
          // TODO: get data JSON from provider or app state
          final dataJson = '{"example":"exported data"}';

          final file = File('$selectedDir/habits_export_${DateTime.now().millisecondsSinceEpoch}.json');
          await file.writeAsString(dataJson);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Data exported to: ${file.path}')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to export data: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('App Preference',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Notifications'),
            value: settings.notificationsEnabled,
            onChanged: onNotificationToggle,
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.darkModeEnabled,
            onChanged: onDarkModeToggle,
            secondary: const Icon(Icons.dark_mode),
          ),
          const SizedBox(height: 24),
          const Text('App Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: onImportData,
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: onExportData,
          ),
          const SizedBox(height: 24),
          const Text('App Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
