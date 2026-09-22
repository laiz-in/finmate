import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/lent.dart';
import '../../../data/models/owe.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../../shared_widgets/confirmation_dialog.dart';
import '../bloc/lent_cubit.dart';
import '../bloc/owe_cubit.dart';
import 'add_lent_screen.dart';
import 'add_owe_screen.dart';

class LiabilityScreen extends StatefulWidget {
  const LiabilityScreen({super.key});

  @override
  State<LiabilityScreen> createState() => _LiabilityScreenState();
}

class _LiabilityScreenState extends State<LiabilityScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid != null) {
      context.read<OweCubit>().load(uid);
      context.read<LentCubit>().load(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final symbol = context.watch<ProfileCubit>().state.profile?.currencySymbol ?? '';
    final oweState = context.watch<OweCubit>().state;
    final lentState = context.watch<LentCubit>().state;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Liabilities', style: AppTextStyles.heading3(colors.textPrimary)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 0 ? colors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                
                                Text(
                                  'OWE',
                                  style: AppTextStyles.caption(_tabIndex == 0 ? Colors.white : colors.textSecondary,
                                  ).copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_outward,
                                  size: 20,
                                  color: _tabIndex == 0 ? Colors.white : colors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _tabIndex == 1 ? colors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'LENT',
                                  style: AppTextStyles.bodyMedium(_tabIndex == 1 ? Colors.white : colors.textSecondary).copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_downward,
                                  size: 20,
                                  color: _tabIndex == 1 ? Colors.white : colors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _OweList(colors: colors, symbol: symbol, owes: oweState.owes),
                  _LentList(colors: colors, symbol: symbol, lents: lentState.lents),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: _tabIndex == 0 ? colors.primary : colors.primary,
        shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onPressed: () async {
          if (_tabIndex == 0) {
            await openAddOweSheet(context);
          } else {
            await openAddLentSheet(context);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ---------------- Settle sheet content (proper StatefulWidget lifecycle) ----------------

class _SettleSheetContent extends StatefulWidget {
  final AppColors colors;
  final String title;
  final String subtitle;
  final String confirmLabel;

  const _SettleSheetContent({
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
  });

  @override
  State<_SettleSheetContent> createState() => _SettleSheetContentState();
}

class _SettleSheetContentState extends State<_SettleSheetContent> {
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title, style: AppTextStyles.heading3(colors.textPrimary)),
          const SizedBox(height: 6),
          Text(widget.subtitle, style: AppTextStyles.body(colors.textSecondary)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              controller: _noteController,
              style: AppTextStyles.body(colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Note (optional)',
                hintStyle: AppTextStyles.body(colors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_noteController.text.trim()),
              child: Text(widget.confirmLabel),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Owe list ----------------

class _OweList extends StatelessWidget {
  final AppColors colors;
  final String symbol;
  final List<Owe> owes;

  const _OweList({required this.colors, required this.symbol, required this.owes});

  Future<String?> _confirmSettle(BuildContext context, String person, String symbol, double amount) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => _SettleSheetContent(
        colors: colors,
        title: 'Mark as paid',
        subtitle: 'Paying $symbol${amount.toStringAsFixed(2)} to $person',
        confirmLabel: 'Confirm',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (owes.isEmpty) {
      return _EmptyState(colors: colors, text: 'You don\'t owe anyone right now');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
      itemCount: owes.length,
      itemBuilder: (context, index) {
        final owe = owes[index];
        return Dismissible(
          key: ValueKey(owe.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => showConfirmationDialog(
            context: context,
            colors: colors,
            title: 'Delete entry?',
            message: 'This will permanently remove this entry.',
            confirmLabel: 'Delete',
          ),
          onDismissed: (_) async {
            final uid = getIt<AuthRepository>().currentUser?.uid;
            if (uid == null) return;
            await context.read<OweCubit>().delete(uid, owe.id);
            if (context.mounted) AppSnackbar.showInfo(context, 'Deleted');
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Iconsax.trash, color: colors.error, size: 20),
          ),
          child: GestureDetector(
            onTap: owe.isSettled
                ? null
                : () async {
                    await openAddOweSheet(context, existingOwe: owe);
                  },
            child: _LiabilityTile(
              colors: colors,
              symbol: symbol,
              personName: owe.personName,
              amount: owe.amount,
              dueDate: owe.dueDate,
              note: owe.note,
              isSettled: owe.isSettled,
              accentColor: colors.error,
              onSettleTap: owe.isSettled
                  ? null
                  : () async {
                      final note = await _confirmSettle(context, owe.personName, symbol, owe.amount);
                      if (note == null) return;
                      final uid = getIt<AuthRepository>().currentUser?.uid;
                      if (uid == null) return;
                      final updated = owe.copyWith(
                        isSettled: true,
                        settledAt: DateTime.now(),
                        settledNote: note,
                        isSynced: false,
                      );
                      await context.read<OweCubit>().save(updated);
                      if (context.mounted) AppSnackbar.showSuccess(context, 'Marked as settled');
                    },
            ),
          ),
        );
      },
    );
  }
}

// ---------------- Lent list ----------------

class _LentList extends StatelessWidget {
  final AppColors colors;
  final String symbol;
  final List<Lent> lents;

  const _LentList({required this.colors, required this.symbol, required this.lents});

  Future<String?> _confirmSettle(BuildContext context, String person, String symbol, double amount) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => _SettleSheetContent(
        colors: colors,
        title: 'Mark as received',
        subtitle: 'Receiving $symbol${amount.toStringAsFixed(2)} from $person',
        confirmLabel: 'Confirm',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (lents.isEmpty) {
      return _EmptyState(colors: colors, text: 'No one owes you right now');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 90),
      itemCount: lents.length,
      itemBuilder: (context, index) {
        final lent = lents[index];
        return Dismissible(
          key: ValueKey(lent.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => showConfirmationDialog(
            context: context,
            colors: colors,
            title: 'Delete entry?',
            message: 'This will permanently remove this entry.',
            confirmLabel: 'Delete',
          ),
          onDismissed: (_) async {
            final uid = getIt<AuthRepository>().currentUser?.uid;
            if (uid == null) return;
            await context.read<LentCubit>().delete(uid, lent.id);
            if (context.mounted) AppSnackbar.showInfo(context, 'Deleted');
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Iconsax.trash, color: colors.error, size: 20),
          ),
          child: GestureDetector(
            onTap: lent.isSettled
                ? null
                : () async {
                    await openAddLentSheet(context, existingLent: lent);
                  },
            child: _LiabilityTile(
              colors: colors,
              symbol: symbol,
              personName: lent.personName,
              amount: lent.amount,
              dueDate: lent.dueDate,
              note: lent.note,
              isSettled: lent.isSettled,
              accentColor: colors.primary,
              onSettleTap: lent.isSettled
                  ? null
                  : () async {
                      final note = await _confirmSettle(context, lent.personName, symbol, lent.amount);
                      if (note == null) return;
                      final uid = getIt<AuthRepository>().currentUser?.uid;
                      if (uid == null) return;
                      final updated = lent.copyWith(
                        isSettled: true,
                        settledAt: DateTime.now(),
                        settledNote: note,
                        isSynced: false,
                      );
                      await context.read<LentCubit>().save(updated);
                      if (context.mounted) AppSnackbar.showSuccess(context, 'Marked as settled');
                    },
            ),
          ),
        );
      },
    );
  }
}

// ---------------- Shared tile + empty state ----------------

class _LiabilityTile extends StatelessWidget {
  final AppColors colors;
  final String symbol;
  final String personName;
  final double amount;
  final DateTime dueDate;
  final String note;
  final bool isSettled;
  final Color accentColor;
  final VoidCallback? onSettleTap;

  const _LiabilityTile({
    required this.colors,
    required this.symbol,
    required this.personName,
    required this.amount,
    required this.dueDate,
    required this.note,
    required this.isSettled,
    required this.accentColor,
    required this.onSettleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                personName.isNotEmpty ? personName[0].toUpperCase() : '?',
                style: AppTextStyles.bodyMedium(accentColor).copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personName,
                  style: AppTextStyles.bodyMedium(colors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  isSettled
                      ? 'Settled'
                      : 'By ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                  style: AppTextStyles.caption(isSettled ? colors.primary : colors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$symbol${amount.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium(colors.textPrimary).copyWith(
                  fontWeight: FontWeight.w700,
                  decoration: isSettled ? TextDecoration.lineThrough : null,
                ),
              ),
              if (!isSettled && onSettleTap != null) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onSettleTap,
                  child: Text(
                    'Settle',
                    style: AppTextStyles.small(accentColor).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}



// ---------------- Empty state ----------------
class _EmptyState extends StatelessWidget {
  final AppColors colors;
  final String text;
  const _EmptyState({required this.colors, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.empty_wallet_add, size:70, color: colors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(text, style: AppTextStyles.body(colors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}