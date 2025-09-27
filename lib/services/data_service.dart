import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/settings_provider.dart';

class DataService {
  final HabitProvider habitProvider;
  final SettingsProvider settingsProvider;

  DataService(this.habitProvider, this.settingsProvider);

  /// Exports habits and settings data as JSON string
  String prepareExportJson() {
    final habitListJson = habitProvider.habits.map((h) => h.toJson()).toList();
    final settingsJson = {
      'notificationsEnabled': settingsProvider.notificationsEnabled,
      'darkMode': settingsProvider.isDarkMode,
    };
    final exportJson = jsonEncode({
      'habits': habitListJson,
      'settings': settingsJson,
    });
    return exportJson;
  }

  /// Saves the JSON string to the application's documents directory
  Future<File> saveExportToFile(String filename, String jsonData) async {
    // Get the app document directory using path_provider
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';
    final file = File(path);
    await file.writeAsString(jsonData, flush: true);
    return file;
  }

  /// Loads JSON from file and import data into providers
  Future<void> importFromFile(File file) async {
    final jsonString = await file.readAsString();
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    if (jsonData.containsKey('habits')) {
      List<dynamic> habitJsonList = jsonData['habits'];
      final List<Habit> importedHabits = habitJsonList
          .map((json) => Habit.fromJson(json))
          .toList();
      habitProvider.importHabits(importedHabits);
    }

    if (jsonData.containsKey('settings')) {
      final settingsJson = jsonData['settings'];
      if (settingsJson.containsKey('notificationsEnabled')) {
        settingsProvider.setNotificationsEnabled(settingsJson['notificationsEnabled'] as bool);
      }
      if (settingsJson.containsKey('darkMode')) {
        settingsProvider.setDarkMode(settingsJson['darkMode'] as bool);
      }
    }
  }
}
