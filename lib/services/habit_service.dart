import '../models/habit.dart';

class HabitService {
  static final HabitService _instance = HabitService._internal();

  factory HabitService() {
    return _instance;
  }

  HabitService._internal();

  final List<Habit> _habits = [];

  List<Habit> get habits => List.unmodifiable(_habits);

  void addHabit(Habit habit) {
    _habits.add(habit);
  }

  void updateHabit(Habit habit) {
    int index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      _habits[index] = habit;
    }
  }

  void removeHabit(String id) {
    _habits.removeWhere((h) => h.id == id);
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }
}
