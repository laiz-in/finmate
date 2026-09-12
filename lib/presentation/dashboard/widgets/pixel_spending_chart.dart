import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense.dart';

class PixelSpendingChart extends StatefulWidget {
  final AppColors colors;
  final List<Expense> expenses;
  final String symbol;
  final int daysToShow;

  const PixelSpendingChart({
    super.key,
    required this.colors,
    required this.expenses,
    required this.symbol,
    this.daysToShow = 15,
  });

  @override
  State<PixelSpendingChart> createState() => _PixelSpendingChartState();
}

class _PixelSpendingChartState extends State<PixelSpendingChart> {
  int? _selectedIndex;

  static const double gap = 3;

  List<_DayTotal> _recentDays() {
    final today = DateTime.now();
    return List.generate(widget.daysToShow, (i) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: widget.daysToShow - 1 - i));
      final total = widget.expenses
          .where((e) =>
              e.date.year == date.year &&
              e.date.month == date.month &&
              e.date.day == date.day)
          .fold(0.0, (sum, e) => sum + e.amount);
      return _DayTotal(date: date, total: total);
    });
  }

  void _handleTap(TapUpDetails details, double width, int columnCount) {
    final cellWidth = (width - gap * (columnCount - 1)) / columnCount;
    final tappedIndex = (details.localPosition.dx / (cellWidth + gap)).floor().clamp(0, columnCount - 1);
    setState(() {
      _selectedIndex = _selectedIndex == tappedIndex ? null : tappedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final symbol = widget.symbol;
    final days = _recentDays();
    final maxValue = days.map((d) => d.total).fold(0.0, (a, b) => a > b ? a : b);
    const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

String _ordinalDay(int day) {
  if (day >= 11 && day <= 13) return '${day}th';
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

    int peakIndex = 0;
    for (int i = 1; i < days.length; i++) {
      if (days[i].total > days[peakIndex].total) peakIndex = i;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LAST ${widget.daysToShow} DAYS', style: AppTextStyles.small(colors.textPrimary)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) => _handleTap(details, constraints.maxWidth, days.length),
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: _PixelChartPainter(
                      days: days,
                      maxValue: maxValue,
                      primary: colors.primary,
                      textColor: colors.textPrimary,
                      fadedTextColor: colors.textSecondary,
                      symbol: symbol,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                );
              },
            ),
          ),
          if (maxValue > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'You spent $symbol${maxValue.toStringAsFixed(0)} on ${_ordinalDay(days[peakIndex].date.day)} ${_monthsFull[days[peakIndex].date.month - 1]}',
                style: AppTextStyles.small(colors.error),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayTotal {
  final DateTime date;
  final double total;
  const _DayTotal({required this.date, required this.total});
}

class _PixelChartPainter extends CustomPainter {
  final List<_DayTotal> days;
  final double maxValue;
  final Color primary;
  final Color textColor;
  final Color fadedTextColor;
  final String symbol;
  final int? selectedIndex;

  static const int rows = 14;
  static const double gap = 3;
  static const double labelSpace = 30;
  static const double bottomLabelSpace = 20;

  _PixelChartPainter({
    required this.days,
    required this.maxValue,
    required this.primary,
    required this.textColor,
    required this.fadedTextColor,
    required this.symbol,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final columns = days.length;
    if (columns == 0) return;

    final gridBottom = size.height - bottomLabelSpace;
    final gridTop = labelSpace;
    final gridHeight = gridBottom - gridTop;

    final cellWidth = (size.width - gap * (columns - 1)) / columns;
    final cellHeight = (gridHeight - gap * (rows - 1)) / rows;

    for (int col = 0; col < columns; col++) {
      final value = days[col].total;
      final filledRows = maxValue > 0
          ? (value / maxValue * rows).round().clamp(0, rows)
          : 0;

      final colLeft = col * (cellWidth + gap);
      final isSelected = col == selectedIndex;

      for (int row = 0; row < rows; row++) {
        final rowTop = gridBottom - (row + 1) * cellHeight - row * gap;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(colLeft, rowTop, cellWidth, cellHeight),
          const Radius.circular(1),
        );

        final paint = Paint();

        if (row < filledRows) {
          final t = filledRows <= 1 ? 0.0 : row / (filledRows - 1);
          final base = Color.lerp(primary, Colors.white, t * 0.35)!;
          paint.color = isSelected ? base : base.withValues(alpha: 0.95);
        } else {
          // Empty cell — same green, very low opacity, so the grid still
          // reads as "your color" rather than neutral grey. Selected column's
          // empty cells get a slightly higher opacity to read as "active".
          paint.color = primary.withValues(alpha: isSelected ? 0.12 : 0.06);
        }

        canvas.drawRRect(rect, paint);
      }

      // Bottom-axis day number.
      final dayText = TextPainter(
        text: TextSpan(
          text: '${days[col].date.day}',
          style: AppTextStyles.small(isSelected ? textColor : fadedTextColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      dayText.paint(
        canvas,
        Offset(colLeft + (cellWidth - dayText.width) / 2, gridBottom + 6),
      );
    }

    // Tapped-column callout — only shown when a column is selected.
    if (selectedIndex != null) {
      final col = selectedIndex!;
      final value = days[col].total;
      final filledRows = maxValue > 0
          ? (value / maxValue * rows).round().clamp(0, rows)
          : 0;
      final colLeft = col * (cellWidth + gap);
      final colTop = filledRows > 0
          ? gridBottom - filledRows * cellHeight - (filledRows - 1) * gap
          : gridBottom;

      final labelText = TextPainter(
        text: TextSpan(
          text: '$symbol${value.toStringAsFixed(0)}',
          style: AppTextStyles.small(textColor).copyWith(fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double labelX = colLeft + cellWidth / 2 - labelText.width / 2;
      labelX = labelX.clamp(0.0, size.width - labelText.width);
      final labelY = (colTop - labelText.height - 6).clamp(0.0, size.height);

      labelText.paint(canvas, Offset(labelX, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _PixelChartPainter oldDelegate) {
    return oldDelegate.days != days ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.primary != primary ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}