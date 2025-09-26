import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

// Widget to render the list of habits with proper icons and markers
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  IconData _iconDataFromString(String codePoint) {
    try {
      final intCode = int.parse(codePoint);
      return IconData(intCode, fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final HabitProvider habitProvider = context.watch<HabitProvider>();
    final List<Habit> habits = habitProvider.habits;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final Habit habit = habits[index];
        final IconData iconData = _iconDataFromString(habit.iconName);
        final IconData markerData = _iconDataFromString(habit.markerIcon);
        final Color markerColor = Color(int.parse(habit.markerColorHex.replaceFirst('#', '0xff')));
        final Color iconColor = Color(int.parse(habit.iconColorHex.replaceFirst('#', '0xff')));

        return ListTile(
          title: Text(habit.name),
          leading: CircleAvatar(
            backgroundColor: iconColor,
            child: Icon(iconData, color: Colors.white),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: markerColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(markerData, color: Colors.white, size: 20),
          ),
        );
      },
    );
  }
}

// Rest of screen placeholders

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Calendar Screen Content'));
  }
}

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Stats Screen Content'));
  }
}

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medals'),
        centerTitle: true,
      ),
      body: const Center(child: Text('Medals Screen Content')),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Settings Screen Content'));
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      const HomeTab(),
      const CalendarScreen(),
      const StatsScreen(),
      const AchievementScreen(),
      const SettingsScreen(),
    ];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/addHabit');
        },
        tooltip: 'Add new habit',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Medals'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: _onNavBarTap,
      ),
    );
  }
}
