import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../settings/settings_screen.dart';
import '../../shared_widgets/app_bottom_nav.dart';
import 'homescreen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          _PlaceholderTab(colors: colors, label: 'Money'),
          _PlaceholderTab(colors: colors, label: 'Circles'),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onAddTap: () {
          // placeholder — will open "add expense" flow later
        },
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final AppColors colors;
  final String label;
  const _PlaceholderTab({required this.colors, required this.label});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text('$label — coming soon', style: AppTextStyles.body(colors.textSecondary)),
      ),
    );
  }
}