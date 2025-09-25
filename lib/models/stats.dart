class Stats {
  final String habitId;
  final List<DateTime> completionDates;

  Stats({
    required this.habitId,
    required this.completionDates,
  });

  int getCompletedCount() => completionDates.length;

  bool isCompletedOn(DateTime date) {
    return completionDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }
}
