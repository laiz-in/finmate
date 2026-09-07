import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return BottomAppBar(
      color: colors.surface,
      elevation: 0,
      height: 50,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 13,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavIcon(icon: Icons.home_rounded, label: '', index: 0, currentIndex: currentIndex, onTap: onTap, colors: colors),
          _NavIcon(icon: Icons.compare_arrows, label: '', index: 1, currentIndex: currentIndex, onTap: onTap, colors: colors),
          const SizedBox(width: 48), // reserved space for the docked FAB notch
          _NavIcon(icon: Icons.people_alt_rounded, label: '', index: 2, currentIndex: currentIndex, onTap: onTap, colors: colors),
          _NavIcon(icon: Icons.settings, label: '', index: 3, currentIndex: currentIndex, onTap: onTap, colors: colors),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final AppColors colors;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == currentIndex;
    final color = active ? colors.primary : colors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.transparent: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 30),
          //   const SizedBox(height: 3),
          //   AnimatedDefaultTextStyle(
          //     duration: const Duration(milliseconds: 200),
          //     style: AppTextStyles.small(color).copyWith(
          //       fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          //     ),
          //     child: Text(label),
          //   ),
          ],
        ),
      ),
    );
  }
}