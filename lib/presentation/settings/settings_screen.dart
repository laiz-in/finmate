import 'package:finmate/presentation/profile/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_cubit.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profileState = context.watch<ProfileCubit>().state;
    final name = profileState.profile?.fullName ?? '';
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text('You', style: AppTextStyles.heading1(colors.textPrimary)),
            const SizedBox(height: 4),
            if (name.isNotEmpty)
              Text(name, style: AppTextStyles.body(colors.textSecondary)),
            const SizedBox(height: 28),

            Text('APPEARANCE', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: const _ThemeSelector(),
            ),
            const SizedBox(height: 28),

            Text('ACCOUNT', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                leading: Icon(Icons.logout_rounded, color: colors.error),
                title: Text('Sign out', style: AppTextStyles.bodyMedium(colors.error)),
                onTap: () => context.read<AuthBloc>().add(const AuthSignOutRequested()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final currentMode = context.watch<ThemeCubit>().state;

    final options = [
      (ThemeMode.light, Icons.light_mode_rounded, 'Light'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Dark'),
      (ThemeMode.system, Icons.settings_suggest_rounded, 'System'),
    ];

    return Row(
      children: options.map((option) {
        final (mode, icon, label) = option;
        final isSelected = currentMode == mode;

        return Expanded(
          child: GestureDetector(
            onTap: () => context.read<ThemeCubit>().setTheme(mode),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? colors.primary : colors.border),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 20, color: isSelected ? Colors.white : colors.textSecondary),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: AppTextStyles.caption(isSelected ? Colors.white : colors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}