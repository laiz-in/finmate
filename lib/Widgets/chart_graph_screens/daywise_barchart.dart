import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../firebase/firebase_utils.dart'; // Adjust the import path as needed

class DaywiseBarchart extends StatefulWidget {
  final List<CustomTransaction> transactions;

  const DaywiseBarchart({super.key, required this.transactions});

  @override
  State<DaywiseBarchart> createState() => _DaywiseBarchartState();
}

class _DaywiseBarchartState extends State<DaywiseBarchart> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(5),
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 49, 49, 49).withOpacity(0.15),
        spreadRadius: 8,
        blurRadius: 17,
        offset: Offset(0,4), // changes position of shadow
      ),
    ],
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Theme.of(context).primaryColorDark,
        ),
        child: _loading
            ? Center(child: CircularProgressIndicator())
            : _buildChart(),
      ),
    );
  }

  Widget _buildChart() {
    // Process the transactions to get the data for the last 7 days
    Map<int, double> spendingData = _calculateLast7DaysSpending();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: spendingData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                borderRadius: BorderRadius.only(topLeft:Radius.circular(5),topRight: Radius.circular(5) ),
                toY: entry.value,
                color: Theme.of(context).cardColor,
                width: 10,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false) ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
            
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                DateTime now = DateTime.now();
                DateTime date = now.subtract(Duration(days: 6 - value.toInt()));
                String dayName = DateFormat('EEE').format(date).toUpperCase();
                return Text(
                  dayName,
                  style: GoogleFonts.montserrat(color: Theme.of(context).cardColor,fontWeight: FontWeight.w500,fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (_, __, ___, ____) => null, // No tooltip
          ),
        ),
      ),
    );
  }

  Map<int, double> _calculateLast7DaysSpending() {
    Map<int, double> spendingData = {};
    DateTime now = DateTime.now();

    // Initialize the map with keys for the last 7 days
    for (int i = 0; i < 7; i++) {
      spendingData[i] = 0.0;
    }

    // Calculate spending for each day
    for (CustomTransaction transaction in widget.transactions) {
      DateTime date = transaction.date;
      DateTime startOfToday = DateTime(now.year, now.month, now.day);
      DateTime startOfTransactionDay = DateTime(date.year, date.month, date.day);
      int daysAgo = startOfToday.difference(startOfTransactionDay).inDays;
      if (daysAgo >= 0 && daysAgo < 7) {
        // Use (6 - daysAgo) to align the days with the x-axis labels
        spendingData[6 - daysAgo] = (spendingData[6 - daysAgo] ?? 0.0) + transaction.spendingAmount;
      }
    }

    return spendingData;
  }
}
