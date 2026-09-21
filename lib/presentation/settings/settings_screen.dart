import 'package:finmate/presentation/auth/bloc/auth_bloc.dart';
import 'package:finmate/presentation/auth/bloc/auth_event.dart';
import 'package:finmate/presentation/expense/bloc/expense_cubit.dart';
import 'package:finmate/presentation/liabilities/bloc/lent_cubit.dart';
import 'package:finmate/presentation/liabilities/bloc/owe_cubit.dart';
import 'package:finmate/presentation/profile/bloc/profile_cubit.dart';
import 'package:finmate/presentation/settings/screens/change_email_screen.dart';
import 'package:finmate/presentation/settings/screens/change_password_screen.dart';
import 'package:finmate/presentation/settings/screens/edit_profile_screen.dart';
import 'package:finmate/presentation/settings/widgets/delete_account_dialog.dart';
import 'package:finmate/presentation/settings/widgets/sign_out_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/repositories/auth_repository.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeleting = false;

  Future<void> _handleSignOut(BuildContext context, AppColors colors) async {
    final confirmed = await showSignOutDialog(context, colors);
    if (!confirmed) return;
    if (!context.mounted) return;
    context.read<ProfileCubit>().clearOnSignOut();
    context.read<ExpenseCubit>().clearOnSignOut();
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }

  Future<void> _handleDeleteAccount(BuildContext context, AppColors colors) async {
    final password = await showDeleteAccountDialog(context, colors);
    if (password == null) return;
    if (!context.mounted) return;

    setState(() => _isDeleting = true);
    final error = await getIt<AuthRepository>().deleteAccount(password);
    if (!context.mounted) return;
    setState(() => _isDeleting = false);

    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }
    context.read<OweCubit>().clearOnSignOut();
    context.read<LentCubit>().clearOnSignOut();
    context.read<ProfileCubit>().clearOnSignOut();
    context.read<ExpenseCubit>().clearOnSignOut();
    context.read<AuthBloc>().add(const AuthSignOutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profileState = context.watch<ProfileCubit>().state;
    final name = profileState.profile?.fullName ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text('hello', style: AppTextStyles.heading2(colors.textSecondary.withValues(alpha: 0.7))),
                if (name.isNotEmpty)
                  Transform.translate(
                    offset: const Offset(0, -8),
                    child: Text(name, style: AppTextStyles.heading2(colors.textSecondary)),
                  ),
                const SizedBox(height: 28),


                // Text('PROFILE', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text('Edit profile', style: AppTextStyles.body(colors.textSecondary)),
                        trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                      Divider(color: colors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text('Reset email', style: AppTextStyles.body(colors.textSecondary)),
                        trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChangeEmailScreen()),
                          );
                        },
                      ),
                      Divider(color: colors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: Text('Reset password', style: AppTextStyles.body(colors.textSecondary)),
                        trailing: Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

 


                // Text('ACCOUNT', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
                // const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Icon(Icons.logout_rounded, color: colors.error),
                        title: Text('Sign out', style: AppTextStyles.body(colors.error)),
                        onTap: () => _handleSignOut(context, colors),
                      ),
                      Divider(color: colors.border, height: 1),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Icon(Icons.delete_forever_rounded, color: colors.error),
                        title: Text('Delete account', style: AppTextStyles.body(colors.error)),
                        onTap: () => _handleDeleteAccount(context, colors),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),


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


              ],
            ),
            if (_isDeleting)
              Container(
                color: colors.background.withValues(alpha: 0.7),
                child: Center(child: CircularProgressIndicator(color: colors.primary)),
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