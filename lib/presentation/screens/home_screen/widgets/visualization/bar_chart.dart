import 'package:dartz/dartz.dart' as dartz; // Add alias
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/usecases/expenses/last_seven_day_expense_usecase.dart';
import 'package:moneyy/service_locator.dart';

class DaywiseBarchart extends StatefulWidget {
  const DaywiseBarchart({super.key});

  @override
  State<DaywiseBarchart> createState() => _DaywiseBarchartState();
}

class _DaywiseBarchartState extends State<DaywiseBarchart> {
  late Future<dartz.Either<String, Map<String, double>>> _expensesFuture;
  

  @override
  void initState() {
    super.initState();
    // Call the use case and handle the Either type
    _expensesFuture = sl<LastSevenDayExpensesUseCase>()();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0), // Use padding instead of Scaffold
      child: FutureBuilder<dartz.Either<String, Map<String, double>>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          } else if (snapshot.hasError) {
            // Show error if the Future itself fails
            WidgetsBinding.instance.addPostFrameCallback((_) {
              errorSnackbar(context, snapshot.error.toString());
            });
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Handle Either (error or success) type here
            return snapshot.data!.fold(
              (errorMessage) {
                // Show error message
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  errorSnackbar(context, errorMessage);
                });
                return Center(child: Text('Error: $errorMessage'));
              },
              (expensesMap) {
                // On success, build the line graph with the returned expenses
                List<double> expenses = expensesMap.values.toList();
                return _buildLineGraph(expenses);
              },
            );
          }
          return const Center(child: Text('No Data Found'));
        },
      ),
    );
  }

  // Widget to build the line graph with the fetched data
  Widget _buildLineGraph(List<double> expenses) {
    double maxY = expenses.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(25,15,25,10),
      width: double.infinity,
      height: 100, // Keep the height same as the bar chart
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 68, 68, 68).withOpacity(0.10),
            spreadRadius: 12,
            blurRadius: 17,
            offset: const Offset(0, 4), // changes position of shadow
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).hintColor,
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          // You might want to set maxY based on your data
          maxY: maxY,
          gridData: FlGridData(show: true,drawVerticalLine: true,getDrawingHorizontalLine: (value){
            return FlLine(
            color: Theme.of(context).hintColor,
            strokeWidth: 1
            );
          }),
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1, // Ensure labels are shown at integer intervals
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value % 1 == 0) {
                    // Only show labels for integer x-values
                    DateTime now = DateTime.now();
                    DateTime date = now.subtract(Duration(days: 6 - value.toInt()));
                    String dayName = DateFormat('EEE').format(date).toUpperCase();
                    return Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        dayName,
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true, // Curved lines for smoother appearance
              color: Theme.of(context).canvasColor,
              barWidth: 2, // Adjust the line thickness
              isStrokeCapRound: true, // Rounded line edges
              dotData: FlDotData(show: true), // Show dots on data points
              belowBarData: BarAreaData(show: false),
              spots: expenses.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
