import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
        // Request notification permission
        final permissionStatus = await Permission.notification.request();
        if (!permissionStatus.isGranted) {
          // Show snackbar or dialog to inform user notifications are denied
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification permission denied')),
          );
          return;
        }
      }
      // Update provider toggle value
      settings.setNotificationsEnabled(value);
      // TODO: Update notification scheduling as needed here
    }

    void onDarkModeToggle(bool value) {
      settings.setDarkModeEnabled(value);
    }

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
          const Text('App Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Import Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Launch file picker for import
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload),
            title: const Text('Export Data'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Launch file picker for export location selection and save data
            },
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
