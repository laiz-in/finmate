import 'package:finmate/core/utils/category_icons.dart';
import 'package:finmate/presentation/shared_widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/di/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../profile/bloc/profile_cubit.dart';
import '../bloc/expense_cubit.dart';
import 'expense_detail_screen.dart';

const _monthsFull = [
  'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
  'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
];


class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedCategories = {};
  DateTimeRange? _dateRange;
  bool _todayOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedCategories.isNotEmpty || _dateRange != null || _todayOnly;

  String _sectionTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year}';
  }


  List<Expense> _applyFilters(List<Expense> expenses) {
    var result = expenses;

    if (_todayOnly) {
      final now = DateTime.now();
      result = result
          .where((e) => e.date.year == now.year && e.date.month == now.month && e.date.day == now.day)
          .toList();
    } else if (_dateRange != null) {
      final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
      final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day, 23, 59, 59);
      result = result.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
    }

    if (_selectedCategories.isNotEmpty) {
      result = result.where((e) => _selectedCategories.contains(e.category)).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((e) => e.note.toLowerCase().contains(query)).toList();
    }

    return result;
  }

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    final grouped = <String, List<Expense>>{};
    for (final expense in expenses) {
      final key = _sectionTitle(expense.date);
      grouped.putIfAbsent(key, () => []).add(expense);
    }
    return grouped;
  }

  Future<void> _openFilterSheet(BuildContext context, AppColors colors, List<String> categories) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
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
                  Text('Filters', style: AppTextStyles.heading2(colors.textPrimary)),
                  const SizedBox(height: 20),

                  Text(
                    'QUICK FILTER',
                    style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),
                  FilterChip(
                    label: const Text('Today'),
                    labelStyle: AppTextStyles.caption(_todayOnly ? Colors.white : colors.textPrimary),
                    selected: _todayOnly,
                    onSelected: (selected) {
                      setSheetState(() {
                        _todayOnly = selected;
                        if (selected) _dateRange = null;
                      });
                      setState(() {});
                    },
                    backgroundColor: colors.background,
                    selectedColor: colors.primary,
                    side: BorderSide(color: colors.border),
                    showCheckmark: false,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'DATE RANGE',
                    style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: sheetContext,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _dateRange,
                      );
                      if (picked != null) {
                        setSheetState(() {
                          _dateRange = picked;
                          _todayOnly = false;
                        });
                        setState(() {});
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.calendar_1, size: 16, color: colors.textSecondary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _dateRange == null
                                  ? 'Select a custom range'
                                  : '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                              style: AppTextStyles.body(colors.textPrimary),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'CATEGORIES',
                    style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final isSelected = _selectedCategories.contains(category);
                      return FilterChip(
                        label: Text(category),
                        labelStyle: AppTextStyles.caption(isSelected ? Colors.white : colors.textPrimary),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                          setState(() {});
                        },
                        backgroundColor: colors.background,
                        selectedColor: colors.primary,
                        side: BorderSide(color: colors.border),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setSheetState(() {
                              _selectedCategories = {};
                              _dateRange = null;
                              _todayOnly = false;
                            });
                            setState(() {});
                          },
                          child: const Text('Clear all'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final profile = context.watch<ProfileCubit>().state.profile;
    final expenseState = context.watch<ExpenseCubit>().state;

    if (profile == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    final symbol = profile.currencySymbol;
    final categories = profile.spendingCategories;
    final allExpenses = List<Expense>.from(expenseState.expenses)
      ..sort((a, b) => b.date.compareTo(a.date));

    final filtered = _applyFilters(allExpenses);
    final grouped = _groupByDate(filtered);
    final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Expenses', style: AppTextStyles.heading3(colors.textPrimary)),
                      Text(
                        'Total: $symbol${total.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium(colors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            // border: Border.all(color: colors.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.body(colors.textPrimary),
                            onChanged: (value) => setState(() => _searchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: AppTextStyles.body(colors.textSecondary),
                              prefixIcon: Icon(Icons.search, size: 22, color: colors.textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _openFilterSheet(context, colors, categories),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _hasActiveFilters ? colors.primary : colors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _hasActiveFilters ? colors.primary : colors.border),
                          ),
                          child: Icon(
                            Iconsax.filter,
                            color: _hasActiveFilters ? Colors.white : colors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(colors: colors, hasFilters: _hasActiveFilters || _searchQuery.isNotEmpty)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: grouped.length,
                      itemBuilder: (context, sectionIndex) {
                        final sectionTitle = grouped.keys.elementAt(sectionIndex);
                        final sectionExpenses = grouped[sectionTitle]!;
                        final sectionTotal = sectionExpenses.fold(0.0, (sum, e) => sum + e.amount);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: sectionIndex == 0 ? 0 : 20, bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(sectionTitle, style: AppTextStyles.small(colors.textSecondary)),
                                  Text(
                                    '$symbol${sectionTotal.toStringAsFixed(0)}',
                                    style: AppTextStyles.caption(colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            ...sectionExpenses.map((expense) {
                              final categoryColor = colors.primary;
                              return _ExpenseTile(
                                colors: colors,
                                expense: expense,
                                symbol: symbol,
                                categoryColor: categoryColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ExpenseDetailScreen(
                                        expense: expense,
                                        symbol: symbol,
                                        categoryColor: categoryColor,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  final uid = getIt<AuthRepository>().currentUser?.uid;
                                  if (uid == null) return;
                                  await context.read<ExpenseCubit>().deleteExpense(uid, expense.id);
                                  if (context.mounted) {
                                    AppSnackbar.showInfo(context, 'Expense deleted');
                                  }
                                },
                              );
                            }),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColors colors;
  final bool hasFilters;
  const _EmptyState({required this.colors, required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.receipt_2, size: 56, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching expenses' : 'No expenses yet',
              style: AppTextStyles.heading3(colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Tap the + button to add your first expense',
              style: AppTextStyles.body(colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final AppColors colors;
  final Expense expense;
  final String symbol;
  final Color categoryColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.colors,
    required this.expense,
    required this.symbol,
    required this.categoryColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) {
        return showConfirmationDialog(
          context: context,
          colors: colors,
          title: 'Delete expense?',
          message: 'This will permanently remove this expense.',
          confirmLabel: 'Delete',
        );
      },
      onDismissed: (_) => onDelete(),
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
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(getCategoryIcon(expense.category), color: categoryColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.category,
                      style: AppTextStyles.bodyMedium(colors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (expense.note.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        expense.note,
                        style: AppTextStyles.caption(colors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$symbol${expense.amount.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium(colors.textPrimary).copyWith(fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}