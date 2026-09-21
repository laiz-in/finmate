import 'package:finmate/presentation/expense/widgets/add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/category_icons.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../shared_widgets/confirmation_dialog.dart';
import '../bloc/expense_cubit.dart';

const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
const _monthsShort = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
];
const _weekdaysFull = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];

class ExpenseDetailScreen extends StatefulWidget {
  final Expense expense;
  final String symbol;
  final Color categoryColor;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.symbol,
    required this.categoryColor,
  });

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  late Expense _expense;

  @override
  void initState() {
    super.initState();
    _expense = widget.expense;
  }

  String _fullDate(DateTime date) {
    final weekday = _weekdaysFull[date.weekday - 1];
    final month = _monthsShort[date.month - 1];
    return '$weekday, ${date.day} $month ${date.year}';
  }

  String _formattedTime(DateTime date) {
    final hour24 = date.hour;
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour24 < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $period';
  }

  Future<void> _edit(BuildContext context) async {
    final result = await openAddExpenseSheet(context, existingExpense: _expense);
    if (result != true) return;
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(BuildContext context, AppColors colors) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      colors: colors,
      title: 'Delete expense?',
      message: 'This will permanently remove this expense.',
      confirmLabel: 'Delete',
    );

    if (!confirmed) return;
    if (!context.mounted) return;

    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid == null) return;

    await context.read<ExpenseCubit>().deleteExpense(uid, _expense.id);

    if (!context.mounted) return;
    Navigator.of(context).pop();
    AppSnackbar.showError(context, 'Expense deleted');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final symbol = widget.symbol;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Expense details', style: AppTextStyles.heading3(colors.textPrimary)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(0, 20, 20, 20),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(getCategoryIcon(_expense.category), color: colors.primary, size: 45),
                        ),
                        const SizedBox(width: 14),
                        Flexible(
                          child: Text(
                            '$symbol${_expense.amount.toStringAsFixed(2)}',
                            style: AppTextStyles.display(colors.primary),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _expense.category,
                      style: AppTextStyles.bodyMedium(colors.textSecondary.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ON',
                                style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.6),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _fullDate(_expense.date),
                                style: AppTextStyles.bodyMedium(colors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'at ${_formattedTime(_expense.createdAt)}',
                                style: AppTextStyles.caption(colors.textSecondary.withValues(alpha: 0.7)),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_expense.note.isNotEmpty) ...[
                      Divider(color: colors.border, height: 28),
                      _DetailRow(colors: colors, icon: Iconsax.note_text, label: 'Note', value: _expense.note),
                    ],
                    Divider(color: colors.border, height: 28),
                    Row(
                      children: [
                        Icon(
                          _expense.isSynced ? Iconsax.tick_circle : Iconsax.clock,
                          size: 18,
                          color: _expense.isSynced ? colors.primary : colors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _expense.isSynced ? 'Synced' : 'Pending sync',
                          style: AppTextStyles.bodyMedium(
                            _expense.isSynced ? colors.primary : colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _edit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surface,
                          foregroundColor: colors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: colors.border),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.edit_2, color: colors.textSecondary, size: 18),
                            const SizedBox(width: 8),
                            Text('Edit', style: AppTextStyles.bodyMedium(colors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _confirmDelete(context, colors),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.error.withValues(alpha: 0.15),
                          foregroundColor: colors.error,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.trash, color: colors.error, size: 18),
                            const SizedBox(width: 8),
                            Text('Delete', style: AppTextStyles.bodyMedium(colors.error)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({
    required this.colors,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.6),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium(colors.textPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}