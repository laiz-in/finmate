import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/usecases/expenses/last_three_expense_usecase.dart';
import 'package:moneyy/service_locator.dart';

class RecentExpensesScreen extends StatefulWidget {
  const RecentExpensesScreen({super.key});

  @override
  State<RecentExpensesScreen> createState() => _RecentExpensesScreenState();
}

class _RecentExpensesScreenState extends State<RecentExpensesScreen> {
  late Future<dartz.Either<String, List<ExpensesEntity>>> _recentExpensesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch the recent expenses using LastThreeExpensesUseCase
    _recentExpensesFuture = sl<LastThreeExpensesUseCase>()();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: FutureBuilder<dartz.Either<String, List<ExpensesEntity>>>(
        future: _recentExpensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Center());
          } else if (snapshot.hasError) {
            // Display error message
            WidgetsBinding.instance.addPostFrameCallback((_) {
              errorSnackbar(context, snapshot.error.toString());
            });
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return snapshot.data!.fold(
              (errorMessage) {
                // Display error message from the use case
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  errorSnackbar(context, errorMessage);
                });
                return Center(child: Text('Error: $errorMessage'));
              },
              (recentExpenses) {
                // If data exists, build the recent transaction card
                return _recentExpensesCard(recentExpenses, context);
              },
            );
          }
          return const Center(child: Text('No Data Found'));
        },
      ),
    );
  }

  // Widget to display recent expenses or error messages
  Widget _recentExpensesCard(List<ExpensesEntity> recentExpenses, BuildContext context) {
    DateTime now = DateTime.now();

    // Function to calculate "time ago"
    String timeAgo(DateTime date) {
      Duration difference = now.difference(date);
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inMinutes}m ago';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 49, 49, 49).withOpacity(0.18),
              spreadRadius: 8,
              blurRadius: 15,
              offset: const Offset(0, 4), // changes position of shadow
            ),
          ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recentExpenses.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "oopss!",
                          style: GoogleFonts.montserrat(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).cardColor.withOpacity(0.6),
                          ),
                        ),
                        Text(
                          "no transactions found",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).cardColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : recentExpenses.asMap().entries.map((entry) {
                  int index = entry.key;
                  ExpensesEntity transaction = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 8, 8, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Amount text
                            Expanded(
                              flex: 3, // 30% of the width
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_outward,
                                    color: Colors.red.shade200,
                                  ),
                                  Text(
                                    '₹${transaction.spendingAmount.toStringAsFixed(1)}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 7, // 70% of the width
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Description text
                                  Expanded(
                                    flex: 1, // 35% of the remaining width
                                    child: Text(
                                      transaction.spendingDescription,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context).cardColor.withOpacity(0.8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Time ago text
                                  Expanded(
                                    flex: 1, // 35% of the remaining width
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          timeAgo(transaction.spendingDate),
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).cardColor.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index != recentExpenses.length - 1)
                        const Divider(color: Color.fromARGB(255, 154, 184, 169)),
                    ],
                  );
                }).toList(),
        ),
      ),
    );
  }
}
