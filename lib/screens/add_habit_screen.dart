import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _habitNameController = TextEditingController();
  TimeOfDay? _reminderTime;
  String? _targetDays;
  IconData? _selectedIcon;
  String? _selectedColor;
  IconData? _selectedMarker;

  final List<IconData> _habitIcons = [
    Icons.directions_run,
    Icons.spa_rounded,
    Icons.bolt_rounded,
    Icons.menu_book_rounded,
    Icons.fitness_center,
    Icons.music_note,
    Icons.local_drink,
    Icons.bedtime,
    Icons.emoji_events,
    Icons.emoji_emotions,
    Icons.water_drop,
    Icons.local_fire_department,
    Icons.book,
    Icons.lightbulb,
    Icons.device_unknown,
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.airport_shuttle,
  ];

  final List<String> _iconColors = [
    '#ff595e',
    '#f15152',
    '#ffca3a',
    '#f2af29',
    '#f18f01',
    '#8ac926',
    '#086375',
    '#1982c4',
    '#6b4a99', // fixed typo from previous e.g. 6b4b99
    '#69b578',
    '#ff6f91',
    '#028090',
    '#a44200',
    '#950952',
  ];

  final List<IconData> _customMarkers = [
    Icons.check_circle_rounded,
    Icons.arrow_circle_up_rounded,
    Icons.arrow_circle_down_rounded,
    Icons.build_circle_rounded,
    Icons.pause_circle_filled_rounded,
    Icons.play_circle_filled_rounded,
    Icons.swap_horizontal_circle_rounded, // corrected icon name here
    Icons.clear_rounded,
    Icons.star_rounded,
    Icons.stars_rounded,
    Icons.diamond_rounded,
    Icons.card_giftcard,
  ];

  final Map<IconData, Color> _markerColors = {
    Icons.check_circle_rounded: Colors.green,
    Icons.arrow_circle_up_rounded: Colors.blue,
    Icons.arrow_circle_down_rounded: Colors.blue,
    Icons.build_circle_rounded: Colors.orange,
    Icons.pause_circle_filled_rounded: Colors.yellow,
    Icons.play_circle_filled_rounded: Colors.green,
    Icons.swap_horizontal_circle_rounded: Colors.teal,
    Icons.clear_rounded: Colors.amber,
    Icons.star_rounded: Colors.teal,
    Icons.stars_rounded: Colors.red,
    Icons.diamond_rounded: Colors.purple,
    Icons.card_giftcard: Colors.orange,
  };

  @override
  void dispose() {
    _habitNameController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  String colorToHex(Color color) {
  final r = (color.r * 255).round() & 0xFF;
  final g = (color.g * 255).round() & 0xFF;
  final b = (color.b * 255).round() & 0xFF;
  return '#'
      '${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}


  void _onAddHabit() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? reminderDateTime;
    if (_reminderTime != null) {
      final now = DateTime.now();
      reminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _reminderTime!.hour,
        _reminderTime!.minute,
      );
    }

    final Color markerColor =
        _markerColors[_selectedMarker ?? _customMarkers[0]] ?? Colors.grey;

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _habitNameController.text.trim(),
      reminderTime: reminderDateTime,
      targetDays: int.tryParse(_targetDays ?? '') ?? 0,
      iconName: (_selectedIcon ?? _habitIcons[0]).codePoint.toString(),
      iconColorHex: _selectedColor ?? _iconColors[0],
      markerIcon: (_selectedMarker ?? _customMarkers[0]).codePoint.toString(),
      markerColorHex: colorToHex(markerColor),
    );

    final habitProvider = context.read<HabitProvider>();
    habitProvider.addHabit(newHabit);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Habit added!')));

    Navigator.of(context).pop();
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Habit'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    const Text(
                      'Habit Name',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _habitNameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter habit name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) =>
                          val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set Target',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Enter target days',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) => _targetDays = val,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set Reminder',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectReminderTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.alarm),
                        ),
                        child: Text(
                          _reminderTime == null
                              ? 'No reminder set'
                              : _reminderTime!.format(context),
                          style: TextStyle(
                              color: _reminderTime == null
                                  ? Colors.grey
                                  : Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select Icon',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18)),
                            const SizedBox(height: 8),
                            GridView.count(
                              crossAxisCount: 6,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: _habitIcons
                                  .map((icon) => GestureDetector(
                                        onTap: () =>
                                            setState(() => _selectedIcon = icon),
                                        child: CircleAvatar(
                                          backgroundColor: _selectedIcon ==
                                                  icon
                                              ? Colors.deepPurple
                                              : Colors.grey[300],
                                          child: Icon(icon,
                                              color: _selectedIcon == icon
                                                  ? Colors.white
                                                  : Colors.black54),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text('Select Color',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18)),
                            const SizedBox(height: 8),
                            GridView.count(
                              crossAxisCount: 6,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: _iconColors
                                  .map((hex) => GestureDetector(
                                        onTap: () =>
                                            setState(() => _selectedColor = hex),
                                        child: CircleAvatar(
                                          backgroundColor:
                                              _colorFromHex(hex),
                                          child: _selectedColor == hex
                                              ? const Icon(Icons.check,
                                                  color: Colors.white)
                                              : null,
                                        ),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            const Text('Select Marker',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18)),
                            const SizedBox(height: 8),
                            GridView.count(
                              crossAxisCount: 6,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              children: _customMarkers
                                  .map((marker) => GestureDetector(
                                        onTap: () => setState(
                                            () => _selectedMarker = marker),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color:
                                                _selectedMarker == marker
                                                    ? _markerColors[
                                                        marker] ?? Colors.grey
                                                    : Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(marker,
                                              color: _selectedMarker == marker
                                                  ? Colors.white
                                                  : Colors.black54),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _onAddHabit,
                      child: const Text('Add Habit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
