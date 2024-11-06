import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebaseUtils; // Ensure this is the correct import for your Firebase service
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
  double todaySpending = 0.0; // To hold today's spending
  bool isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    _fetchTodaySpending(); // Fetch the spending when the widget is initialized
  }

  Future<void> _fetchTodaySpending() async {
    double total = await firebaseUtils.getTodayTotalSpending(context, widget.userId);
     if (mounted) {
    setState(() {
      todaySpending = total;
      isLoading = false; // Update loading state
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
      padding: const EdgeInsets.only(top: 25),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hintColor,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 49, 49, 49).withOpacity(0.05),
                spreadRadius: 10,
                blurRadius: 15,
                offset: Offset(2, 4),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildCircularIndicator(
                    context: context,
                    title: 'Monthly Limit',
                    percentage: monthlyLimitPercentageForGraph,
                    amount: '${widget.totalSpending.toStringAsFixed(2)}/${
                      widget.monthlyLimit.toStringAsFixed(0)}',
                  ),
                  _buildCircularIndicator(
                    context: context,
                    title: 'Daily Limit',
                    percentage: dailySpendingPercentageForGraph,
                    amount: '${todaySpending.toStringAsFixed(2)}/${widget.dailyLimit.toStringAsFixed(0)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for building circular indicators
  Widget _buildCircularIndicator({
    required BuildContext context,
    required String title,
    required double percentage,
    required String amount,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.43,
      height: 165,
      child: Column(
        children: [
          SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Theme.of(context).canvasColor.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 7.0,
            percent: percentage,
            center: Text(
              '${(percentage*100).toStringAsFixed(0)}%',
              style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor.withOpacity(0.7),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Theme.of(context).canvasColor,
            backgroundColor: Theme.of(context).canvasColor.withOpacity(0.3),
          ),
          SizedBox(height: 10),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: Theme.of(context).canvasColor.withOpacity(0.6),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
