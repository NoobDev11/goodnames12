import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/habit_provider.dart';
import '../services/data_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final habitProvider = context.read<HabitProvider>();
    final dataService = DataService(habitProvider, settings);

    Future<void> onNotificationToggle(bool value) async {
      if (value) {
        final permissionStatus = await Permission.notification.request();
        if (!permissionStatus.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notification permission denied')),
            );
          }
          return;
        }
      }
      if (!mounted) return;
      settings.setNotificationsEnabled(value);
      // TODO: Add notification schedule/unschedule logic
    }

    void onDarkModeToggle(bool value) {
      settings.setDarkModeEnabled(value);
    }

    Future<void> onImport() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (result != null && result.files.single.path != null) {
          if (!mounted) return;
          final file = File(result.files.single.path!);
          await dataService.importFromFile(file);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imported data from: ${file.path}')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import data: $e')),
        );
      }
    }

    Future<void> onExport() async {
      try {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Storage permission denied')),
            );
          }
          return;
        }

        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unable to access storage directory')),
            );
          }
          return;
        }

        final path = directory.path;
        final fileName = 'habits_export_${DateTime.now().millisecondsSinceEpoch}.json';
        final filePath = '$path/$fileName';

        final json = dataService.prepareJsonExport();
        final file = File(filePath);
        await file.writeAsString(json);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Exported data to: $filePath')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to export data: $e')),
          );
        }
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
          const Text('App Preferences',
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
          const Text('Data Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: onImport,
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: onExport,
          ),
          const SizedBox(height: 24),
          const Text('About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    child: Text('Developed by AV Interactive'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text('Version: v1.0.0.000001'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Last updated: 00.00.01'),
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
