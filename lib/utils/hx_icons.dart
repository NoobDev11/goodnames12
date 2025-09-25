import 'package:flutter/material.dart';

class HXIcons {
  static const Map<String, IconData> habitIcons = {
    'running': Icons.directions_run,
    'meditation': Icons.self_improvement,
    'reading': Icons.menu_book,
    'exercise': Icons.fitness_center,
    'music': Icons.music_note,
    'drink': Icons.local_drink,
    'sleep': Icons.nights_stay,
    'trophy': Icons.emoji_events,
    'book': Icons.book,
    'other': Icons.more_horiz,
  };

  static IconData getIcon(String key) {
    return habitIcons[key] ?? Icons.help_outline;
  }
}
