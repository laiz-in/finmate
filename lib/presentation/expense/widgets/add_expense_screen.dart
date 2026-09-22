import 'package:finmate/core/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/expense_cubit.dart';

class OpenAddExpenseScreen extends StatefulWidget {
  final Expense? existingExpense;

  const OpenAddExpenseScreen({super.key, this.existingExpense});

  bool get isEditing => existingExpense != null;

  @override
  State<OpenAddExpenseScreen> createState() => _OpenAddExpenseScreenState();
}

class _OpenAddExpenseScreenState extends State<OpenAddExpenseScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  final _amountFieldKey = GlobalKey<FormFieldState<String>>();
  final _categoryFieldKey = GlobalKey<FormFieldState<String>>();
  final _noteFieldKey = GlobalKey<FormFieldState<String>>();

  String? _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingExpense;
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _selectedCategory = existing?.category;
    _selectedDate = existing?.date ?? DateTime.now();
  }

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
    final amountValid = _amountFieldKey.currentState?.validate() ?? false;
    final categoryValid = _categoryFieldKey.currentState?.validate() ?? false;
    final noteValid = _noteFieldKey.currentState?.validate() ?? false;

    if (!amountValid || !categoryValid || !noteValid) return;

    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);

    final existing = widget.existingExpense;
    final expense = Expense(
      id: existing?.id ?? const Uuid().v4(),
      uid: uid,
      amount: double.parse(_amountController.text.trim()),
      category: _selectedCategory!,
      note: _noteController.text.trim(),
      date: _selectedDate,
      createdAt: existing?.createdAt ?? DateTime.now(),
      isSynced: false,
    );

    await context.read<ExpenseCubit>().addExpense(expense);

    if (!mounted) return;

    Navigator.of(context).pop(true);
    AppSnackbar.showSuccess(
      context,
      widget.isEditing ? 'Expense has been updated!' : 'Expense has been added!',
    );
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

  Widget _fieldError(AppColors colors, String? errorText) {
    if (errorText == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        errorText,
        style: AppTextStyles.small(colors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profile = context.watch<ProfileCubit>().state.profile;
    final categories = profile?.spendingCategories ?? [];
    final symbol = profile?.currencySymbol ?? '';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Scaffold(
        backgroundColor: colors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.wallet_add_1, color: colors.primary, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          widget.isEditing ? 'Edit expense' : 'Add expense',
                          style: AppTextStyles.heading3(colors.textPrimary),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colors.border),
                        ),
                        child: Icon(Icons.close_rounded, color: colors.textPrimary, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Amount
                FormField<String>(
                  key: _amountFieldKey,
                  initialValue: _amountController.text,
                  validator: (_) {
                    final v = _amountController.text;
                    if (v.trim().isEmpty) return 'Enter an amount';
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    if (parsed > 10000000) return 'Amount cannot exceed 10,000,000';
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: field.hasError ? colors.error : colors.border),
                          ),
                          child: TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppTextStyles.heading3(colors.textPrimary),
                            onChanged: (value) => field.didChange(value),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              prefixText: '$symbol ',
                              prefixStyle: AppTextStyles.heading3(colors.textPrimary),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                            ),
                          ),
                        ),
                        _fieldError(colors, field.errorText),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Category dropdown
                _sectionLabel(colors, 'CATEGORY'),
                const SizedBox(height: 8),
                if (categories.isEmpty)
                  Text('No categories set up in your profile', style: AppTextStyles.caption(colors.textSecondary))
                else
                  FormField<String>(
                    key: _categoryFieldKey,
                    initialValue: _selectedCategory,
                    validator: (_) => _selectedCategory == null ? 'Please select a category' : null,
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: field.hasError ? colors.error : colors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                icon: const SizedBox.shrink(),
                                dropdownColor: colors.surface,
                                borderRadius: BorderRadius.circular(14),
                                style: AppTextStyles.caption(colors.textPrimary),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                value: _selectedCategory,
                                hint: Text('Select a category', style: AppTextStyles.caption(colors.textSecondary)),
                                items: categories.map((category) {
                                  return DropdownMenuItem(
                                    value: category,
                                    child: Text(
                                      category,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedCategory = value);
                                  field.didChange(value);
                                },
                              ),
                            ),
                          ),
                          _fieldError(colors, field.errorText),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 18),

                // Date
                _sectionLabel(colors, 'DATE'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_calendar_sharp, size: 20, color: colors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(_formattedDate(_selectedDate), style: AppTextStyles.caption(colors.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Note
                _sectionLabel(colors, 'NOTE'),
                const SizedBox(height: 8),
                FormField<String>(
                  key: _noteFieldKey,
                  initialValue: _noteController.text,
                  validator: (_) {
                    if (_noteController.text.trim().isEmpty) return 'Please add a short note';
                    return null;
                  },
                  builder: (field) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: field.hasError ? colors.error : colors.border),
                          ),
                          child: TextField(
                            controller: _noteController,
                            style: AppTextStyles.caption(colors.textPrimary),
                            maxLines: 2,
                            onChanged: (value) => field.didChange(value),
                            decoration: InputDecoration(
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              hintText: 'something like a description..',
                              hintStyle: AppTextStyles.caption(colors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                          ),
                        ),
                        _fieldError(colors, field.errorText),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 62,
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
                              Text(widget.isEditing ? 'Update expense' : 'Save expense'),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 29),
                            ],
                          ),
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

/// Opens the add/edit expense sheet. Returns true if the expense was
/// saved (added or updated), false/null if the user cancelled.
Future<bool?> openAddExpenseSheet(BuildContext context, {Expense? existingExpense}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.95,
      child: OpenAddExpenseScreen(existingExpense: existingExpense),
    ),
  );
}