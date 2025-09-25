import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../widgets/habit_card.dart';
import '../providers/habit_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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

  void _toggleMark(Habit habit, HabitProvider provider) {
    provider.toggleHabitMarked(habit);
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final habits = habitProvider.habits;
    final habitMarked = habitProvider.habitMarked;

    int unmarked = habitMarked.values.where((m) => !m).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            for (var habit in habits)
              Semantics(
                label:
                    '${habit.name} habit card, marked as ${habitMarked[habit.id] == true ? "completed" : "not completed"}',
                button: true,
                child: HabitCard(
                  habit: habit,
                  marked: habitMarked[habit.id] ?? false,
                  onToggle: () => _toggleMark(habit, habitProvider),
                ),
              ),
            if (unmarked > 0)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 10),
                    Text(
                      'You missed marking $unmarked habit${unmarked > 1 ? 's' : ''}!',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add habit screen or handle adding
        },
        tooltip: 'Add new habit',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Achievements'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          // Handle screen navigation here
        },
      ),
    );
  }
}
