import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../providers/habit_stats_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _displayedMonth = DateTime.now();
  String? _selectedHabitId;

  @override
  void initState() {
    super.initState();
    final habits = getHabitIds();
    _selectedHabitId = habits.isNotEmpty ? habits.first : null;
  }

  List<String> getHabitIds() {
    final habits = context.read<HabitProvider>().habits;
    return habits.map((h) => h.id).toList();
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final statsProvider = context.watch<HabitStatsProvider>();

    final habits = habitProvider.habits;
    Habit? habit;

    if (habits.isNotEmpty) {
      habit = habits.firstWhere(
        (h) => h.id == _selectedHabitId,
        orElse: () => habits.first,
      );
    } else {
      habit = null;
    }

    int year = _displayedMonth.year;
    int month = _displayedMonth.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;
    int firstWeekday = DateTime(year, month, 1).weekday; // Mon=1 ... Sun=7
    int currentDay = 1;

    List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<Widget> dayHeaders = dayNames
        .map((d) => Expanded(
              child: Center(
                  child: Text(
                d,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
            ))
        .toList();

    List<Row> weeks = [];

    for (int wk = 0; wk < 6; wk++) {
      List<Widget> days = [];
      for (int wd = 1; wd <= 7; wd++) {
        if ((wk == 0 && wd < firstWeekday) || currentDay > daysInMonth) {
          days.add(const Expanded(child: SizedBox.shrink()));
        } else {
          bool done = false;
          if (habit != null) {
            // Check actual completion for this day
            final date = DateTime(year, month, currentDay);
            done = statsProvider.isHabitDone(habit.id, date);
          }

          Widget dayContent = Center(
              child:
                  Text('$currentDay', style: TextStyle(color: done ? Colors.white : Colors.black)));

          if (done && habit != null) {
            final codePoint = int.tryParse(habit.markerIcon);
            final color = Color(int.parse(habit.markerColorHex.replaceFirst('#', 'ff')));
            if (codePoint != null) {
              dayContent = Icon(IconData(codePoint, fontFamily: 'MaterialIcons'),
                  color: color, size: 26);
            }
          }

          days.add(Expanded(
            child: Container(
              margin: const EdgeInsets.all(4),
              height: 40,
              decoration: BoxDecoration(
                  color: done ? Colors.deepPurple : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8)),
              child: dayContent,
            ),
          ));
          currentDay++;
        }
      }
      weeks.add(Row(children: days));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Calendar'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${_displayedMonth.month}/${_displayedMonth.year}',
                      style: const TextStyle(fontSize: 18)),
                ),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right))
              ],
            ),

            const SizedBox(height: 16),

            // Habit selector tabs
            SizedBox(
              height: 50,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: habits.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, index) {
                    Habit habitItem = habits[index];
                    bool selected = habitItem.id == _selectedHabitId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedHabitId = habitItem.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                            color: selected ? Colors.deepPurple : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20)),
                        child: Center(
                            child: Text(
                                habitItem.name[0].toUpperCase() +
                                    habitItem.name.substring(1),
                                style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : Colors.black87))),
                      ),
                    );
                  }),
            ),

            const SizedBox(height: 16),

            // Calendar with week day headers inside a card
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(children: dayHeaders),
                      const SizedBox(height: 8),
                      ...weeks,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
