import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

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

  // Change month
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
    final habits = habitProvider.habits;
    final habit = habits.firstWhere((h) => h.id == _selectedHabitId, orElse: () => habits.isNotEmpty ? habits[0] : null);

    // Collect all done days for selected habit (assuming you keep record somewhere)
    // Here we're assuming isHabitCompletedToday maps for days and you track habit done per date elsewhere,
    // This is a stub with no real dates, you'd need an actual date tracking model.
    Map<int, bool> doneDays = {}; // Example: {1:true, 5:true,...}

    // Build calendar grid
    int year = _displayedMonth.year;
    int month = _displayedMonth.month;
    int daysInMonth = DateTime(year, month + 1, 0).day;

    // Helper to get weekday for first day (1=Monday,..7=Sunday)
    final firstWeekDay = DateTime(year, month, 1).weekday;
    int currentDay = 1;

    List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    List<Widget> dayWidgets = [];

    // Day name headers
    dayWidgets.add(
      Row(
        children: dayNames
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ))
            .toList(),
      ),
    );

    List<Row> calendarRows = [];

    for (int week = 0; week < 6; week++) {
      List<Widget> weekDays = [];
      for (int wd = 1; wd <= 7; wd++) {
        if ((week == 0 && wd < firstWeekDay) || currentDay > daysInMonth) {
          weekDays.add(const Expanded(child: SizedBox())); // Empty space
        } else {
          bool done = false;
          if (habit != null && habitProvider.isHabitCompletedToday(habit.id)) {
            // For demonstration; replace with actual date-based done lookup
            done = doneDays[currentDay] ?? false;
          }

          Widget dayWidget = Center(child: Text(currentDay.toString(), style: TextStyle(color: done ? Colors.white : Colors.black)));

          if (done && habit != null) {
            // Render marker icon on day with custom color applied to icon
            final markerIconCode = int.tryParse(habit.markerIcon);
            if (markerIconCode != null) {
              dayWidget = Icon(IconData(markerIconCode, fontFamily: 'MaterialIcons'),
                  color: Color(int.parse(habit.markerColorHex.replaceFirst('#', '0xff'))), size: 26);
            }
          }

          weekDays.add(
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: done ? Colors.deepPurple : Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                height: 40,
                child: dayWidget,
              ),
            ),
          );
          currentDay++;
        }
      }
      calendarRows.add(Row(children: weekDays));
    }

    dayWidgets.add(const SizedBox(height: 8));
    dayWidgets.addAll(calendarRows);

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Calendar'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Month switcher pill
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                  child: Text('${_displayedMonth.month}/${_displayedMonth.year}', style: const TextStyle(fontSize: 18)),
                ),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),

            const SizedBox(height: 16),

            // Habit tabs for filtering
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: habits.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final h = habits[index];
                  bool selected = h.id == _selectedHabitId;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedHabitId = h.id;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? Colors.deepPurple : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                          child: Text(
                            h.name[0].toUpperCase() + h.name.substring(1),
                            style: TextStyle(color: selected ? Colors.white : Colors.black87),
                          )),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Calendar inside a card
            Expanded(
              child: Card(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: dayWidgets),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
