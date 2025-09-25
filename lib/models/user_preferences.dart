class UserPreferences {
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  UserPreferences({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
  });

  UserPreferences copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return UserPreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}
