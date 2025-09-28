import 'package:flutter/material.dart';

class HabitStatsProvider extends ChangeNotifier {
  final Map<String, Map<String, bool>> _habitCompletionData = {};

  void markHabitDone(String habitId, DateTime date, bool done) {
    final dateStr = _formatDate(date);
    _habitCompletionData.putIfAbsent(habitId, () => {});
    _habitCompletionData[habitId]![dateStr] = done;
    notifyListeners();
  }

  void markDone(String habitId, DateTime date, bool done) {
    markHabitDone(habitId, date, done);
  }

  bool isHabitDone(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    return _habitCompletionData[habitId]?[dateStr] ?? false;
  }

  int currentStreak(String habitId) {
    if (!_habitCompletionData.containsKey(habitId)) return 0;
    final today = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      if (isHabitDone(habitId, day)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int longestStreak(String habitId) {
    if (!_habitCompletionData.containsKey(habitId)) return 0;
    int longest = 0;
    int streak = 0;
    var dates = _habitCompletionData[habitId]!.keys.toList()..sort();
    for (final dateStr in dates) {
      if (_habitCompletionData[habitId]![dateStr] == true) {
        streak++;
        if (streak > longest) {
          longest = streak;
        }
      } else {
        streak = 0;
      }
    }
    return longest;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? getHabitStartDate(String habitId) {
    final completions = _habitCompletionData[habitId];
    if (completions == null || completions.isEmpty) return null;
    final dates = completions.entries.where((e) => e.value).map((e) => DateTime.parse(e.key)).toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }

  int completionsInWeek(String habitId, DateTime weekStart) {
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (isHabitDone(habitId, day)) count++;
    }
    return count;
  }
}
