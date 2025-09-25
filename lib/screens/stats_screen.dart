import 'package:flutter/material.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedHabit = 'All Habits';

  final List<String> _habits = ['All Habits', 'Meditation', 'Running', 'Read'];

  // Dummy data for progress - should ideally come from a stats service
  final Map<String, List<int>> _weeklyProgress = {
    'All Habits': [5, 3, 7, 2, 6, 1, 4],
    'Meditation': [1, 2, 3, 1, 0, 0, 1],
    'Running': [0, 1, 2, 3, 4, 2, 1],
    'Read': [4, 0, 1, 2, 2, 0, 2],
  };

  final Map<String, int> _currentStreak = {
    'Meditation': 4,
    'Running': 10,
    'Read': 3,
  };

  final Map<String, int> _longestStreak = {
    'Meditation': 7,
    'Running': 12,
    'Read': 5,
  };

  @override
  Widget build(BuildContext context) {
    List<int> progress = _weeklyProgress[_selectedHabit] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stats'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Habit Filters - Tabs/Pills
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _habits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final habit = _habits[index];
                  final isSelected = habit == _selectedHabit;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedHabit = habit;
                      });
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.deepPurple : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          habit,
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
            const SizedBox(height: 24),

            // Weekly Progress Bar Graph
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weekly Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('+40%', style: TextStyle(fontSize: 16, color: Colors.green.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final val = progress.isNotEmpty ? progress[index] : 0;
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
            ),
            const SizedBox(height: 18),

            // Current and Longest Streak
            if (_selectedHabit != 'All Habits')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStreakCard('Current Streak', _currentStreak[_selectedHabit] ?? 0),
                  _buildStreakCard('Longest Streak', _longestStreak[_selectedHabit] ?? 0),
                ],
              ),

            if (_selectedHabit == 'All Habits') ...[
              const SizedBox(height: 36),
              const Text(
                'Select a habit to see detailed streak data.',
                style: TextStyle(color: Colors.grey),
              )
            ],
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
