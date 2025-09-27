import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/local_storage.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  Map<String, bool> _habitCompletedToday = {};

  List<Habit> get habits => _habits;

  HabitProvider() {
    _loadHabits();
    _loadHabitCompletedToday();
  }

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

  void toggleHabitCompleted(String id) {
    bool current = _habitCompletedToday[id] ?? false;
    _habitCompletedToday[id] = !current;
    _saveHabitCompletedToday();
    notifyListeners();
  }

  bool isHabitCompletedToday(String id) {
    return _habitCompletedToday[id] ?? false;
  }

  // New method to import a list of habits completely replacing current
  Future<void> importHabits(List<Habit> importedHabits) async {
    _habits = importedHabits;
    await _saveHabits();
    notifyListeners();
  }

  // New method to generate export JSON string of habits
  String generateExportJson() {
    List<Map<String, dynamic>> jsonList = _habits.map((h) => h.toJson()).toList();
    return jsonEncode(jsonList);
  }
}
