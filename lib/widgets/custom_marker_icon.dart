import 'package:flutter/material.dart';

class CustomMarkerIcon extends StatelessWidget {
  final Color backgroundColor;
  final IconData icon;
  final double size;

  const CustomMarkerIcon({
    super.key,
    required this.backgroundColor,
    required this.icon,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: size * 0.6),
    );
  }
}
