import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

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
              Text('Add expense', style: AppTextStyles.heading2(colors.textPrimary)),
              const SizedBox(height: 24),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.heading2(colors.textPrimary),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '$symbol ',
                  prefixStyle: AppTextStyles.heading2(colors.textPrimary),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter an amount';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text('CATEGORY', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
              const SizedBox(height: 10),
              if (categories.isEmpty)
                Text('No categories set up in your profile', style: AppTextStyles.body(colors.textSecondary))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      labelStyle: AppTextStyles.caption(isSelected ? Colors.white : colors.textPrimary),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedCategory = category),
                      backgroundColor: colors.surface,
                      selectedColor: colors.primary,
                      side: BorderSide(color: colors.border),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),

              Text('DATE', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: colors.textSecondary),
                      const SizedBox(width: 10),
                      Text(_formattedDate(_selectedDate), style: AppTextStyles.body(colors.textPrimary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text('NOTE (OPTIONAL)', style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                style: AppTextStyles.body(colors.textPrimary),
                decoration: const InputDecoration(hintText: 'e.g. Lunch with client'),
              ),
              const SizedBox(height: 28),

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
                      : const Text('Save Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}