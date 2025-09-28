import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart' as habit_provider;
import '../models/habit.dart' as habit_model;
import '../models/achievement.dart' as achievement_model;

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> with SingleTickerProviderStateMixin {
  String? _selectedHabitId;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    final habits = context.read<habit_provider.HabitProvider>().habits;
    _selectedHabitId = habits.isNotEmpty ? habits.first.id : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<achievement_model.Achievement> _getAchievementsForHabit(habit_model.Habit habit) {
    return habit.achievements ?? <achievement_model.Achievement>[];
  }

  int _calculateTotalPoints(List<achievement_model.Achievement> achievements) {
    return achievements.where((a) => a.achieved).fold(0, (sum, a) => sum + a.points);
  }

  int _calculateMedalsEarned(List<achievement_model.Achievement> achievements) {
    return achievements.where((a) => a.achieved).length;
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<habit_provider.HabitProvider>();
    final habits = habitProvider.habits;

    habit_model.Habit? habit;
    if (_selectedHabitId != null && _selectedHabitId!.isNotEmpty) {
      habit = habits.isNotEmpty
          ? habits.firstWhere(
              (h) => h.id == _selectedHabitId,
              orElse: () => habits.first,
            )
          : null;
    } else {
      habit = habits.isNotEmpty ? habits.first : null;
    }

    if (habit == null) {
      return const Scaffold(
        body: Center(child: Text('No habits found')),
      );
    }

    final achievements = _getAchievementsForHabit(habit);
    final totalPoints = _calculateTotalPoints(achievements);
    final medalsEarned = _calculateMedalsEarned(achievements);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.star, size: 48, color: Colors.amber),
                      Text(
                        '$totalPoints',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text('Total Points'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.emoji_events, size: 48, color: Colors.orange),
                      Text(
                        '$medalsEarned',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text('Medals Earned'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final h = habits[index];
                final isSelected = h.id == _selectedHabitId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedHabitId = h.id;
                      _controller.reset();
                      _controller.forward();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        h.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  final isAchieved = achievement.achieved;
                  final label = achievement.title;
                  final points = achievement.points;

                  return Semantics(
                    label: 'Achievement: $label, $points points',
                    selected: isAchieved,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isAchieved ? Colors.deepPurple : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Image.asset(
                              achievement.medalAsset,
                              width: 36,
                              height: 36,
                              color: isAchieved ? null : Colors.black26,
                            ),
                          ),
                          Text(
                            label,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isAchieved ? Colors.white : Colors.black54,
                            ),
                          ),
                          Text(
                            '$points points',
                            style: TextStyle(
                              color: isAchieved ? Colors.white70 : Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
