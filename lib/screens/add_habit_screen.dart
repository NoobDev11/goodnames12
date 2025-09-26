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
  String? _selectedIcon;
  String? _selectedIconColor;
  String? _selectedMarker;

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
    '#ffca3a',
    '#8ac926',
    '#1982c4',
    '#6a4c93',
    '#ff6f91',
  ];

  final List<IconData> _customMarkers = [
    Icons.check,
    Icons.close,
    Icons.circle,
    Icons.arrow_upward,
    Icons.star,
    Icons.diamond,
    Icons.card_giftcard,
    Icons.whatshot,
    Icons.
  ];

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
          now.year, now.month, now.day, _reminderTime!.hour, _reminderTime!.minute);
      }

      final newHabit = Habit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _habitNameController.text.trim(),
        reminderTime: reminderDateTime,
        targetDays: int.tryParse(_targetDays ?? '') ?? 0,
        iconName: _selectedIcon ?? _habitIcons[0],
        iconColorHex: _selectedIconColor ?? _iconColors[0],
        markerIcon: _selectedMarker ?? _customMarkers[0],
        markerColorHex: '#000000', // Provide a default or selectable marker color
      );

      final habitProvider = context.read<HabitProvider>();
      habitProvider.addHabit(newHabit);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Habit added!')),
      );
      Navigator.pop(context);
    }
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
                        child: Icon(Icons.star, // placeholder icon
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
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedMarker = marker;
                      }),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.star, // placeholder icon
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

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
