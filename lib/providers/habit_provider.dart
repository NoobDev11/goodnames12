import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/local_storage.dart';
// Import your habit_stats_provider to link here (assuming in same level)
import 'habit_stats_provider.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  Map<String, bool> _habitCompletedToday = {};

  final HabitStatsProvider statsProvider;

  HabitProvider(this.statsProvider) {
    _loadHabits();
    _loadHabitCompletedToday();
  }

  List<Habit> get habits => _habits;

  Future<void> _loadHabits() async {
    final jsonString = await LocalStorage().getString('habits');
    if (jsonString != null) {
      try {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _habits = jsonList
            .map((json) => Habit.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _habits = [];
      }
    }
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    final jsonList = _habits.map((habit) => habit.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await LocalStorage().saveString('habits', jsonString);
  }

  Future<void> addHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      _habits[index] = habit;
      await _saveHabits();
      notifyListeners();
    }
  }

  Future<void> removeHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    _habitCompletedToday.remove(id);
    await _saveHabits();
    await _saveHabitCompletedToday();
    notifyListeners();
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadHabitCompletedToday() async {
    final jsonString = await LocalStorage().getString('habitCompletedToday');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        _habitCompletedToday = map.map((k, v) => MapEntry(k, v as bool));
      } catch (_) {
        _habitCompletedToday = {};
      }
    }
    notifyListeners();
  }

  Future<void> _saveHabitCompletedToday() async {
    await LocalStorage().saveString('habitCompletedToday', jsonEncode(_habitCompletedToday));
  }

  // Updated toggle to notify stats provider about completion change
  void toggleHabitCompleted(String id) {
    bool current = _habitCompletedToday[id] ?? false;
    _habitCompletedToday[id] = !current;
    _saveHabitCompletedToday();
    notifyListeners();

    // Update stats provider about today's habit completion
    statsProvider.markHabitDone(id, DateTime.now(), !current);

    // TODO: Add achievement unlocking logic here if needed
  }

  bool isHabitCompletedToday(String id) {
    return _habitCompletedToday[id] ?? false;
  }

  // Import replaces all habits - consider resetting stats or re-importing appropriately
  Future<void> importHabits(List<Habit> importedHabits) async {
    _habits = importedHabits;

    // Ideally reset or recalculate stats here
    // TODO: Integration with statsProvider for imported data sync

    await _saveHabits();
    notifyListeners();
  }

  // Generate JSON for export, consider also exporting stats and achievements
  String generateExportJson() {
    List<Map<String, dynamic>> jsonList = _habits.map((h) => h.toJson()).toList();
    return jsonEncode(jsonList);
  }
}
