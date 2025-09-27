import 'package:flutter/material.dart';

class FloatingNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  static const _iconData = [
    Icons.home_rounded,
    Icons.calendar_today_rounded,
    Icons.bar_chart_rounded,
    Icons.emoji_events_rounded,
    Icons.settings_rounded,
  ];

  const FloatingNavbar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double barHeight = 62;
    const double indicatorRadius = 27;
    const double barPaddingH = 25;
    const double indicatorOpacity = 0.18;
    final Color purple = const Color(0xFF8857FF); // Design purple
    final Color lightPurple = const Color(0xFF8857FF).withOpacity(indicatorOpacity);

    return IgnorePointer(
      ignoring: false,
      child: SizedBox(
        height: barHeight,
        child: Stack(
          children: [
            // Background and shadow
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: barPaddingH),
                height: barHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(barHeight/2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.11),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
            ),

            // Animated indicator bubble
            AnimatedAlign(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              alignment: Alignment(-1 + 0.5 * currentIndex, 0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: barPaddingH),
                width: indicatorRadius * 2,
                height: indicatorRadius * 2,
                decoration: BoxDecoration(
                  color: lightPurple,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Icons row
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: barPaddingH, vertical: 0),
                height: barHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(_iconData.length, (idx) {
                    bool selected = (currentIndex == idx);
                    return _NavBarIcon(
                      icon: _iconData[idx],
                      selected: selected,
                      onTap: () => onTap(idx),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double iconSize = 28.0;
    final Color purple = const Color(0xFF8857FF);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.ease,
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: iconSize,
          color: selected ? purple : Colors.grey.shade400,
        ),
      ),
    );
  }
}
