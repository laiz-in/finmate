import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavIcon(icon: Icons.home_rounded, label: 'Home', index: 0, currentIndex: currentIndex, onTap: onTap, colors: colors),
            _NavIcon(icon: Icons.receipt_long_rounded, label: 'Money', index: 1, currentIndex: currentIndex, onTap: onTap, colors: colors),
            GestureDetector(
              onTap: onAddTap,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colors.textPrimary, shape: BoxShape.circle),
                child: Icon(Icons.add, color: colors.background),
              ),
            ),
            _NavIcon(icon: Icons.people_alt_rounded, label: 'Circles', index: 2, currentIndex: currentIndex, onTap: onTap, colors: colors),
            _NavIcon(icon: Icons.person_rounded, label: 'You', index: 3, currentIndex: currentIndex, onTap: onTap, colors: colors),
          ],
        ),
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
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.small(color)),
        ],
      ),
    );
  }
}