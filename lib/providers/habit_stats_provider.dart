import 'package:flutter/material.dart';

class HabitStatsProvider extends ChangeNotifier {
  // Map habitId -> Map dateString (yyyy-MM-dd) -> completion status
  final Map<String, Map<String, bool>> _habitCompletionData = {};

  // Mark habit done or undone for a particular date
  void markHabitDone(String habitId, DateTime date, bool done) {
    final dateStr = _formatDate(date);
    _habitCompletionData.putIfAbsent(habitId, () => {});
    _habitCompletionData[habitId]![dateStr] = done;
    notifyListeners();
  }

  // alias for interop:
  void markDone(String habitId, DateTime date, bool done) {
    markHabitDone(habitId, date, done);
  }

  // Get if habit was done on given date
  bool isHabitDone(String habitId, DateTime date) {
    final dateStr = _formatDate(date);
    return _habitCompletionData[habitId]?[dateStr] ?? false;
  }

  // Calculate current streak up to today
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

  // Format DateTime as yyyy-MM-dd
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Add these extension methods if you use getHabitStartDate and completionsInWeek in stats:
extension HabitStatsExtensions on HabitStatsProvider {
  DateTime? getHabitStartDate(String habitId) {
    // Find earliest date where habit is done
    final completions = _habitCompletionData[habitId];
    if (completions == null || completions.isEmpty) return null;
    final dates = completions.keys
        .where((k) => completions[k] == true)
        .map((dateStr) => DateTime.parse(dateStr))
        .toList();
    if (dates.isEmpty) return null;
    dates.sort();
    return dates.first;
  }

  int completionsInWeek(String habitId, DateTime weekStart) {
    // Count completions in the 7 days starting from weekStart
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (isHabitDone(habitId, day)) count++;
    }
    return count;
  }
}
