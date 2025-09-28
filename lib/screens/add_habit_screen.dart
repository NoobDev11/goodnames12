import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';  // Removed extra space here
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  TimeOfDay? _reminderTime;
  String? _targetDays;
  IconData? _selectedIcon;
  String? _selectedColor;
  IconData? _selectedMarker;

  final _habitIcons = [
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

  final _iconColors = [
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
    '#645830',
    '#da6278',
    '#f06449',
    '#907ad6',
  ];

  final _customMarkers = [
    Icons.check_circle_rounded,
    Icons.arrow_circle_up_rounded,
    Icons.arrow_circle_down_rounded,
    Icons.build_circle_rounded,
    Icons.pause_circle_filled_rounded,
    Icons.play_circle_filled_rounded,
    Icons.swap_horizontal_circle_rounded,
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

  final _markerColors = {
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
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}'
        '${color.green.toRadixString(16).padLeft(2, '0')}'
        '${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  void _onAddHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final reminderDate = _reminderTime != null
        ? DateTime(now.year, now.month, now.day, _reminderTime!.hour, _reminderTime!.minute)
        : null;

    final markerColor = _markerColors[_selectedMarker ?? _customMarkers.first] ?? Colors.grey;

    final targetValue = int.tryParse(_targetDays ?? '');

    final newHabit = Habit(
      id: now.millisecondsSinceEpoch.toString(),
      name: _habitNameController.text.trim(),
      reminderTime: reminderDate,
      targetDays: (targetValue != null && targetValue > 0) ? targetValue : null,
      iconName: (_selectedIcon ?? _habitIcons.first).codePoint.toString(),
      iconColorHex: _selectedColor ?? _iconColors.first,
      markerIcon: (_selectedMarker ?? _customMarkers.first).codePoint.toString(),
      markerColorHex: _colorToHex(markerColor),
    );

    context.read<HabitProvider>().addHabit(newHabit);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Habit added!')));
    Navigator.of(context).pop();
  }

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close and go back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Add New Habit'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const Text('Add Habit Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _habitNameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.edit),
                          hintText: 'e.g., read journal',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Set Reminder', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: _selectReminderTime,
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.alarm),
                                    ),
                                    child: Text(
                                      _reminderTime?.format(context) ?? 'Optional',
                                      style: TextStyle(
                                        color: _reminderTime == null ? Colors.grey : null,
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
                                const Text('Set Target', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.flag),
                                    hintText: 'e.g., 3 days',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    _targetDays = val;
                                  },
                                  validator: (val) {
                                    if (val == null || val.isEmpty) return null;
                                    final n = int.tryParse(val);
                                    if (n == null || n <= 0) return 'Enter positive number or leave blank';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildIconSelector(),
                      const SizedBox(height: 16),
                      _buildColorSelector(),
                      const SizedBox(height: 16),
                      _buildMarkerSelector(),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          side: BorderSide(color: Colors.deepPurple.shade100),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onAddHabit,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          backgroundColor: Colors.deepPurple.shade300,
                        ),
                        child: const Text(
                          'Add Habit',
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Set Icon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _habitIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[200],
                    child: Icon(icon, color: isSelected ? Colors.white : Colors.deepPurple),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Icon Colour', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _iconColors.map((hex) {
                final isSelected = _selectedColor == hex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = hex),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: _colorFromHex(hex),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkerSelector() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Custom Marker', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _customMarkers.map((marker) {
                final isSelected = _selectedMarker == marker;
                final color = _markerColors[marker] ?? Colors.grey;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMarker = marker),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: isSelected ? color : Colors.grey[200],
                    child: Icon(marker, color: isSelected ? Colors.white : Colors.black54),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 6),
            Text(
              "Your custom marker will show up in all sections instead of default markers. Set a custom target and earn a special medal.",
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitProgress {
  final Habit habit;
  final double percent;
  final int completedDays;

  _HabitProgress({
    required this.habit,
    required this.percent,
    required this.completedDays,
  });
}
