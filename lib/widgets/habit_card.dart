import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/hx_icons.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool marked;
  final VoidCallback onToggle;

  const HabitCard({
    super.key,
    required this.habit,
    this.marked = false,
    required this.onToggle,
  });

  Color _colorFromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget _buildMarker() {
    if (!marked) return const SizedBox(width: 30, height: 30);
    final color = _colorFromHex(habit.markerColorHex);
    return Icon(Icons.check_circle, color: color, size: 30);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final iconBg = _colorFromHex(habit.iconColorHex);
    return Semantics(
      label:
          '${habit.name} habit card, reminder at ${habit.reminderTime != null ? _formatTime(habit.reminderTime!) : "no reminder set"}, marked as ${marked ? "completed" : "not completed"}',
      button: true,
      child: GestureDetector(
        onTap: onToggle,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child:
                      Icon(HXIcons.getIcon(habit.iconName), size: 28, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (habit.reminderTime != null)
                        Text(
                          _formatTime(habit.reminderTime!),
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                _buildMarker(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
