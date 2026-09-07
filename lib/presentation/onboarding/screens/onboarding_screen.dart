import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/currencies.dart';
import '../../../core/constants/spending_categories.dart';
import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/bloc/profile_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dailyBudgetController = TextEditingController();
  final _monthlyBudgetController = TextEditingController();

  late CurrencyOption _selectedCurrency;
  final Set<String> _selectedCategories = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = detectDefaultCurrency();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dailyBudgetController.dispose();
    _monthlyBudgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one spending category')),
      );
      return;
    }

    final authRepo = getIt<AuthRepository>();
    final uid = authRepo.currentUser?.uid;
    final email = authRepo.currentUser?.email;
    if (uid == null || email == null) return;

    setState(() => _isSaving = true);
    final profile = UserProfile(
      uid: uid,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: email,
      currencyCode: _selectedCurrency.code,
      currencySymbol: _selectedCurrency.symbol,
      dailyBudget: double.tryParse(_dailyBudgetController.text.trim()) ?? 0,
      monthlyBudget: double.tryParse(_monthlyBudgetController.text.trim()) ?? 0,
      spendingCategories: _selectedCategories.toList(),
    );
    await context.read<ProfileCubit>().saveProfile(profile);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final email = getIt<AuthRepository>().currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                      Text.rich(
                        TextSpan(
                          style: AppTextStyles.heading2(colors.textPrimary),
                          children: [
                            TextSpan(
                              text: 'Set up your ',
                              style: TextStyle(color: colors.textPrimary.withValues(alpha: 0.5)),
                            ),
                            const TextSpan(text: 'finmate'),
                          ],
                        ),
                      ),
                    ],
                  ),                const SizedBox(height: 8),
                const SizedBox(height: 32),

                _SectionLabel('YOUR NAME', colors),
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

                _SectionLabel('EMAIL', colors),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(email, style: AppTextStyles.body(colors.textSecondary)),
                ),
                const SizedBox(height: 24),

                _SectionLabel('CURRENCY', colors),
                const SizedBox(height: 10),
                DropdownButtonFormField<CurrencyOption>(
                  value: _selectedCurrency,
                  dropdownColor: colors.surface,
                  style: AppTextStyles.body(colors.textPrimary),
                  items: kCurrencies.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text('${c.code} — ${c.name} (${c.symbol})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedCurrency = value);
                  },
                ),
                const SizedBox(height: 24),

                _SectionLabel('BUDGETS', colors),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dailyBudgetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: AppTextStyles.body(colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Daily',
                          prefixText: '${_selectedCurrency.symbol} ',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null) return 'Invalid';
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
                        decoration: InputDecoration(
                          hintText: 'Monthly',
                          prefixText: '${_selectedCurrency.symbol} ',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (double.tryParse(v.trim()) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SectionLabel('SPENDING CATEGORIES', colors),
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
                const SizedBox(height: 36),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Continue'),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final AppColors colors;
  const _SectionLabel(this.text, this.colors);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8));
  }
}