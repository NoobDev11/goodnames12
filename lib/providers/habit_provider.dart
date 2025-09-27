import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/local_storage.dart';
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
        // Initialize achievements for habits if they are null
        for (int i = 0; i < _habits.length; i++) {
          if (_habits[i].achievements == null) {
            _habits[i] = _habits[i].copyWith(achievements: _initDefaultAchievements());
          }
        }
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
    // Initialize achievements if not provided
    Habit habitWithAchievements =
        habit.achievements == null ? habit.copyWith(achievements: _initDefaultAchievements()) : habit;
    _habits.add(habitWithAchievements);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      // Ensure achievements present
      Habit habitWithAchievements = habit.achievements == null
          ? habit.copyWith(achievements: _initDefaultAchievements())
          : habit;
      _habits[index] = habitWithAchievements;
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

    // Notify stats provider about completion toggle
    statsProvider.markHabitDone(id, DateTime.now(), !current);

    // Unlock achievements if conditions met
    Habit? habit = getHabitById(id);
    if (habit != null && habit.achievements != null) {
      bool updated = false;
      for (var achievement in habit.achievements!) {
        if (!achievement.achieved) {
          int streak = statsProvider.currentStreak(id);
          if (streak >= achievement.days) {
            achievement.achieved = true;
            updated = true;
          }
        }
      }
      if (updated) {
        saveAchievementsForHabit(habit);
      }
    }
  }

  Future<void> saveAchievementsForHabit(Habit habit) async {
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      _habits[index] = habit;
      await _saveHabits();
      notifyListeners();
    }
  }

  bool isHabitCompletedToday(String id) {
    return _habitCompletedToday[id] ?? false;
  }

  List<Achievement> _initDefaultAchievements() {
    return [
      Achievement(days: 3, points: 5, achieved: false, medalIconAsset: 'assets/medals/medal_3_days.png'),
      Achievement(days: 7, points: 10, achieved: false, medalIconAsset: 'assets/medals/medal_7_days.png'),
      Achievement(days: 15, points: 15, achieved: false, medalIconAsset: 'assets/medals/medal_15_days.png'),
      Achievement(days: 30, points: 20, achieved: false, medalIconAsset: 'assets/medals/medal_30_days.png'),
      Achievement(days: 60, points: 30, achieved: false, medalIconAsset: 'assets/medals/medal_60_days.png'),
      Achievement(days: 90, points: 50, achieved: false, medalIconAsset: 'assets/medals/medal_90_days.png'),
      Achievement(days: 180, points: 75, achieved: false, medalIconAsset: 'assets/medals/medal_180_days.png'),
      Achievement(days: 365, points: 100, achieved: false, medalIconAsset: 'assets/medals/medal_365_days.png'),
      Achievement(days: 9999, points: 0, achieved: false, label: 'Custom Set Target', medalIconAsset: 'assets/medals/medal_custom.png'),
    ];
  }

  Future<void> importHabits(List<Habit> importedHabits) async {
    _habits = importedHabits;
    // You may want to reset or sync statsProvider here
    await _saveHabits();
    notifyListeners();
  }

  String generateExportJson() {
    List<Map<String, dynamic>> jsonList = _habits.map((h) => h.toJson()).toList();
    return jsonEncode(jsonList);
  }
}
