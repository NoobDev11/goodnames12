import 'package:flutter/material.dart';

class StatsBarChart extends StatelessWidget {
  final List<int> weeklyData;

  const StatsBarChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weeklyData.map((e) {
        return Flexible(
          child: Container(
            height: e * 10.0,
            width: 20,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }
}
