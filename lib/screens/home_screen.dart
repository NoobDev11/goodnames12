import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';
import '../widgets/floating_navbar.dart';

// Import your actual screen pages here
import '../screens/calendar_screen.dart';
import '../screens/stats_screen.dart';
import '../screens/achievement_screen.dart';
import '../screens/settings_screen.dart';

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

  String? _formatTime(DateTime? dt) {
    if (dt == null) return null;
    int hour = dt.hour;
    String minute = dt.minute.toString().padLeft(2, '0');
    String suffix = 'AM';
    if (hour >= 12) {
      suffix = 'PM';
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
        final habit = habits[index];
        final iconData = _iconDataFromString(habit.iconName);
        final markerData = _iconDataFromString(habit.markerIcon);
        final iconColor = _colorFromHex(habit.iconColorHex);
        final markerColor = _colorFromHex(habit.markerColorHex);
        final bool isDone = habitProvider.isHabitCompletedToday(habit.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 7),
          elevation: 4,
          child: SizedBox(
            height: 80,  // Fixed height for all habit cards
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
                    ? Icon(
                        markerData,
                        color: markerColor,
                        size: 28,  // slightly bigger for better visibility
                      )
                    : const Icon(Icons.radio_button_unchecked,
                        color: Colors.grey, size: 28),
              ),
            ),
          ),
        );
      },
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
  late final List<Widget> _screens;

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

  void _onTabTapped(int index) {
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
      body: Stack(
        children: [
          FadeTransition(
            opacity: _animation,
            child: _screens[_selectedIndex],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 15,
            child: FloatingNavbar(
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/addHabit'),
        tooltip: 'Add new habit',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
