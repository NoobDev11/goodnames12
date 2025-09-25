import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String label;
  final int points;
  final bool achieved;

  const AchievementCard({
    super.key,
    required this.label,
    required this.points,
    this.achieved = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = achieved ? Colors.deepPurple : Colors.grey.shade300;
    final textColor = achieved ? Colors.white : Colors.black54;
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.stars, color: Colors.white, size: 36),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            Text(
              '$points points',
              style: TextStyle(
                color: textColor.withAlpha((0.7 * 255).toInt()),
                fontSize: 12,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
