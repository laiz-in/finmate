import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class GraphCardWidget extends StatelessWidget {
  final double todaySpending;
  final double totalSpending;
  final double monthlyLimit;
  final double dailyLimit;

  const GraphCardWidget({
    super.key,
    required this.todaySpending,
    required this.totalSpending,
    required this.monthlyLimit,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    final dailySpendingPercentage = (todaySpending / dailyLimit) * 100;
    final monthlyLimitPercentage = (totalSpending / monthlyLimit) * 100;
    double dailySpendingPercentageForGraph = 0;

    if ((dailySpendingPercentage / 100) > 1) {
      dailySpendingPercentageForGraph = 1.0;
    } else {
      dailySpendingPercentageForGraph = dailySpendingPercentage / 100;
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 49, 49, 49).withOpacity(0.10),
                spreadRadius: 10,
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildCircularIndicator(
                    context: context,
                    title: 'Monthly limit',
                    percentage: monthlyLimitPercentage,
                    amount: '$totalSpending/$monthlyLimit',
                  ),
                  _buildCircularIndicator(
                    context: context,
                    title: 'Daily limit',
                    percentage: dailySpendingPercentageForGraph * 100,
                    amount: '$todaySpending/$dailyLimit',
                  ),
                ],
              ),



            //  DaywiseBarchart(transactions: allTransactions),




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
            style: GoogleFonts.montserrat(
              color: Theme.of(context).cardColor.withOpacity(0.8),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 7.0,
            percent: (percentage / 100),
            center: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: GoogleFonts.montserrat(
                color: Theme.of(context).cardColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Theme.of(context).cardColor,
            backgroundColor: Theme.of(context).cardColor.withOpacity(0.3),
          ),
          SizedBox(height: 5),
          Text(
            amount,
            style: GoogleFonts.montserrat(
              color: Theme.of(context).cardColor.withOpacity(0.8),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
