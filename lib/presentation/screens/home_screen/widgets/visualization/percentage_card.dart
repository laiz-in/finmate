import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebaseUtils;
import 'package:percent_indicator/circular_percent_indicator.dart';

class GraphCardWidget extends StatefulWidget {
  final double totalSpending;
  final double monthlyLimit;
  final double dailyLimit;
  final String userId;

  const GraphCardWidget({
    super.key,
    required this.totalSpending,
    required this.monthlyLimit,
    required this.dailyLimit,
    required this.userId,
  });

  @override
  GraphCardWidgetState createState() => GraphCardWidgetState();
}

class GraphCardWidgetState extends State<GraphCardWidget> {
  double todaySpending = 0.0;
  double thisMonthSpending = 0.0;
  double thisMonthIncome = 0.0;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  StreamSubscription<double>? _monthlySpendingSubscription;
  Timer? _retryTimer;
  int _retryAttempts = 0;
  static const int maxRetryAttempts = 3;
  
  @override
  void initState() {
    super.initState();
    _setupDataFetching();
  }

  @override
  void dispose() {
    _monthlySpendingSubscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(GraphCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch data if userId changes
    if (oldWidget.userId != widget.userId) {
      _resetAndRefetch();
    }
  }

  void _resetAndRefetch() {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
      _retryAttempts = 0;
    });
    _monthlySpendingSubscription?.cancel();
    _retryTimer?.cancel();
    _setupDataFetching();
  }

  Future<void> _setupDataFetching() async {
    try {
      // Setup real-time monthly spending updates with error handling
      _monthlySpendingSubscription = firebaseUtils
          .getMonthTotalSpending(widget.userId)
          .handleError((error) {
            _handleError('Monthly spending update failed: $error');
            return 0.0;
          })
          .listen(
            (spending) {
              if (mounted) {
                setState(() {
                  thisMonthSpending = spending;
                  hasError = false;
                  errorMessage = '';
                });
              }
            },
            onError: (error) {
              _handleError('Stream error: $error');
            },
          );

      // Fetch other data points with proper error handling
      final results = await Future.wait([
        firebaseUtils.getTodayTotalSpending(widget.userId),
        firebaseUtils.getMonthTotalIncome(widget.userId),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Data fetch timeout'),
      );

      if (mounted) {
        setState(() {
          todaySpending = results[0];
          thisMonthIncome = results[1];
          isLoading = false;
          hasError = false;
          errorMessage = '';
          _retryAttempts = 0;
        });
      }
    } catch (e) {
      _handleError('Failed to fetch data: $e');
    }
  }

  void _handleError(String error) {
    if (!mounted) return;

    setState(() {
      hasError = true;
      errorMessage = error;
      isLoading = false;
    });

    // Implement exponential backoff for retries
    if (_retryAttempts < maxRetryAttempts) {
      _retryTimer?.cancel();
      _retryTimer = Timer(
        Duration(seconds: pow(2, _retryAttempts).toInt()),
        () {
          _retryAttempts++;
          _setupDataFetching();
        },
      );
    }
  }

  // Safely calculate percentages to avoid division by zero
  double _calculatePercentage(double value, double limit) {
    if (limit <= 0) return 0.0;
    final percentage = (value / limit) * 100;
    return percentage > 100 ? 100 : percentage;
  }

  @override
  Widget build(BuildContext context) {
    // Safe calculations with null checks and bounds
    final dailySpendingPercentage = _calculatePercentage(todaySpending, widget.dailyLimit);
    final monthlyLimitPercentage = _calculatePercentage(thisMonthSpending, widget.monthlyLimit);
    final dailySpendingPercentageForGraph = dailySpendingPercentage / 100;
    final monthlyLimitPercentageForGraph = monthlyLimitPercentage / 100;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(
            'Unable to load data. Retrying...',
            style: GoogleFonts.poppins(
              color: Theme.of(context).cardColor,
              fontSize: 12.sp,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 17.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 68, 68, 68).withOpacity(0.10),
                spreadRadius: 10.r,
                blurRadius: 15.r,
                offset: Offset(2.w, 4.h),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: AppColors.darkForegroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.r),
                    topRight: Radius.circular(15.r),
                  ),
                ),
                child: Row(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCircularIndicator(
                    context: context,
                    title: 'Monthly Limit',
                    percentage: monthlyLimitPercentageForGraph,
                    amount: '${thisMonthSpending.toStringAsFixed(1)}/${widget.monthlyLimit.toStringAsFixed(0)}',
                  ),
                  SizedBox(width: 15.w),
                  _buildCircularIndicator(
                    context: context,
                    title: 'Daily Limit',
                    percentage: dailySpendingPercentageForGraph,
                    amount: '${todaySpending.toStringAsFixed(0)}/${widget.dailyLimit.toStringAsFixed(0)}',
                  ),
                  SizedBox(width: 25.w),
                  _buildVerticalBar(
                    label: "Expense",
                    value: thisMonthSpending,
                    maxValue: thisMonthSpending > thisMonthIncome ? thisMonthSpending : thisMonthIncome,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(width: 16.w),
                  _buildVerticalBar(
                    label: "Income",
                    value: thisMonthIncome,
                    maxValue: thisMonthSpending > thisMonthIncome ? thisMonthSpending : thisMonthIncome,
                    color: AppColors.foregroundColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rest of your widget methods remain exactly the same
  Widget _buildVerticalBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    // Your existing implementation
    double barHeight = 80.h;
    double normalizedHeight = (maxValue > 0) ? (value / maxValue) * barHeight : 0;

    return Column(
      children: [
        SizedBox(height: 8.h),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 23.w,
          height: barHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.grey.shade300,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: normalizedHeight,
              width: 23.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: color,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '₹ ${value.toStringAsFixed(0)}',
          style: GoogleFonts.montserrat(
            fontSize: 7.sp,
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h)
      ],
    );
  }

  Widget _buildCircularIndicator({
    required BuildContext context,
    required String title,
    required double percentage,
    required String amount,
  }) {
    return Column(
      children: [
        SizedBox(height: 9.h),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 15.h),
        CircularPercentIndicator(
          radius: 33.0.r,
          lineWidth: 6.0.w,
          percent: percentage,
          center: Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              color: Theme.of(context).canvasColor.withOpacity(0.7),
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Theme.of(context).canvasColor,
          backgroundColor: Theme.of(context).canvasColor.withOpacity(0.3),
        ),
        SizedBox(height: 15.h),
        Text(
          amount,
          style: GoogleFonts.poppins(
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 7.sp,
          ),
        ),
      ],
    );
  }
}