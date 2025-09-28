import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../models/achievement.dart' as achievement_model;
import '../data/local_storage.dart';
import 'habit_stats_provider.dart';
import '../services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<Habit> _habits = [];
  final Map<String, bool> _habitCompletedToday = {};

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
    final jsonString = await LocalStorage.instance.getString('habits');
    if (jsonString != null) {
      try {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _habits = jsonList.map((json) {
          final parsedHabit = Habit.fromJson(json);
          if (parsedHabit.achievements != null) {
            final achievementsJson = json['achievements'] as List<dynamic>;
            final achievements = achievementsJson
                .map((e) => achievement_model.Achievement.fromJson(e))
                .toList();
            return parsedHabit.copyWith(achievements: achievements);
          } else {
            return parsedHabit;
          }
        }).toList();

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

  Future<void> _saveHabits() async {
    final jsonList = _habits.map((h) => h.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await LocalStorage.instance.setString('habits', jsonString);
  }

  Future<void> addHabit(Habit habit) async {
    Habit habitWithAchievements = habit;
    if (habit.achievements == null) {
      habitWithAchievements = habit.copyWith(
          achievements: _initDefaultAchievements(habit.targetDays));
    }
    _habits.add(habitWithAchievements);
    await _saveHabits();
    await _scheduleNotificationForHabit(habitWithAchievements);
    notifyListeners();
  }

  Future<void> updateHabit(Habit habit) async {
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      Habit habitWithAchievements = habit;
      if (habit.achievements == null) {
        habitWithAchievements = habit.copyWith(
            achievements: _initDefaultAchievements(habit.targetDays));
      }
      _habits[index] = habitWithAchievements;
      await _saveHabits();
      await _scheduleNotificationForHabit(habitWithAchievements);
      notifyListeners();
    }
  }

  Future<void> removeHabit(String id) async {
    _habits.removeWhere((h) => h.id == id);
    _habitCompletedToday.remove(id);
    await _saveHabits();
    await _saveHabitToday();
    await _notificationService.cancel(_notificationId(id));
    notifyListeners();
  }

  Future<void> _loadHabitToday() async {
    final jsonString =
        await LocalStorage.instance.getString('habitCompletedToday');
    if (jsonString != null) {
      try {
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        _habitCompletedToday.clear();
        map.forEach((key, value) {
          _habitCompletedToday[key] = value as bool;
        });
      } catch (_) {
        _habitCompletedToday.clear();
      }
    }
    notifyListeners();
  }

  Future<void> _saveHabitToday() async {
    final jsonString = jsonEncode(_habitCompletedToday);
    await LocalStorage.instance.setString('habitCompletedToday', jsonString);
  }

  void toggleHabitCompleted(String id) {
    final isCompleted = _habitCompletedToday[id] ?? false;
    _habitCompletedToday[id] = !isCompleted;
    _saveHabitToday();
    notifyListeners();

    if (statsProvider.markDone != null) {
      statsProvider.markDone!(id, DateTime.now(), !isCompleted);
    }

    final habit = getHabitById(id);
    if (habit != null) {
      bool updated = false;
      // need to copy achievements to mutate them safely
      List<achievement_model.Achievement> updatedAchievements =
          habit.achievements?.map((a) => a.copyWith()).toList() ?? [];

      for (final achievement in updatedAchievements) {
        if (!achievement.achieved) {
          if (statsProvider.currentStreak != null &&
              statsProvider.currentStreak!(id) >= achievement.requiredStreak) {
            achievement.achieved = true;
            updated = true;
          }
        }
      }
      if (updated) {
        final updatedHabit = habit.copyWith(achievements: updatedAchievements);
        saveAchievements(updatedHabit);
      }
    }
  }

  Future<void> saveAchievements(Habit habit) async {
    final idx = _habits.indexWhere((h) => h.id == habit.id);
    if (idx != -1) {
      _habits[idx] = habit;
      await _saveHabits();
      notifyListeners();
    }
  }

  bool isHabitCompletedToday(String id) => _habitCompletedToday[id] ?? false;

  int _notificationId(String habitId) => habitId.hashCode & 0x7FFFFFFF;

  Future<void> _scheduleNotificationForHabit(Habit habit) async {
    if (habit.reminderTime == null) {
      await _notificationService.cancel(_notificationId(habit.id));
      return;
    }
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day,
        habit.reminderTime!.hour, habit.reminderTime!.minute);
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }
    await _notificationService.scheduleNotification(
      _notificationId(habit.id),
      'Time for your habit!',
      'Don\'t forget to complete "${habit.name}" today.',
      scheduledTime,
    );
  }

  List<achievement_model.Achievement> _initDefaultAchievements(int? customTarget) {
    final milestones = <achievement_model.Achievement>[
      achievement_model.Achievement(
        id: '1',
        habitId: '',
        title: '3 Days',
        requiredStreak: 3,
        points: 5,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_3_days.png',
      ),
      achievement_model.Achievement(
        id: '2',
        habitId: '',
        title: '7 Days',
        requiredStreak: 7,
        points: 10,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_7_days.png',
      ),
      achievement_model.Achievement(
        id: '3',
        habitId: '',
        title: '15 Days',
        requiredStreak: 15,
        points: 15,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_15_days.png',
      ),
      achievement_model.Achievement(
        id: '4',
        habitId: '',
        title: '30 Days',
        requiredStreak: 30,
        points: 20,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_30_days.png',
      ),
      achievement_model.Achievement(
        id: '5',
        habitId: '',
        title: '60 Days',
        requiredStreak: 60,
        points: 30,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_60_days.png',
      ),
      achievement_model.Achievement(
        id: '6',
        habitId: '',
        title: '90 Days',
        requiredStreak: 90,
        points: 50,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_90_days.png',
      ),
      achievement_model.Achievement(
        id: '7',
        habitId: '',
        title: '180 Days',
        requiredStreak: 180,
        points: 75,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_180_days.png',
      ),
      achievement_model.Achievement(
        id: '8',
        habitId: '',
        title: '365 Days',
        requiredStreak: 365,
        points: 100,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_365_days.png',
      ),
    ];

    if (customTarget != null && customTarget > 0) {
      milestones.add(achievement_model.Achievement(
        id: 'custom',
        habitId: '',
        title: 'Custom Target',
        requiredStreak: customTarget,
        points: 0,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_custom_days.png',
      ));
    } else {
      milestones.add(achievement_model.Achievement(
        id: 'custom_placeholder',
        habitId: '',
        title: 'Custom Target Placeholder',
        requiredStreak: 9999,
        points: 0,
        achieved: false,
        medalIconAsset: 'assets/icon/medal_custom_days.png',
      ));
    }

    return milestones;
  }
}

class _HabitProgress {
  final Habit habit;
  final double percent;
  final int completedDays;

  _HabitProgress({
    required this.habit,
    required this.percent,
    required this.completedDays,
  });
}
