import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();

    // Here you would obtain stats data for habits - mock example:
    // Replace these with real data sources or computed values
    List<int> progress = _selectedHabitId == 'all'
        ? [5, 3, 7, 2, 6, 1, 4]
        : [1, 2, 3, 1, 0, 0, 1]; // demo

    int currentStreak = 4; // demo
    int longestStreak = 7; // demo

    bool hasEnoughData = progress.isNotEmpty && progress.any((x) => x > 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _habitFilterIds.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  String id = _habitFilterIds[index];
                  bool selected = _selectedHabitId == id;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedHabitId = id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? Colors.deepPurple : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _habitNameById(id),
                          style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          hasEnoughData
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: List.generate(7, (index) {
                                    final val = progress[index];
                                    return Flexible(
                                      child: Container(
                                        height: val * 10.0,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurple,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }),
                                )
                              : const Text('Not enough data', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),

                  if (_selectedHabitId != 'all')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStreakCard('Current Streak', currentStreak),
                        _buildStreakCard('Longest Streak', longestStreak),
                      ],
                    ),

                  if (_selectedHabitId == 'all') 
                    const Padding(
                      padding: EdgeInsets.only(top: 36),
                      child: Text(
                        'Select a habit to see detailed streak data.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(String title, int value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 10),
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
