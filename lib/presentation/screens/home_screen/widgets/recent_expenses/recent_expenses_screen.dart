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
            return Container(
                            padding: EdgeInsets.fromLTRB(25,15,25,10),
                            width: double.infinity,
                            height: 150,
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
                        );
                      }
          
          
          else if (snapshot.hasError) {
            // Display error message
            WidgetsBinding.instance.addPostFrameCallback((_) {
              errorSnackbar(context, snapshot.error.toString());
            });
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          else if (snapshot.hasData) {
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
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 37, 37, 37).withOpacity(0.08),
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
                    padding: const EdgeInsets.fromLTRB(0.0, 10, 0, 10),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon( Icons.hourglass_disabled,color: Theme.of(context).canvasColor.withOpacity(0.6),size: 40,),
                          SizedBox(height: 10,),
                          Text(
                            "no expenses found!",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).canvasColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
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
                              flex:4, // 30% of the width
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_outward,
                                    color: Colors.red.shade200,
                                  ),
                                  Text(
                                    transaction.spendingAmount.toStringAsFixed(1),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).canvasColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 6, // 70% of the width
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
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).canvasColor.withOpacity(0.7),
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
                                          overflow: TextOverflow.ellipsis,

                                          timeAgo(transaction.spendingDate),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context).canvasColor.withOpacity(0.7),
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
                        Divider(color: Theme.of(context).canvasColor.withOpacity(0.1),thickness: 1,),
                    ],
                  );
                }).toList(),
        ),
      ),
    );
  }
}
