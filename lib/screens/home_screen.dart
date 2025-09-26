import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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
    final habitProvider = context.watch<HabitProvider>();
    final List<Habit> habits = habitProvider.habits;

    Widget bodyContent;
    switch (_selectedIndex) {
      case 0:
        bodyContent = ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            return ListTile(
              title: Text(habit.name),
              leading: CircleAvatar(
                backgroundColor: Color(int.parse(habit.iconColorHex.replaceFirst('#', '0xff'))),
                child: Icon(Icons.star), // Replace with actual icons as needed
              ),
            );
          },
        );
        break;
      case 1:
        bodyContent = const Center(child: Text('Calendar Screen'));
        break;
      case 2:
        bodyContent = const Center(child: Text('Stats Screen'));
        break;
      case 3:
        bodyContent = const Center(child: Text('Achievements Screen'));
        break;
      case 4:
        bodyContent = const Center(child: Text('Settings Screen'));
        break;
      default:
        bodyContent = const Center(child: Text('Unknown Screen'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _animation,
        child: bodyContent,
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
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Achievements'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: _onNavBarTap,
      ),
    );
  }
}
