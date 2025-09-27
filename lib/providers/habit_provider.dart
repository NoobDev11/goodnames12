import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../data/local_storage.dart';
import 'habit_stats_provider.dart';
import '../services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<Habit> _habits = [];
  Map<String, bool> _habitCompletedToday = {};

  final HabitStatsProvider statsProvider;

  HabitProvider(this.statsProvider) {
    _init();
  }

  Future<void> _init() async {
    await _notificationService.init();
    await _loadHabits();
    await _loadHabitToday();
  }

  List<Habit> get habits => _habits;

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadHabits() async {
    final jsonString = await LocalStorage().get('habits');
    if (jsonString != null) {
      try {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _habits = jsonList.map((json) => Habit.fromJson(json)).toList();

        for (int i = 0; i < _habits.length; i++) {
          if (_habits[i].achievements == null) {
            _habits[i] = _habits[i].copyWith(
                achievements: _initDefaultAchievements(_habits[i].targetDays));
            await _scheduleNotificationForHabit(_habits[i]);
          }
        }
      } catch (_) {
        _habits = [];
      }
    }
    notifyListeners();
  }

  // Other existing methods remain the same...

  // No change needed for notification scheduling, save/load, toggle, etc.

  List<Achievement> _initDefaultAchievements(int? customTarget) {
    List<Achievement> milestones = [
      Achievement(days: 3, points: 5, achieved: false, medalIconAsset: 'assets/icon/medal_3_days.png'),
      Achievement(days: 7, points: 10, achieved: false, medalIconAsset: 'assets/icon/medal_7_days.png'),
      Achievement(days: 15, points: 15, achieved: false, medalIconAsset: 'assets/icon/medal_15_days.png'),
      Achievement(days: 30, points: 20, achieved: false, medalIconAsset: 'assets/icon/medal_30_days.png'),
      Achievement(days: 60, points: 30, achieved: false, medalIconAsset: 'assets/icon/medal_60_days.png'),
      Achievement(days: 90, points: 50, achieved: false, medalIconAsset: 'assets/icon/medal_90_days.png'),
      Achievement(days: 180, points: 75, achieved: false, medalIconAsset: 'assets/icon/medal_180_days.png'),
      Achievement(days: 365, points: 100, achieved: false, medalIconAsset: 'assets/icon/medal_365_days.png'),
    ];
    if (customTarget != null && customTarget > 0) {
      milestones.add(Achievement(days: customTarget, points: 0, achieved: false, label: 'Custom Target', medalIconAsset: 'assets/icon/medal_custom_days.png'));
    } else {
      milestones.add(Achievement(days: 9999, points: 0, achieved: false, label: 'Custom Target Placeholder', medalIconAsset: 'assets/icon/medal_custom_days.png'));
    }
    return milestones;
  }
}
