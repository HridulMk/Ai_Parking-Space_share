import 'dart:ui';

import 'package:flutter/material.dart';

class AppFloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const AppFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final compact = width < 380;
            final iconSize = compact ? 20.0 : 22.0;
            final labelSize = compact ? 10.0 : 11.0;

            return SizedBox(
              height: 86,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Subtle floating glow only, no solid rectangular background.
                  Positioned(
                    left: 8,
                    right: 8,
                    bottom: 8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          height: 66,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.18)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _NavButton(
                                  icon: Icons.book_online_outlined,
                                  label: 'My Booking',
                                  selected: selectedIndex == 0,
                                  iconSize: iconSize,
                                  labelSize: labelSize,
                                  onTap: () => onTap(0),
                                ),
                              ),
                              Expanded(
                                child: _NavButton(
                                  icon: Icons.dashboard_outlined,
                                  label: 'Dashboard',
                                  selected: selectedIndex == 1,
                                  iconSize: iconSize,
                                  labelSize: labelSize,
                                  onTap: () => onTap(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: compact ? 72 : 84),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: _NavButton(
                                  icon: Icons.local_parking_outlined,
                                  label: 'Parking',
                                  selected: selectedIndex == 3,
                                  iconSize: iconSize,
                                  labelSize: labelSize,
                                  onTap: () => onTap(3),
                                ),
                              ),
                              Expanded(
                                child: _NavButton(
                                  icon: Icons.person_outline,
                                  label: 'Profile',
                                  selected: selectedIndex == 4,
                                  iconSize: iconSize,
                                  labelSize: labelSize,
                                  onTap: () => onTap(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -2,
                    child: Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(44),
                        onTap: () => onTap(2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: compact ? 78 : 86,
                          height: compact ? 78 : 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedIndex == 2
                                ? const Color(0xFFCAE6EA)
                                : const Color(0xFFF6F8FA),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x22000000),
                                  blurRadius: 14,
                                  offset: Offset(0, 8)),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                size: compact ? 24 : 26,
                                color: selectedIndex == 2
                                    ? const Color(0xFF0EA5A4)
                                    : const Color(0xFF222A35),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Home',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selectedIndex == 2
                                      ? const Color(0xFF0EA5A4)
                                      : const Color(0xFF222A35),
                                  fontSize: labelSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double iconSize;
  final double labelSize;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.iconSize,
    required this.labelSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF0EA5A4) : const Color(0xFF222A35);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: labelSize,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
