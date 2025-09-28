import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/habit_provider.dart';
import '../providers/habit_stats_provider.dart';
import '../models/habit.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedHabitId = 'all';

  List<Habit> get _habits => context.read<HabitProvider>().habits;

  List<String> get _habitFilterIds => ['all', ..._habits.map((h) => h.id)];

  String _habitNameById(String id) {
    if (id == 'all') return 'All Habits';
    final habit = _habits.firstWhere(
      (h) => h.id == id,
      orElse: () => Habit(
        id: 'unknown_id',
        name: 'Unknown',
        iconName: '',
        iconColorHex: '',
        markerIcon: '',
        markerColorHex: '',
        targetDays: null, // Provide the required parameter
      ),
    );
    return habit.name;
  }

  List<FlSpot> _buildLineChartData(HabitStatsProvider stats, String habitId) {
    final today = DateTime.now();
    const weeksToShow = 12;
    final startDate = stats.getHabitStartDate(habitId) ??
        today.subtract(Duration(days: weeksToShow * 7));

    final spots = <FlSpot>[];
    for (int i = 0; i < weeksToShow; i++) {
      final weekStart = startDate.add(Duration(days: i * 7));
      final completions = stats.completionsInWeek(habitId, weekStart);
      spots.add(FlSpot(i.toDouble(), completions.toDouble()));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habitStats = context.watch<HabitStatsProvider>();
    final today = DateTime.now();

    if (_selectedHabitId == 'all') {
      final totalHabits = _habits.length;

      final completedCountByDay = List<int>.generate(7, (i) {
        final day = today.subtract(Duration(days: today.weekday - 1 - i));
        return _habits.where((habit) => habitStats.isHabitDone(habit.id, day)).length;
      });

      final habitProgressList = _habits.map((habit) {
        final completedDays = List.generate(7, (i) {
          final day = today.subtract(Duration(days: today.weekday - 1 - i));
          return habitStats.isHabitDone(habit.id, day);
        }).where((done) => done).length;
        final percent = (completedDays / 7) * 100;
        return _HabitProgress(habit: habit, percent: percent, completedDays: completedDays);
      }).toList()
        ..sort((a, b) => b.percent.compareTo(a.percent));

      return Scaffold(
        appBar: AppBar(title: const Text('Stats - All Habits')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: _habitFilterIds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) {
                    final id = _habitFilterIds[idx];
                    final name = _habitNameById(id);
                    final isSelected = id == _selectedHabitId;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedHabitId = id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text('Weekly Completion - All Habits', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 150,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: totalHabits.toDouble(),
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                    if (value >= 0 && value < labels.length) {
                                      return Text(labels[value.toInt()], style: const TextStyle(fontWeight: FontWeight.bold));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(7, (index) {
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: completedCountByDay[index].toDouble(),
                                    color: Colors.deepPurple,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const Text('Habit Progress (last 7 days)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            itemCount: habitProgressList.length,
                            itemBuilder: (context, index) {
                              final progress = habitProgressList[index];
                              return ListTile(
                                title: Text(progress.habit.name),
                                subtitle: LinearProgressIndicator(
                                  value: progress.percent / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.deepPurple,
                                ),
                                trailing: Text('${progress.percent.toStringAsFixed(0)}% (${progress.completedDays}/7)'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      final habit = habitProvider.getHabitById(_selectedHabitId);
      if (habit == null) {
        return const Scaffold(
          body: Center(child: Text('Habit not found')),
        );
      }

      final currentStreak = habitStats.currentStreak(_selectedHabitId);
      final longestStreak = habitStats.longestStreak(_selectedHabitId);

      final achievements = habit.achievements ?? [];
      achievements.sort((a, b) => a.requiredStreak.compareTo(b.requiredStreak));
      final nextMilestone = achievements.isNotEmpty
          ? achievements.firstWhere((a) => !a.achieved, orElse: () => achievements.last)
          : null;

      int progressToNext = 0;
      double progressPercent = 0;

      if (nextMilestone != null) {
        progressToNext = nextMilestone.requiredStreak - currentStreak;
        progressPercent = (currentStreak / nextMilestone.requiredStreak).clamp(0.0, 1.0);
      }

      final currentWeekCompletion = List.generate(7, (i) {
        final day = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - i));
        return habitStats.isHabitDone(habit.id, day);
      });

      final milestoneWidgets = achievements.map((achievement) {
        final percent = (currentStreak / achievement.requiredStreak).clamp(0.0, 1.0);
        return ListTile(
          title: Text(achievement.title),
          subtitle: LinearProgressIndicator(
            value: percent,
            color: Colors.deepPurple,
            backgroundColor: Colors.grey[200],
          ),
          trailing: Text('${(percent * 100).toStringAsFixed(0)}%'),
        );
      }).toList();

      final lineSpots = _buildLineChartData(habitStats, habit.id);

      return Scaffold(
        appBar: AppBar(
          title: Text('Stats - ${habit.name}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStreakCard('Current Streak', currentStreak),
                  _buildStreakCard('Longest Streak', longestStreak),
                ],
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Milestone: ${nextMilestone?.title ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progressPercent, color: Colors.deepPurple),
                      const SizedBox(height: 6),
                      Text('$progressToNext days to next milestone'),
                    ],
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Weekly Completion', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (i) {
                          return CircleAvatar(
                            child: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]),
                            backgroundColor: currentWeekCompletion[i] ? Colors.deepPurple : Colors.grey[300],
                            foregroundColor: currentWeekCompletion[i] ? Colors.white : Colors.black54,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Milestone Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...milestoneWidgets,
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall Progress (weeks)', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  interval: 1,
                                  getTitlesWidget: (value, _) => Text('W ${value.toInt() + 1}'),
                                ),
                              ),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 1)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                color: Colors.deepPurple,
                                spots: lineSpots,
                                isCurved: true,
                                barWidth: 4,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  List<FlSpot> _buildLineChartData(HabitStatsProvider stats, String habitId) {
    final today = DateTime.now();
    const weeksToShow = 12;
    final startDate = stats.getHabitStartDate(habitId) ??
        today.subtract(Duration(days: weeksToShow * 7));

    final spots = <FlSpot>[];
    for (int i = 0; i < weeksToShow; i++) {
      final weekStart = startDate.add(Duration(days: i * 7));
      final completions = stats.completionsInWeek(habitId, weekStart);
      spots.add(FlSpot(i.toDouble(), completions.toDouble()));
    }
    return spots;
  }

  Widget _buildStreakCard(String title, int value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(value.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(title),
          ],
        ),
      ),
    );
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
