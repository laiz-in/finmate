import 'package:finmate/core/utils/app_page_route.dart';
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

enum _QuickFilter { none, today, yesterday, pickDate }
enum _SortOrder { none, highToLow, lowToHigh }

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  String? _selectedCategory;
  _QuickFilter _quickFilter = _QuickFilter.none;
  DateTime? _pickedDate;
  DateTime? _fromDate;
  DateTime? _toDate;
  _SortOrder _sortOrder = _SortOrder.none;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _quickFilter != _QuickFilter.none ||
      _fromDate != null ||
      _toDate != null ||
      _sortOrder != _SortOrder.none;

  String _sectionTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    return '${date.day} ${_monthsFull[date.month - 1]} ${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Expense> _applyFilters(List<Expense> expenses) {
    var result = expenses;

    switch (_quickFilter) {
      case _QuickFilter.today:
        final now = DateTime.now();
        result = result.where((e) => _isSameDay(e.date, now)).toList();
        break;
      case _QuickFilter.yesterday:
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        result = result.where((e) => _isSameDay(e.date, yesterday)).toList();
        break;
      case _QuickFilter.pickDate:
        if (_pickedDate != null) {
          result = result.where((e) => _isSameDay(e.date, _pickedDate!)).toList();
        }
        break;
      case _QuickFilter.none:
        if (_fromDate != null || _toDate != null) {
          final start = _fromDate != null
              ? DateTime(_fromDate!.year, _fromDate!.month, _fromDate!.day)
              : DateTime(2020);
          final end = _toDate != null
              ? DateTime(_toDate!.year, _toDate!.month, _toDate!.day, 23, 59, 59)
              : DateTime.now();
          result = result.where((e) => !e.date.isBefore(start) && !e.date.isAfter(end)).toList();
        }
        break;
    }

    if (_selectedCategory != null) {
      result = result.where((e) => e.category == _selectedCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((e) => e.note.toLowerCase().contains(query)).toList();
    }

    result = List<Expense>.from(result);
    switch (_sortOrder) {
      case _SortOrder.highToLow:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case _SortOrder.lowToHigh:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case _SortOrder.none:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
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
      backgroundColor: colors.background,
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
              child: SingleChildScrollView(
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('Today'),
                          labelStyle: AppTextStyles.caption(
                            _quickFilter == _QuickFilter.today ? Colors.white : colors.textPrimary,
                          ),
                          selected: _quickFilter == _QuickFilter.today,
                          onSelected: (selected) {
                            setSheetState(() {
                              _quickFilter = selected ? _QuickFilter.today : _QuickFilter.none;
                              if (selected) {
                                _fromDate = null;
                                _toDate = null;
                                _pickedDate = null;
                              }
                            });
                            setState(() {});
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary,
                          side: BorderSide(color: colors.border),
                          showCheckmark: false,
                        ),
                        ChoiceChip(
                          label: const Text('Yesterday'),
                          labelStyle: AppTextStyles.caption(
                            _quickFilter == _QuickFilter.yesterday ? Colors.white : colors.textPrimary,
                          ),
                          selected: _quickFilter == _QuickFilter.yesterday,
                          onSelected: (selected) {
                            setSheetState(() {
                              _quickFilter = selected ? _QuickFilter.yesterday : _QuickFilter.none;
                              if (selected) {
                                _fromDate = null;
                                _toDate = null;
                                _pickedDate = null;
                              }
                            });
                            setState(() {});
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary,
                          side: BorderSide(color: colors.border),
                          showCheckmark: false,
                        ),
                        ChoiceChip(
                          label: Text(
                            _quickFilter == _QuickFilter.pickDate && _pickedDate != null
                                ? '${_pickedDate!.day}/${_pickedDate!.month}/${_pickedDate!.year}'
                                : 'Pick a date',
                          ),
                          labelStyle: AppTextStyles.caption(
                            _quickFilter == _QuickFilter.pickDate ? Colors.white : colors.textPrimary,
                          ),
                          selected: _quickFilter == _QuickFilter.pickDate,
                          onSelected: (selected) async {
                            if (!selected) {
                              setSheetState(() {
                                _quickFilter = _QuickFilter.none;
                                _pickedDate = null;
                              });
                              setState(() {});
                              return;
                            }
                            final picked = await showDatePicker(
                              context: sheetContext,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              initialDate: _pickedDate ?? DateTime.now(),
                            );
                            if (picked != null) {
                              setSheetState(() {
                                _quickFilter = _QuickFilter.pickDate;
                                _pickedDate = picked;
                                _fromDate = null;
                                _toDate = null;
                              });
                              setState(() {});
                            }
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary,
                          side: BorderSide(color: colors.border),
                          showCheckmark: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'CUSTOM DATE RANGE',
                      style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: sheetContext,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDate: _fromDate ?? DateTime.now(),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  _fromDate = picked;
                                  _quickFilter = _QuickFilter.none;
                                  _pickedDate = null;
                                });
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: Text(
                                _fromDate == null
                                    ? 'From'
                                    : '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}',
                                style: AppTextStyles.body(colors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: sheetContext,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDate: _toDate ?? DateTime.now(),
                              );
                              if (picked != null) {
                                setSheetState(() {
                                  _toDate = picked;
                                  _quickFilter = _QuickFilter.none;
                                  _pickedDate = null;
                                });
                                setState(() {});
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: Text(
                                _toDate == null
                                    ? 'To'
                                    : '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}',
                                style: AppTextStyles.body(colors.textPrimary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'CATEGORY',
                      style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          icon: const SizedBox.shrink(),
                          dropdownColor: colors.surface,
                          borderRadius: BorderRadius.circular(12),
                          style: AppTextStyles.body(colors.textPrimary),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          value: _selectedCategory,
                          hint: Text('All categories', style: AppTextStyles.body(colors.textSecondary)),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All categories', style: AppTextStyles.body(colors.textPrimary)),
                            ),
                            ...categories.map((category) {
                              return DropdownMenuItem<String?>(
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
                            }),
                          ],
                          onChanged: (value) {
                            setSheetState(() => _selectedCategory = value);
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'SORT BY AMOUNT',
                      style: AppTextStyles.small(colors.textSecondary).copyWith(letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('High to low'),
                          labelStyle: AppTextStyles.caption(
                            _sortOrder == _SortOrder.highToLow ? Colors.white : colors.textPrimary,
                          ),
                          selected: _sortOrder == _SortOrder.highToLow,
                          onSelected: (selected) {
                            setSheetState(() {
                              _sortOrder = selected ? _SortOrder.highToLow : _SortOrder.none;
                            });
                            setState(() {});
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary,
                          side: BorderSide(color: colors.border),
                          showCheckmark: false,
                        ),
                        ChoiceChip(
                          label: const Text('Low to high'),
                          labelStyle: AppTextStyles.caption(
                            _sortOrder == _SortOrder.lowToHigh ? Colors.white : colors.textPrimary,
                          ),
                          selected: _sortOrder == _SortOrder.lowToHigh,
                          onSelected: (selected) {
                            setSheetState(() {
                              _sortOrder = selected ? _SortOrder.lowToHigh : _SortOrder.none;
                            });
                            setState(() {});
                          },
                          backgroundColor: colors.surface,
                          selectedColor: colors.primary,
                          side: BorderSide(color: colors.border),
                          showCheckmark: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                setSheetState(() {
                                  _selectedCategory = null;
                                  _quickFilter = _QuickFilter.none;
                                  _pickedDate = null;
                                  _fromDate = null;
                                  _toDate = null;
                                  _sortOrder = _SortOrder.none;
                                });
                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.error,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Clear all'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(sheetContext).pop(),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text('Apply'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                  Text('Expenses', style: AppTextStyles.heading3(colors.textPrimary)),
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

            // EXPENSE LIST
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
                                    appPageRoute(
                                      ExpenseDetailScreen(
                                        expense: expense,
                                        symbol: symbol,
                                        categoryColor: categoryColor,
                                      ),
                                      colors.background,
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  final uid = getIt<AuthRepository>().currentUser?.uid;
                                  if (uid == null) return;
                                  await context.read<ExpenseCubit>().deleteExpense(uid, expense.id);
                                  if (context.mounted) {
                                    AppSnackbar.showError(context, 'Expense has been deleted');
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

// EMPTY STATE WIDGET
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
            Icon(Iconsax.box_remove, size: 70, color: colors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching expenses' : 'You don\'t have any expenses yet!',
              style: AppTextStyles.bodyMedium(colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// EACH EXPENSE TILE
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