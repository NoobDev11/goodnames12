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
  String? _selectedIconColor;
  IconData? _selectedMarker;

  final List<IconData> _habitIcons = [
    Icons.directions_run,
    Icons.spa_rounded,
    Icons.bolt_rounded,
    Icons.menu_book_rounded,
    Icons.fitness_center_rounded,
    Icons.music_note_rounded,
    Icons.local_drink_rounded,
    Icons.bedtime_rounded,
    Icons.emoji_events_rounded,
    Icons.emoji_emotions_rounded,
    Icons.water_drop_rounded,
    Icons.local_fire_department_rounded,
    Icons.book,
    Icons.lightbulb,
    Icons.device_unknown,
    Icons.account_balance_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.airport_shuttle_rounded,
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
    '#6a4c93',
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
    Icons.swap_horizontal_circle_rounded,
    Icons.close_rounded,
    Icons.circle,
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
    Icons.close_rounded: Colors.amber,
    Icons.circle: Colors.green,
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
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _onAddHabit() {
    if (_formKey.currentState!.validate()) {
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

      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _habitNameController.text.trim(),
        reminderTime: reminderDateTime,
        targetDays: int.tryParse(_targetDays ?? '') ?? 0,
        iconName:
            _selectedIcon?.codePoint.toString() ?? _habitIcons[0].codePoint.toString(),
        iconColorHex: _selectedIconColor ?? _iconColors[0],
        markerIcon: _selectedMarker?.codePoint.toString() ??
            _customMarkers[0].codePoint.toString(),
        markerColorHex: _selectedMarker != null
            ? '#${_markerColors[_selectedMarker!]!.value.toRadixString(16).substring(2)}'
            : '#${_markerColors[_customMarkers[0]]!.value.toRadixString(16).substring(2)}',
      );

      final habitProvider = context.read<HabitProvider>();
      habitProvider.addHabit(newHabit);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit added!')),
      );
      Navigator.pop(context);
    }
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
          tooltip: 'Close Add Habit Screen',
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Semantics(
                label: 'Habit name input field',
                hint: 'Enter the habit name',
                child: TextFormField(
                  controller: _habitNameController,
                  decoration: const InputDecoration(
                    labelText: 'Add Habit Name',
                    hintText: 'e.g. read journal',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Name required' : null,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Reminder time picker',
                      hint: 'Tap to select a daily reminder time',
                      child: InkWell(
                        onTap: _selectReminderTime,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Set Reminder',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.alarm),
                          ),
                          child: Text(_reminderTime == null
                              ? 'Optional'
                              : _reminderTime!.format(context)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      label: 'Target days input',
                      hint: 'Enter target streak days',
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Set Target (days)',
                          hintText: 'e.g. 3 days',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.flag),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) => _targetDays = val,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Choose Icon'),
              const SizedBox(height: 8),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _habitIcons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final icon = _habitIcons[index];
                    final isSelected = _selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedIcon = icon;
                      }),
                      child: CircleAvatar(
                        backgroundColor:
                            isSelected ? Colors.deepPurple : Colors.grey[300],
                        child: Icon(icon,
                            color: isSelected ? Colors.white : Colors.black45),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Select Icon Color'),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _iconColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final hex = _iconColors[index];
                    final isSelected = _selectedIconColor == hex;
                    Color c = _colorFromHex(hex);
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedIconColor = hex;
                      }),
                      child: CircleAvatar(
                        backgroundColor: c,
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Select Custom Marker'),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _customMarkers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final marker = _customMarkers[index];
                    final isSelected = _selectedMarker == marker;
                    Color? markerColor = _markerColors[marker];
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedMarker = marker;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? markerColor : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(marker,
                            color: isSelected ? Colors.white : Colors.black45),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onAddHabit,
                      child: const Text('Add Habit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
