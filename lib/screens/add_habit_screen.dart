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
    Icons.fitness_center_rounded,
    Icons.music_note,
    Icons.local_drink,
    Icons.bedtime_rounded,
    Icons.emoji_events,
    Icons.emoji_emotions,
    Icons.water_drop,
    Icons.local_fire_department,
    Icons.book,
    Icons.lightbulb,
    Icons.apple_rounded,
    Icons.account_balance,
    Icons.account_balance_wallet,
    Icons.bookmarks_rounded,
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
    '#6b4a99',
    '#69b578',
    '#ff6f91',
    '#028090',
    '#a44200',
    '#950952',
    '#645830',
    '#da6278',
    '#f06449',
    '#907ad6',
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
    Icons.alternate_email_rounded,
    Icons.amp_stories_rounded,
    Icons.anchor_rounded,
    Icons.assistant_navigation,
    Icons.auto_awesome_rounded,
    Icons.block_rounded,
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
    Icons.alternate_email_rounded: Colors.blue,
    Icons.amp_stories_rounded: Colors.green,
    Icons.anchor_rounded: Colors.brown,
    Icons.assistant_navigation: Colors.blue,
    Icons.auto_awesome_rounded: Colors.blue,
    Icons.block_rounded: Colors.red,
  };

  @override
  void dispose() {
    _habitNameController.dispose();
    super.dispose();
  }

  Future<void> _selectReminderTime() async {
    final picked =
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

    final markerColor = _markerColors[_selectedMarker ?? _customMarkers[0]] ?? Colors.grey;

    final int? targetDaysValue = int.tryParse(_targetDays ?? '');

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _habitNameController.text.trim(),
      reminderTime: reminderDateTime,
      targetDays: targetDaysValue != null && targetDaysValue > 0 ? targetDaysValue : null,
      iconName: (_selectedIcon ?? _habitIcons[0]).codePoint.toString(),
      iconColorHex: _selectedColor ?? _iconColors[0],
      markerIcon: (_selectedMarker ?? _customMarkers[0]).codePoint.toString(),
      markerColorHex: colorToHex(markerColor),
    );

    context.read<HabitProvider>().addHabit(newHabit);

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close this page and go back to Home Screen',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    "Add New Habit",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance the leading
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          "Add Habit Name",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                      TextFormField(
                        controller: _habitNameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.edit),
                          hintText: "e.g. read journal",
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 6.0),
                                  child: Text(
                                    "Set Reminder",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                ),
                                InkWell(
                                  onTap: _selectReminderTime,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.alarm),
                                    ),
                                    child: Text(
                                      _reminderTime != null
                                          ? _reminderTime!.format(context)
                                          : "Optional",
                                      style: TextStyle(
                                        color: _reminderTime != null
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 6.0),
                                  child: Text(
                                    "Set Target",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.flag),
                                    hintText: "e.g. 3 days",
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) => _targetDays = val,
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return null;
                                    final n = int.tryParse(val);
                                    if (n == null || n <= 0) {
                                      return 'Enter a positive number or leave blank';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Set Icon",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 8),
                              GridView.count(
                                crossAxisCount: 6,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _habitIcons
                                    .map((icon) => GestureDetector(
                                          onTap: () =>
                                              setState(() => _selectedIcon = icon),
                                          child: CircleAvatar(
                                            radius: 21,
                                            backgroundColor: _selectedIcon == icon
                                                ? Colors.deepPurple
                                                : Colors.grey[200],
                                            child: Icon(icon,
                                                color: _selectedIcon == icon
                                                    ? Colors.white
                                                    : Colors.deepPurple),
                                          ),
                                        ))
                                    .toList(),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Select Icon Colour",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 8),
                              GridView.count(
                                crossAxisCount: 6,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _iconColors.map((hex) {
                                  final selected = _selectedColor == hex;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedColor = hex),
                                    child: CircleAvatar(
                                      radius: 15,
                                      backgroundColor: _colorFromHex(hex),
                                      child: selected
                                          ? const Icon(Icons.check, color: Colors.white)
                                          : null,
                                    ),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Select Custom Marker",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16)),
                              const SizedBox(height: 8),
                              GridView.count(
                                crossAxisCount: 6,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                children: _customMarkers.map((marker) {
                                  final selected = _selectedMarker == marker;
                                  final color = _markerColors[marker] ?? Colors.grey;
                                  return GestureDetector(
                                    onTap: () => setState(() => _selectedMarker = marker),
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: selected ? color : Colors.grey[200],
                                      child: Icon(marker,
                                          color: selected ? Colors.white : Colors.black54),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Your custom marker will show up in all sections instead of default markers. Set a custom streak target in days and earn a special medal after completion.",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          side: BorderSide(
                            color: Colors.deepPurple.shade100,
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 57,
                      child: ElevatedButton(
                        onPressed: _onAddHabit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          backgroundColor: Colors.deepPurple.shade300,
                        ),
                        child: const Text(
                          "Add Habit",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
