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

  // Use these for UI habit selection and labels
  List<String> get _habitFilterIds => ['all', ..._habits.map((h) => h.id)];

  String _habitNameById(String id) {
    if (id == 'all') return 'All Habits';
    final habit = _habits.firstWhere(
      (h) => h.id == id,
      orElse: () => Habit(
        id: 'all',
        name: 'Unknown',
        iconName: '',
        iconColorHex: '',
        markerIcon: '',
        markerColorHex: '',
      ),
    );
    return habit.name;
  }

  List<FlSpot> _buildLineChartData(HabitStatsProvider habitStats, String habitId) {
    final today = DateTime.now();
    const weeksToShow = 12;
    final startDate = habitStats.getHabitStartDate(habitId) ??
        today.subtract(Duration(days: weeksToShow * 7));

    final spots = <FlSpot>[];
    for (int i = 0; i < weeksToShow; i++) {
      final weekStart = startDate.add(Duration(days: i * 7));
      final completions = habitStats.completionsInWeek(habitId, weekStart);
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

      final completedHabitCountByDay = List<int>.generate(7, (i) {
        final day = today.subtract(Duration(days: today.weekday - 1 - i));
        int completedCount = 0;
        for (final habit in _habits) {
          if (habitStats.isHabitDone(habit.id, day)) completedCount++;
        }
        return completedCount;
      });

      final habitProgressList = _habits.map((habit) {
        int daysCompleted = 0;
        for (int i = 0; i < 7; i++) {
          final day = today.subtract(Duration(days: today.weekday - 1 - i));
          if (habitStats.isHabitDone(habit.id, day)) daysCompleted++;
        }
        final percent = (daysCompleted / 7) * 100;
        return _HabitProgress(
            habit: habit, percent: percent, completedDays: daysCompleted);
      }).toList()
        ..sort((a, b) => b.percent.compareTo(a.percent));

      return Scaffold(
        appBar: AppBar(title: const Text('Stats - All Habits')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Habit filter tabs
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _habitFilterIds.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, idx) {
                    final id = _habitFilterIds[idx];
                    final name = _habitNameById(id);
                    final isSelected = id == _selectedHabitId;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedHabitId = id);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected ? Colors.white : Colors.black87)),
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
                      const Text('Weekly Completion - All Habits',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                                      return Text(labels[value.toInt()],
                                          style: const TextStyle(fontWeight: FontWeight.bold));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles:
                                  AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(
                              7,
                              (i) => BarChartGroupData(x: i, barRods: [
                                BarChartRodData(
                                  toY: completedHabitCountByDay[i].toDouble(),
                                  color: Colors.deepPurple,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ]),
                            ),
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
                        const Text("Habit Weekly Progress",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            itemCount: habitProgressList.length,
                            itemBuilder: (context, index) {
                              final hp = habitProgressList[index];
                              return ListTile(
                                title: Text(hp.habit.name),
                                subtitle: LinearProgressIndicator(
                                  backgroundColor: Colors.grey[300],
                                  value: hp.percent / 100,
                                  color: Colors.deepPurple,
                                ),
                                trailing: Text(
                                    '${hp.percent.toStringAsFixed(0)}% (${hp.completedDays}/7)'),
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
      final Habit? habit = habitProvider.getHabitById(_selectedHabitId);
      if (habit == null) {
        return const Scaffold(body: Center(child: Text('Habit not found')));
      }

      final currentStreak = habitStats.currentStreak(_selectedHabitId);
      final longestStreak = habitStats.longestStreak(_selectedHabitId);

      final achievements = habit.achievements ?? [];
      achievements.sort((a, b) => a.days.compareTo(b.days));
      final nextMilestone = achievements.firstWhere(
          (a) => !a.achieved,
          orElse: () => achievements.isNotEmpty
              ? achievements.last
              : achievements.first);

      int progressToNext = 0;
      double progressPercent = 0;
      if (nextMilestone != null) {
        progressToNext = nextMilestone.days - currentStreak;
        progressPercent = (currentStreak / nextMilestone.days).clamp(0.0, 1.0);
      }

      final currentWeekCompletion =
          List<bool>.generate(7, (i) {
        final day = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1 - i));
        return habitStats.isHabitDone(_selectedHabitId, day);
      });

      final milestoneWidgets = achievements.map((a) {
        final percentDone = (currentStreak / a.days).clamp(0.0, 1.0);
        return ListTile(
          title: Text(a.label ?? '${a.days} Days'),
          subtitle: LinearProgressIndicator(
              value: percentDone,
              color: Colors.deepPurple,
              backgroundColor: Colors.grey[200]),
          trailing: Text('${(percentDone * 100).toStringAsFixed(0)}%'),
        );
      }).toList();

      final lineSpots = _buildLineChartData(habitStats, _selectedHabitId);

      return Scaffold(
        appBar: AppBar(title: Text('Stats - ${habit.name}')),
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
                      Text('Next Milestone: ${nextMilestone.label}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                          value: progressPercent, color: Colors.deepPurple),
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
                      const Text('Weekly Completion',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (i) {
                          return CircleAvatar(
                            child: Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]),
                            backgroundColor: currentWeekCompletion[i]
                                ? Colors.deepPurple
                                : Colors.grey[300],
                            foregroundColor: currentWeekCompletion[i]
                                ? Colors.white
                                : Colors.black54,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Milestone Progress',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ...milestoneWidgets
                  ],
                ),
              ),
              Card(
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Overall Progress (weeks)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                                  getTitlesWidget: (value, meta) {
                                    return Text('W ${value.toInt() + 1}');
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 40,
                                ),
                              ),
                              rightTitles:
                                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles:
                                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  Widget _buildStreakCard(String title, int value) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(value.toString(),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(title),
        ]),
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

// Extension to add missing methods to HabitStatsProvider (temporary)
extension HabitStatsExtensions on HabitStatsProvider {
  DateTime? getHabitStartDate(String habitId) {
    // Example implementation: return null or actual date
    return DateTime.now().subtract(Duration(days: 84));
  }

  int completionsInWeek(String habitId, DateTime weekStart) {
    // Example implementation: count completions during the week
    return 0;
  }
}
