import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../bloc/expense_cubit.dart';

const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  final String symbol;
  final Color categoryColor;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.symbol,
    required this.categoryColor,
  });

  String _fullDate(DateTime date) {
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year}';
  }

  Future<void> _confirmDelete(BuildContext context, AppColors colors) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: colors.surface,
            title: Text('Delete expense?', style: AppTextStyles.heading3(colors.textPrimary)),
            content: Text(
              'This will permanently remove this expense.',
              style: AppTextStyles.body(colors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('Cancel', style: AppTextStyles.bodyMedium(colors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('Delete', style: AppTextStyles.bodyMedium(colors.error)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;
    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid == null || !context.mounted) return;
    await context.read<ExpenseCubit>().deleteExpense(uid, expense.id);
    if (context.mounted) {
      Navigator.of(context).pop();
      AppSnackbar.showInfo(context, 'Expense deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Expense details', style: AppTextStyles.heading3(colors.textPrimary)),
        actions: [
          IconButton(
            icon: Icon(Iconsax.trash, color: colors.error, size: 20),
            onPressed: () => _confirmDelete(context, colors),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Iconsax.wallet_1, color: categoryColor, size: 26),
              ),
              const SizedBox(height: 16),
              Text(
                '$symbol${expense.amount.toStringAsFixed(2)}',
                style: AppTextStyles.display(colors.textPrimary),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 24),
              _DetailRow(colors: colors, label: 'Category', value: expense.category),
              _DetailRow(colors: colors, label: 'Date', value: _fullDate(expense.date)),
              if (expense.note.isNotEmpty)
                _DetailRow(colors: colors, label: 'Note', value: expense.note),
              _DetailRow(
                colors: colors,
                label: 'Sync status',
                value: expense.isSynced ? 'Synced' : 'Pending sync',
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
  final String label;
  final String value;
  const _DetailRow({required this.colors, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
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
    );
  }
}