// lib/models/habit.dart
import 'achievement.dart';

class Habit {
  final String id;
  final String name;
  final String iconName;
  final String iconColorHex;
  final String markerIcon;
  final String markerColorHex;
  final DateTime? reminderTime;
  final int targetDays;
  final bool notificationsEnabled;
  final List<Achievement>? achievements;

  Habit({
    required this.id,
    required this.name,
    required this.iconName,
    required this.iconColorHex,
    required this.markerIcon,
    required this.markerColorHex,
    this.reminderTime,
    required this.targetDays,
    this.notificationsEnabled = true,
    this.achievements,
  });

  Habit copyWith({
    String? id,
    String? name,
    String? iconName,
    String? iconColorHex,
    String? markerIcon,
    String? markerColorHex,
    DateTime? reminderTime,
    int? targetDays,
    bool? notificationsEnabled,
    List<Achievement>? achievements,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      iconColorHex: iconColorHex ?? this.iconColorHex,
      markerIcon: markerIcon ?? this.markerIcon,
      markerColorHex: markerColorHex ?? this.markerColorHex,
      reminderTime: reminderTime ?? this.reminderTime,
      targetDays: targetDays ?? this.targetDays,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      achievements: achievements ?? this.achievements,
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final rem = json['reminderTime'];
    DateTime? reminder;
    if (rem != null && rem is String) {
      reminder = DateTime.tryParse(rem);
    }

    List<Achievement>? ach;
    if (json['achievements'] is Iterable) {
      ach = (json['achievements'] as Iterable)
          .map((e) => Achievement.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return Habit(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      iconName: json['iconName']?.toString() ?? '',
      iconColorHex: json['iconColorHex']?.toString() ?? '',
      markerIcon: json['markerIcon']?.toString() ?? '',
      markerColorHex: json['markerColorHex']?.toString() ?? '',
      reminderTime: reminder,
      targetDays: (json['targetDays'] is int)
          ? json['targetDays'] as int
          : int.tryParse(json['targetDays']?.toString() ?? '0') ?? 0,
      notificationsEnabled: json['notificationsEnabled'] == null
          ? true
          : (json['notificationsEnabled'] == true),
      achievements: ach,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'iconColorHex': iconColorHex,
      'markerIcon': markerIcon,
      'markerColorHex': markerColorHex,
      'reminderTime': reminderTime?.toIso8601String(),
      'targetDays': targetDays,
      'notificationsEnabled': notificationsEnabled,
      'achievements': achievements?.map((e) => e.toJson()).toList(),
    };
  }
}
