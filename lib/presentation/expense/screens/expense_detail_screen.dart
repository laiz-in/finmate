import 'package:finmate/presentation/shared_widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';

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
    final confirmed = await showConfirmationDialog(
      context: context,
      colors: colors,
      title: 'Delete expense?',
      message: 'This will permanently remove this expense.',
      confirmLabel: 'Delete',
    );

    if (!confirmed) return;
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