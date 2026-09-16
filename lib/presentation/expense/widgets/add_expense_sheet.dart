import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/category_icons.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/expense_cubit.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final expense = Expense(
      id: const Uuid().v4(),
      uid: uid,
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory!,
      note: _noteController.text.trim(),
      date: _selectedDate,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    await context.read<ExpenseCubit>().addExpense(expense);

    if (mounted) Navigator.of(context).pop();
  }

  String _formattedDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _sectionLabel(AppColors colors, String text) {
    return Row(
      children: [
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profile = context.watch<ProfileCubit>().state.profile;
    final categories = profile?.spendingCategories ?? [];
    final symbol = profile?.currencySymbol ?? '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Iconsax.wallet_add_1, color: colors.primary, size: 28),
                  const SizedBox(width: 10),
                  Text('Add expense', style: AppTextStyles.heading3(colors.textPrimary)),
                ],
              ),
              const SizedBox(height: 20),

              // Amount
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: AppTextStyles.heading3(colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    prefixText: '$symbol ',
                    prefixStyle: AppTextStyles.heading3(colors.textPrimary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter an amount';
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    if (parsed > 10000000) return 'Amount cannot exceed 10,000,000';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 22),

              // Category dropdown
              _sectionLabel(colors,'CATEGORY'),
              const SizedBox(height: 10),
              if (categories.isEmpty)
                Text('No categories set up in your profile', style: AppTextStyles.body(colors.textSecondary))
              else
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(Iconsax.arrow_down_1, size: 18, color: colors.textSecondary),
                    dropdownColor: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    style: AppTextStyles.body(colors.textPrimary),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),

                    ),
                    hint: Text('Select a category', style: AppTextStyles.body(colors.textSecondary)),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(getCategoryIcon(category), size: 16, color: colors.primary),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                category,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                ),
              const SizedBox(height: 22),

              // Date
              _sectionLabel(colors, 'DATE'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.calendar_1, size: 16, color: colors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_formattedDate(_selectedDate), style: AppTextStyles.body(colors.textPrimary)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Note
              _sectionLabel(colors,'NOTE'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: TextFormField(
                  controller: _noteController,
                  style: AppTextStyles.caption(colors.textPrimary),
                  decoration: InputDecoration(
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    hintText: 'e.g. Bought sweets',
                    hintStyle: AppTextStyles.caption(colors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please add a short note';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            const Text('Save Expense'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}