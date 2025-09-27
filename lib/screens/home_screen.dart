import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

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

  String? _formatTime(DateTime? dateTime) {
    if (dateTime == null) return null;
    var hour = dateTime.hour;
    var minute = dateTime.minute.toString().padLeft(2, '0');
    var suffix = "AM";
    if (hour >= 12) {
      suffix = "PM";
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;
    return '$hour:$minute $suffix';
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final List<Habit> habits = habitProvider.habits;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final Habit habit = habits[index];
        final IconData iconData = _iconDataFromString(habit.iconName);
        final IconData markerData = _iconDataFromString(habit.markerIcon);
        final Color markerColor = _colorFromHex(habit.markerColorHex);
        final Color iconColor = _colorFromHex(habit.iconColorHex);

        final bool isDone = habit.isCompletedToday ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 7),
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: iconColor,
              child: Icon(iconData, color: Colors.white),
            ),
            title: Text(
              habit.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            subtitle: habit.reminderTime != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.alarm, size: 16, color: Colors.deepPurple),
                      const SizedBox(width: 4),
                      Text(_formatTime(habit.reminderTime)!,
                          style: const TextStyle(color: Colors.deepPurple)),
                    ],
                  )
                : null,
            trailing: GestureDetector(
              onTap: () {
                habitProvider.toggleHabitCompleted(habit.id);
              },
              child: isDone
                  ? Container(
                      decoration: BoxDecoration(
                        color: markerColor,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      padding: const EdgeInsets.all(7),
                      child: Icon(markerData, color: Colors.white, size: 24),
                    )
                  : Icon(Icons.radio_button_unchecked, color: Colors.grey, size: 24),
            ),
          ),
        );
      },
    );
  }
}

// Actual calendar widget page
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Center(child: Text('Your full calendar UI goes here.')),
    );
  }
}

// Actual stats widget page
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Center(child: Text('Your stats and graphs go here.')),
    );
  }
}

// Real achievements page widget
class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: Center(child: Text('Show badges and completed goals here.')),
    );
  }
}

// Real settings page widget
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(child: Text('Settings UI here.')),
    );
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
