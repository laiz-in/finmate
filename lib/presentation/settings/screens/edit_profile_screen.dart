import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/spending_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/user_profile.dart';
import '../../profile/bloc/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dailyBudgetController;
  late TextEditingController _monthlyBudgetController;
  late Set<String> _selectedCategories;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state.profile!;
    _firstNameController = TextEditingController(text: profile.firstName);
    _lastNameController = TextEditingController(text: profile.lastName);
    _dailyBudgetController = TextEditingController(text: profile.dailyBudget.toStringAsFixed(0));
    _monthlyBudgetController = TextEditingController(text: profile.monthlyBudget.toStringAsFixed(0));
    _selectedCategories = profile.spendingCategories.toSet();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dailyBudgetController.dispose();
    _monthlyBudgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      AppSnackbar.showWarning(context, 'Select at least one spending category');
      return;
    }

    final currentProfile = context.read<ProfileCubit>().state.profile!;
    setState(() => _isSaving = true);

    final updated = UserProfile(
      uid: currentProfile.uid,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: currentProfile.email,
      currencyCode: currentProfile.currencyCode,
      currencySymbol: currentProfile.currencySymbol,
      dailyBudget: double.parse(_dailyBudgetController.text.trim()),
      monthlyBudget: double.parse(_monthlyBudgetController.text.trim()),
      spendingCategories: _selectedCategories.toList(),
    );

    await context.read<ProfileCubit>().saveProfile(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      AppSnackbar.showSuccess(context, 'Profile updated');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final symbol = context.read<ProfileCubit>().state.profile?.currencySymbol ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Edit profile', style: AppTextStyles.heading3(colors.textPrimary)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NAME',
                  style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        style: AppTextStyles.body(colors.textPrimary),
                        decoration: const InputDecoration(hintText: 'First name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        style: AppTextStyles.body(colors.textPrimary),
                        decoration: const InputDecoration(hintText: 'Last name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'BUDGETS',
                  style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dailyBudgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.body(colors.textPrimary),
                        decoration: InputDecoration(hintText: 'Daily', prefixText: '$symbol '),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final parsed = double.tryParse(v.trim());
                          if (parsed == null) return 'Invalid';
                          if (parsed > 10000000) return 'Max 10,000,000';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _monthlyBudgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.body(colors.textPrimary),
                        decoration: InputDecoration(hintText: 'Monthly', prefixText: '$symbol '),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          final parsed = double.tryParse(v.trim());
                          if (parsed == null) return 'Invalid';
                          if (parsed > 10000000) return 'Max 10,000,000';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Text(
                  'SPENDING CATEGORIES',
                  style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kDefaultSpendingCategories.map((category) {
                    final isSelected = _selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      labelStyle: AppTextStyles.caption(isSelected ? Colors.white : colors.textPrimary),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                      backgroundColor: colors.surface,
                      selectedColor: colors.primary,
                      side: BorderSide(color: colors.border),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color.fromARGB(255, 206, 204, 204)),
                          )
                        : const Text('Save changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}