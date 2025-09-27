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
    return _habits.firstWhere((h) => h.id == id, orElse: () => Habit(
      id: 'all',
      name: 'Unknown',
      iconName: '',
      iconColorHex: '',
      markerIcon: '',
      markerColorHex: ''
    )).name;
  }

  List<FlSpot> _buildLineChartData(HabitStatsProvider habitStats, String habitId) {
    // Compute weekly completions since start
    DateTime today = DateTime.now();
    int weeksToShow = 12;

    DateTime startDate = habitStats.getHabitStartDate(habitId) ?? today.subtract(Duration(days: 7 * weeksToShow));

    List<FlSpot> spots = [];

    for (int i = 0; i < weeksToShow; i++) {
      DateTime weekStart = startDate.add(Duration(days: i * 7));
      int completionCount = habitStats.completionsInWeek(habitId, weekStart);
      spots.add(FlSpot(i.toDouble(), completionCount.toDouble()));
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

      List<int> completedHabitCountByDay = List.generate(7, (i) {
        final day = today.subtract(Duration(days: today.weekday - 1 - i));
        int completedCount = 0;
        for (final h in _habits) {
          if (habitStats.isHabitDone(h.id, day)) completedCount++;
        }
        return completedCount;
      });

      List<_HabitProgress> habitProgressList = _habits.map((h) {
        int daysDone = 0;
        for (int i = 0; i < 7; i++) {
          final day = today.subtract(Duration(days: today.weekday - 1 - i));
          if (habitStats.isHabitDone(h.id, day)) daysDone++;
        }
        double percent = (daysDone / 7) * 100;
        return _HabitProgress(habit: h, percent: percent, completedDays: daysDone);
      }).toList();

      habitProgressList.sort((a,b) => b.percent.compareTo(a.percent));

      return Scaffold(
        appBar: AppBar(title: const Text('Stats - All Habits')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
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
                                  getTitlesWidget: (value, meta) {
                                    const labels = ['M','T','W','T','F','S','S'];
                                    int idx = value.toInt();
                                    if (idx >= 0 && idx < labels.length) {
                                      return Text(labels[idx], style: const TextStyle(fontWeight: FontWeight.bold));
                                    }
                                    return const SizedBox.shrink();
                                  }
                                )
                              ),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(show: true),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(7, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: completedHabitCountByDay[i].toDouble(),
                                    color: Colors.deepPurple,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ]
                              );
                            }),
                          )
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
                        const Text("Habit Weekly Progress", style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            itemCount: habitProgressList.length,
                            itemBuilder: (ctx, i) {
                              final hp = habitProgressList[i];
                              return ListTile(
                                title: Text(hp.habit.name),
                                subtitle: LinearProgressIndicator(
                                  backgroundColor: Colors.grey[300],
                                  value: hp.percent / 100,
                                  color: Colors.deepPurple,
                                ),
                                trailing: Text('${hp.percent.toStringAsFixed(0)}% (${hp.completedDays}/7)'),
                              );
                            }
                          ),
                        )
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
      Habit? habit = habitProvider.getHabitById(_selectedHabitId);
      if (habit == null) {
        return const Scaffold(body: Center(child: Text('Habit not found')));
      }

      final currentStreak = habitStats.currentStreak(_selectedHabitId);
      final longestStreak = habitStats.longestStreak(_selectedHabitId);

      final achievements = habit.achievements ?? [];
      achievements.sort((a,b) => a.days.compareTo(b.days));
      Achievement? nextMilestone = achievements.firstWhere(
        (a) => !a.achieved,
        orElse: () => achievements.isNotEmpty ? achievements.last : null
      );

      int progressToNext = 0;
      double progressPercent = 0;
      if (nextMilestone != null) {
        progressToNext = nextMilestone.days - currentStreak;
        progressPercent = (currentStreak / nextMilestone.days).clamp(0.0, 1.0);
      }

      List<bool> currentWeekCompletion = List.generate(7, (i) {
        final day = today.subtract(Duration(days: today.weekday - 1 - i));
        return habitStats.isHabitDone(_selectedHabitId, day);
      });

      List<Widget> milestoneWidgets = achievements.map((a) {
        double percentDone = (currentStreak / a.days).clamp(0.0, 1.0);
        return ListTile(
          title: Text(a.label ?? '${a.days} Days'),
          subtitle: LinearProgressIndicator(value: percentDone, color: Colors.deepPurple, backgroundColor: Colors.grey[200]),
          trailing: Text('${(percentDone*100).toStringAsFixed(0)}%'),
        );
      }).toList();

      // Generate data for line chart from actual habit completions per week
      List<FlSpot> lineSpots = _buildLineChartData(habitStats, _selectedHabitId);

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
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Milestone: ${nextMilestone?.label ?? 'Completed!'}', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            child: Text(['M','T','W','T','F','S','S'][i]),
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
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Milestone Progress', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      const Text('Overall Progress (weeks)', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 200,
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
                                  }
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 40,
                                ),
                              ),
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

  Widget _buildStreakCard(String title, int value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text(value.toString(), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
