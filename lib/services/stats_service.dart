class StatsService {
  static final StatsService _instance = StatsService._internal();

  factory StatsService() {
    return _instance;
  }

  StatsService._internal();

  final Map<String, List<bool>> _habitCompletionHistory = {};

  // Add completion status for a habit on a date (true = completed)
  void addCompletion(String habitId, bool completed) {
    _habitCompletionHistory.putIfAbsent(habitId, () => []);
    _habitCompletionHistory[habitId]!.add(completed);
  }

  List<bool> getCompletionHistory(String habitId) {
    return _habitCompletionHistory[habitId] ?? [];
  }

  int getCurrentStreak(String habitId) {
    List<bool> history = getCompletionHistory(habitId);
    int streak = 0;
    for (int i = history.length - 1; i >= 0; i--) {
      if (history[i]) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
