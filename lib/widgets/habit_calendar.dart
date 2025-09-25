import 'package:flutter/material.dart';

class HabitCalendar extends StatelessWidget {
  final int year;
  final int month;
  final List<int> markedDays;

  const HabitCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.markedDays,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday;

    List<Widget> dayLabels = [
      for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
        Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold))))
    ];

    List<Widget> calendarCells = [];

    int currentDay = 1;
    for (int week = 0; week < 6; week++) {
      List<Widget> weekDays = [];
      for (int weekday = 1; weekday <= 7; weekday++) {
        if ((week == 0 && weekday < firstWeekday) || currentDay > daysInMonth) {
          weekDays.add(const Expanded(child: SizedBox.shrink()));
        } else {
          bool isMarked = markedDays.contains(currentDay);
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
      calendarCells.add(Row(children: weekDays));
    }

    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: dayLabels),
        const SizedBox(height: 8),
        ...calendarCells,
      ],
    );
  }
}
