import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/local_storage.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  Map<String, bool> _habitMarked = {};

  List<Habit> get habits => _habits;
  Map<String, bool> get habitMarked => _habitMarked;

  HabitProvider() {
    _loadHabits();
    _loadHabitMarked();
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
    _habitMarked.remove(id);
    await _saveHabits();
    await _saveHabitMarked();
    notifyListeners();
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadHabitMarked() async {
    final jsonString = await LocalStorage().getString('habitMarked');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> map = jsonDecode(jsonString);
        _habitMarked = map.map((k, v) => MapEntry(k, v as bool));
      } catch (_) {
        _habitMarked = {};
      }
    }
    notifyListeners();
  }

  Future<void> _saveHabitMarked() async {
    await LocalStorage().saveString('habitMarked', jsonEncode(_habitMarked));
  }

  void toggleHabitMarked(Habit habit) {
    final current = _habitMarked[habit.id] ?? false;
    _habitMarked[habit.id] = !current;
    _saveHabitMarked();
    notifyListeners();
  }
}
