import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/local_storage.dart';
import 'habit_stats_provider.dart';
import '../services/notification_service.dart';  // Adjust path if needed



class HabitProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
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
        // Initialize achievements with custom target if missing
        for (int i = 0; i < _habits.length; i++) {
          if (_habits[i].achievements == null) {
            _habits[i] = _habits[i].copyWith(
              achievements: _initDefaultAchievements(_habits[i].targetDays),
            );
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
    Habit habitWithAchievements = habit;
    if (habit.achievements == null) {
      habitWithAchievements = habit.copyWith(
        achievements: _initDefaultAchievements(habit.targetDays),
      );
    }
    _habits.add(habitWithAchievements);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      Habit updatedHabit = habit;
      if (habit.achievements == null) {
        updatedHabit = habit.copyWith(
          achievements: _initDefaultAchievements(habit.targetDays),
        );
      }
      _habits[index] = updatedHabit;
      await _saveHabits();
      notifyListeners();
    }
  }

  Future<void> removeHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    _habitCompletedToday.remove(id);
    await _saveHabits();
    await _saveHabitToday();
    notifyListeners();
  }

  Future<void> _loadHabitToday() async {
    final jsonString = await LocalStorage().getString('habitCompletedToday');
    if (jsonString != null) {
      try {
        final map = jsonDecode(jsonString);
        _habitCompletedToday = Map<String, bool>.from(map);
      } catch (e) {
        _habitCompletedToday = {};
      }
    }
    notifyListeners();
  }

  Future<void> _saveHabitToday() async {
    await LocalStorage().saveString('habitCompletedToday', jsonEncode(_habitCompletedToday));
  }

  void toggleHabitCompleted(String id) {
    bool current = _habitCompletedToday[id] ?? false;
    _habitCompletedToday[id] = !current;
    _saveHabitToday();
    notifyListeners();

    statsProvider.markHabitDone(id, DateTime.now(), !current);

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

  List<Achievement> _initDefaultAchievements(int? customTarget) {
    List<Achievement> milestones = [
      Achievement(days: 3, points: 5, achieved: false, medalIcon: 'assets/icon/medal_3_days.png'),
      Achievement(days: 7, points: 10, achieved: false, medalIcon: 'assets/icon/medal_7_days.png'),
      Achievement(days: 15, points: 15, achieved: false, medalIcon: 'assets/icon/medal_15_days.png'),
      Achievement(days: 30, points: 20, achieved: false, medalIcon: 'assets/icon/medal_30_days.png'),
      Achievement(days: 60, points: 30, achieved: false, medalIcon: 'assets/icon/medal_60_days.png'),
      Achievement(days: 90, points: 50, achieved: false, medalIcon: 'assets/icon/medal_90_days.png'),
      Achievement(days: 180, points: 75, achieved: false, medalIcon: 'assets/icon/medal_180_days.png'),
      Achievement(days: 365, points: 100, achieved: false, medalIcon: 'assets/icon/medal_365_days.png'),
    ];

    if (customTarget != null && customTarget > 0) {
      milestones.add(
        Achievement(days: customTarget, points: 0, achieved: false, label: 'Custom Target', medalIcon: 'assets/icon/medal_custom_days.png'),
      );
    } else {
      milestones.add(
        Achievement(days: 9999, points: 0, achieved: false, label: 'Custom Target Placeholder', medalIcon: 'assets/icon/medal_custom_days.png'),
      );
    }

    return milestones;
  }

  Future<void> importHabits(List<Habit> importedHabits) async {
    _habits = importedHabits;
    await _saveHabits();
    notifyListeners();
  }

  String generateJsonExport() {
    return jsonEncode(_habits.map((h) => h.toJson()).toList());
  }
}
