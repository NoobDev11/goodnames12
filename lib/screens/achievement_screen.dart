import 'package:flutter/material.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  String _selectedHabit = 'Meditation';

  final List<String> _habits = ['Meditation', 'Running', 'Read'];

  final Map<String, List<Map<String, dynamic>>> _achievements = {
    'Meditation': [
      {'days': 3, 'points': 5, 'achieved': true},
      {'days': 7, 'points': 10, 'achieved': true},
      {'days': 15, 'points': 15, 'achieved': false},
      {'days': 30, 'points': 20, 'achieved': false},
      {'days': 60, 'points': 30, 'achieved': false},
      {'days': 90, 'points': 50, 'achieved': false},
      {'days': 180, 'points': 75, 'achieved': false},
      {'days': 365, 'points': 100, 'achieved': false},
      {'days': 9999, 'points': 150, 'achieved': false, 'label': 'Custom'},
    ],
    'Running': [
      {'days': 3, 'points': 5, 'achieved': true},
      {'days': 7, 'points': 10, 'achieved': true},
      {'days': 15, 'points': 15, 'achieved': true},
      {'days': 30, 'points': 20, 'achieved': false},
    ],
    'Read': [
      {'days': 3, 'points': 5, 'achieved': true},
      {'days': 7, 'points': 10, 'achieved': false},
      {'days': 15, 'points': 15, 'achieved': false},
    ],
  };

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get totalPoints {
    final achievementList = _achievements[_selectedHabit];
    if (achievementList == null) return 0;
    return achievementList
        .where((e) => e['achieved'] == true)
        .fold(0, (sum, e) => sum + (e['points'] as int));
  }

  int get medalsEarned {
    return _achievements[_selectedHabit]
            ?.where((e) => e['achieved'] == true)
            .length ??
        0;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> habitAchievements =
        _achievements[_selectedHabit] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text('Total Points'),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.emoji_events,
                          size: 48, color: Colors.orange),
                      Text(
                        '$medalsEarned',
                        style: const TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text('Medals Earned'),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _habits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                String habit = _habits[index];
                bool isSelected = habit == _selectedHabit;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedHabit = habit;
                      _controller.reset();
                      _controller.forward();
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        habit,
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87),
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
                itemCount: habitAchievements.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
                itemBuilder: (ctx, idx) {
                  final achievement = habitAchievements[idx];
                  final isAchieved = achievement['achieved'] ?? false;
                  final days = achievement['days'];
                  final points = achievement['points'];
                  final label = achievement['label'] ?? '$days Days';

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
                          const Icon(Icons.stars, color: Colors.white, size: 36),
                          const SizedBox(height: 6),
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
