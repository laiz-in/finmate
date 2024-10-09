import 'package:dartz/dartz.dart' as dartz;
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
      padding: const EdgeInsets.all(0.0),
      child: FutureBuilder<dartz.Either<String, Map<String, double>>>(
        future: _expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _loadingContainer(context);
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              errorSnackbar(context, snapshot.error.toString());
            });
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return snapshot.data!.fold(
              (errorMessage) {
                print(errorMessage);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  errorSnackbar(context, errorMessage);
                });
                return Center(child: Text('Error: $errorMessage'));
              },
              (expensesMap) {
                List<double> expenses = expensesMap.values.toList();
                return _buildBarChart(expenses);
              },
            );
          }
          return const Center(child: Text('No Data Found'));
        },
      ),
    );
  }

  // Loading container
  Widget _loadingContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 10),
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 68, 68, 68).withOpacity(0.10),
            spreadRadius: 12,
            blurRadius: 17,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).hintColor,
      ),
    );
  }

  // Widget to build the bar chart with the fetched data
  Widget _buildBarChart(List<double> expenses) {
    double maxY = expenses.reduce((a, b) => a > b ? a : b);

      List<double> expensesreversed = expenses.reversed.toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
      width: double.infinity,
      height: 150, // Adjust height for bar chart
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 68, 68, 68).withOpacity(0.10),
            spreadRadius: 12,
            blurRadius: 17,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Theme.of(context).hintColor,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: maxY,// Adjust to add space above the tallest bar
          minY: 0,
          titlesData: FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      value.toInt().toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 8,
                        color: Theme.of(context).canvasColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  DateTime now = DateTime.now();
                  DateTime date = now.subtract(Duration(days: 14 - value.toInt()));
                  String dayLabel = DateFormat('d').format(date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0,left: 0),
                    child: Text(
                      dayLabel,
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).canvasColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 7,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: expensesreversed.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Theme.of(context).canvasColor,
                  width: 10, // Adjust width of the bars
                  borderRadius: BorderRadius.circular(6),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
