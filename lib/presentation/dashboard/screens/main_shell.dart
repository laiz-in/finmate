import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../expense/widgets/add_expense_sheet.dart';
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

  void _openAddExpense() {
    final colors = Theme.of(context).extension<AppColors>()!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddExpenseSheet(),
    );
  }

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
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpense,
        backgroundColor: colors.primary,
        shape: const CircleBorder(),
        elevation: 2,
        child: Icon(Icons.add, color: colors.background, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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