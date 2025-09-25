import 'package:flutter/material.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _displayedMonth = DateTime.now();
  String _selectedHabitId = 'running';

  final List<String> _habits = ['running', 'meditation', 'read'];

  // Simulating calendar markings for habits by date
  final Map<String, List<int>> _habitMarkedDays = {
    'running': [1, 5, 8, 10, 15],
    'meditation': [3, 7, 9, 21],
    'read': [2, 4, 6, 11],
  };

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

  List<Widget> _buildCalendar() {
    int year = _displayedMonth.year;
    int month = _displayedMonth.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    List<Widget> dayWidgets = [];

    // Day names row
    List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    dayWidgets.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: dayNames
          .map((d) => Expanded(
                  child: Center(
                child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
              )))
          .toList(),
    ));

    // Start weekday of the month (1-Monday ... 7-Sunday)
    int firstWeekDay = DateTime(year, month, 1).weekday;
    int currentDay = 1;

    List<Row> calendarRows = [];

    // Build weeks (max 6 weeks)
    for (int week = 0; week < 6; week++) {
      List<Widget> weekDays = [];

      for (int wd = 1; wd <= 7; wd++) {
        if ((week == 0 && wd < firstWeekDay) || currentDay > daysInMonth) {
          // Empty slots before first day and after last day
          weekDays.add(Expanded(child: Container()));
        } else {
          bool isMarked = _habitMarkedDays[_selectedHabitId]?.contains(currentDay) ?? false;
          weekDays.add(
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isMarked ? Colors.deepPurple : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                height: 40,
                child: Center(
                  child: Text(
                    currentDay.toString(),
                    style: TextStyle(
                      color: isMarked ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
          currentDay++;
        }
      }
      calendarRows.add(Row(children: weekDays));
    }

    return [
      ...dayWidgets,
      const SizedBox(height: 8),
      ...calendarRows,
    ];
  }

  @override
  Widget build(BuildContext context) {
    String monthYearLabel = "${_displayedMonth.month}/${_displayedMonth.year}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Calendar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Month navigation
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Text(monthYearLabel, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),
          // Habit filter tabs
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _habits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                String habit = _habits[index];
                bool isSelected = habit == _selectedHabitId;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedHabitId = habit;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        habit[0].toUpperCase() + habit.substring(1),
                        style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: _buildCalendar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
