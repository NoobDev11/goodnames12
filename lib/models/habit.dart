class Habit {
  final String id;
  final String name;
  final String iconName; // Identifier for habit icon
  final String iconColorHex;
  final String markerIcon; // Custom marker icon name
  final String markerColorHex;
  final DateTime? reminderTime;
  final int? targetDays; // optional target streak
  final bool notificationsEnabled;

  Habit({
    required this.id,
    required this.name,
    required this.iconName,
    required this.iconColorHex,
    required this.markerIcon,
    required this.markerColorHex,
    this.reminderTime,
    this.targetDays,
    this.notificationsEnabled = true,
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
    );
  }

  // ----- ADD THESE FOR STORAGE -----
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      iconColorHex: json['iconColorHex'] as String,
      markerIcon: json['markerIcon'] as String,
      markerColorHex: json['markerColorHex'] as String,
      reminderTime: json['reminderTime'] != null
          ? DateTime.tryParse(json['reminderTime'] as String)
          : null,
      targetDays: json['targetDays'] != null ? json['targetDays'] as int : null,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
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
    };
  }
}
