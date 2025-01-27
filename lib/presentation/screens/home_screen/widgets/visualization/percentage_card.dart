import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebaseUtils; // ENSURE THIS IS THE CORRECT IMPORT FOR YOUR FIREBASE SERVICE
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
  double todaySpending = 0.0; // TO HOLD TODAY'S SPENDING
  double thisMonthSpending = 0.0; // TO HOLD THIS MONTH'S SPENDING
  double thisMonthIncome = 0.0; // TO HOLD THIS MONTH'S INCOME

  bool isLoading = true; // TO TRACK LOADING STATE

  @override
  void initState() {
    super.initState();
    _fetchTodaySpending(); // FETCH THE SPENDING WHEN THE WIDGET IS INITIALIZED
  }

  Future<void> _fetchTodaySpending() async {
    double totalTodaySpending = await firebaseUtils.getTodayTotalSpending(widget.userId);
    double totalMonthExpense = await firebaseUtils.getMonthTotalSpending(widget.userId);
    double totalMonthIncome = await firebaseUtils.getMonthTotalIncome(widget.userId);
    if (mounted) {
      setState(() {
        todaySpending = totalTodaySpending;
        thisMonthSpending = totalMonthExpense;
        thisMonthIncome = totalMonthIncome;
        isLoading = false; // UPDATE LOADING STATE
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dailySpendingPercentage = (todaySpending / widget.dailyLimit) * 100;
    final monthlyLimitPercentage = (widget.totalSpending / widget.monthlyLimit) * 100;

    double dailySpendingPercentageForGraph = dailySpendingPercentage > 100 ? 1.0 : dailySpendingPercentage / 100;
    double monthlyLimitPercentageForGraph = monthlyLimitPercentage > 100 ? 1.0 : monthlyLimitPercentage / 100;

    return Padding(
      padding: EdgeInsets.only(top: 17.h), // PADDING
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0), // PADDING
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 68, 68, 68).withOpacity(0.10),
                spreadRadius: 10.r,
                blurRadius: 15.r,
                offset: Offset(2.w, 4.h), // CHANGES POSITION OF SHADOW
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
                    amount: '${widget.totalSpending.toStringAsFixed(1)}/${widget.monthlyLimit.toStringAsFixed(0)}',
                  ),
                  SizedBox(width: 15.w,),

                  _buildCircularIndicator(
                    context: context,
                    title: 'Daily Limit',
                    percentage: dailySpendingPercentageForGraph,
                    amount: '${todaySpending.toStringAsFixed(0)}/${widget.dailyLimit.toStringAsFixed(0)}',
                  ),
                  SizedBox(width: 25.w,),
                  _buildVerticalBar(
                    label: "Expense",
                    value: thisMonthSpending,
                    maxValue: thisMonthSpending > thisMonthIncome ? thisMonthSpending : thisMonthIncome,
                    color: Colors.red.shade300,
                  ),
                  SizedBox(width: 16.w), // SPACING
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

  /// METHOD TO BUILD THE VERTICAL BAR FOR EXPENSE AND INCOME
  Widget _buildVerticalBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    double barHeight = 80.h; // MAXIMUM HEIGHT OF THE BAR
    double normalizedHeight = (maxValue > 0) ? (value / maxValue) * barHeight : 0; // AVOID NaN ISSUE

    return Column(
      children: [
        SizedBox(height: 8.h,),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontSize: 10.sp, // FONT SIZE
          ),
        ),
        SizedBox(height: 8.h), // SPACING
        Container(
          width: 23.w, // WIDTH OF THE BAR
          height: barHeight, // TOTAL HEIGHT OF THE BAR
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: Colors.grey.shade300, // BACKGROUND COLOR OF THE ENTIRE BAR
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: normalizedHeight, // HEIGHT RELATIVE TO VALUE
              width: 23.w, // SAME AS THE WIDTH OF THE OUTER CONTAINER
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.r),
                color: color, // COLOR OF THE FILLED PORTION
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h), // SPACING
        Text(
          '₹ ${value.toStringAsFixed(0)}',

          style: GoogleFonts.montserrat(
            fontSize: 10.sp, // FONT SIZE
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h,)
      ],
    );
  }

  // HELPER METHOD FOR BUILDING CIRCULAR INDICATORS
  Widget _buildCircularIndicator({
    required BuildContext context,
    required String title,
    required double percentage,
    required String amount,
  }) {
    return Column(
      children: [
        SizedBox(height: 9.h,),

        // HEADING FOR THE CIRCULAR INDICATOR
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w500,
            fontSize: 10.sp, // FONT SIZE
          ),
        ),

        SizedBox(height: 15.h), // SPACING

        // CIRCULAR INDICATOR
        CircularPercentIndicator(
          radius: 33.0.r, // RADIUS
          lineWidth: 6.0.w, // LINE WIDTH
          percent: percentage,
          center: Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: GoogleFonts.poppins(
              color: Theme.of(context).canvasColor.withOpacity(0.7),
              fontSize: 12.sp, // FONT SIZE
              fontWeight: FontWeight.w500,
            ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: Theme.of(context).canvasColor,
          backgroundColor: Theme.of(context).canvasColor.withOpacity(0.3),
        ),

        SizedBox(height: 15.h), // SPACING

        // TEXT FOR THE AMOUNT
        Text(
          amount,
          style: GoogleFonts.poppins(
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            fontSize: 10.sp, // FONT SIZE
          ),
        ),
      ],
    );
  }
}