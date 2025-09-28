import 'package:flutter/material.dart';

class HabitStatsProvider extends ChangeNotifier {
  // Map of habitId -> Map of date String (yyyy-MM-dd) -> completion bool
  final Map<String, Map<String, bool>> _habitCompletionData = {};

  // Mark habit done for particular date
  void markHabitDone(String habitId, DateTime date, bool done) {
    final dateStr = _formatDate(date);
    _habitCompletionData.putIfAbsent(habitId, () => {});
    _habitCompletionData[habitId]![dateStr] = done;
    notifyListeners();
  }

  // Alias as used in HabitProvider
  void markDone(String habitId, DateTime date, bool done) {
    markHabitDone(habitId, date, done);
  }

  // Check if habit done on given date
  bool isHabitDone(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    return _habitCompletionData[habitId]?[dateStr] ?? false;
  }

  // Calculate current streak of consecutive days up to today
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

  // Calculate longest streak
  int longestStreak(String habitId) {
    if (!_habitCompletionData.containsKey(habitId)) return 0;
    int longest = 0;
    int streak = 0;
    var dates = _habitCompletionData[habitId]!.keys.toList();
    dates.sort();
    for (var dateStr in dates) {
      if (_habitCompletionData[habitId]![dateStr] == true) {
        streak++;
        longest = streak > longest ? streak : longest;
      } else {
        streak = 0;
      }
    }
    return longest;
  }

  // Get habit start date (earliest completion record)
  DateTime? getHabitStartDate(String habitId) {
    final data = _habitCompletionData[habitId];
    if (data == null || data.isEmpty) return null;
    final dates = data.entries
        .where((e) => e.value)
        .map((e) => DateTime.parse(e.key))
        .toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }

  // Number of completions in the week starting at weekStart
  int completionsInWeek(String habitId, DateTime weekStart) {
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (isHabitDone(habitId, day)) count++;
    }
    return count;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
