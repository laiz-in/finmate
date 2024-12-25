import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/entities/income/income.dart';
import 'package:moneyy/domain/usecases/income/last_three_income_usecase.dart';
import 'package:moneyy/service_locator.dart';

class RecentIncomeScreen extends StatefulWidget {
  const RecentIncomeScreen({super.key});

  @override
  State<RecentIncomeScreen> createState() => _RecentIncomeScreenState();
}

class _RecentIncomeScreenState extends State<RecentIncomeScreen> {
  late Future<dartz.Either<String, List<IncomeEntity>>> _recentIncomeFuture;

  @override
  void initState() {
    super.initState();
    // FETCH THE RECENT INCOME USING LASTTHREEINCOMEUSECASE
    _recentIncomeFuture = sl<LastThreeIncomeUseCase>()();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0), // PADDING
      child: FutureBuilder<dartz.Either<String, List<IncomeEntity>>>(
        future: _recentIncomeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              padding: EdgeInsets.fromLTRB(25.w, 15.h, 25.w, 10.h), // PADDING
              width: double.infinity,
              height: 150.h, // HEIGHT
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 68, 68, 68).withOpacity(0.10),
                    spreadRadius: 12.r,
                    blurRadius: 17.r,
                    offset: const Offset(0, 4), // CHANGES POSITION OF SHADOW
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(20.r)),
                color: Theme.of(context).hintColor,
              ),
            );
          } else if (snapshot.hasError) {
            // DISPLAY ERROR MESSAGE
            WidgetsBinding.instance.addPostFrameCallback((_) {
              errorSnackbar(context, snapshot.error.toString());
            });
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return snapshot.data!.fold(
              (errorMessage) {
                // DISPLAY ERROR MESSAGE FROM THE USE CASE
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  errorSnackbar(context, errorMessage);
                });
                return Center(child: Text('Error: $errorMessage'));
              },
              (recentIncome) {
                // IF DATA EXISTS, BUILD THE RECENT TRANSACTION CARD
                return _recentIncomeCard(recentIncome, context);
              },
            );
          }

          return const Center(child: Text('No Data Found'));
        },
      ),
    );
  }

  // WIDGET TO DISPLAY RECENT INCOME OR ERROR MESSAGES
  Widget _recentIncomeCard(List<IncomeEntity> recentIncome, BuildContext context) {
    DateTime now = DateTime.now();

    // FUNCTION TO CALCULATE "TIME AGO"
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
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0), // PADDING
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 3.h), // PADDING
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 37, 37, 37).withOpacity(0.08),
              spreadRadius: 8.r,
              blurRadius: 15.r,
              offset: const Offset(0, 4), // CHANGES POSITION OF SHADOW
            ),
          ],
          color: Theme.of(context).hintColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.r),
            bottomRight: Radius.circular(15.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recentIncome.isEmpty
              ? [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 10.h, 0, 10.h), // PADDING
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.hourglass_disabled,
                            color: Theme.of(context).canvasColor.withOpacity(0.6),
                            size: 40.sp, // ICON SIZE
                          ),
                          SizedBox(height: 10.h), // SPACING
                          Text(
                            "no income found!",
                            style: GoogleFonts.poppins(
                              fontSize: 15.sp, // FONT SIZE
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).canvasColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              : recentIncome.asMap().entries.map((entry) {
                  int index = entry.key;
                  IncomeEntity transaction = entry.value;
                  return Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(2.w, 3.h, 8.w, 3.h), // PADDING
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // AMOUNT TEXT
                            Expanded(
                              flex: 4, // 30% OF THE WIDTH
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 8.w), // PADDING
                                    child: Icon(
                                      Symbols.south_west,
                                      color: Colors.green.shade300,
                                      size: 20.sp, // ICON SIZE
                                    ),
                                  ),
                                  Text(
                                    transaction.incomeAmount.toStringAsFixed(1),
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16.sp, // FONT SIZE
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).canvasColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 6, // 70% OF THE WIDTH
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // DESCRIPTION TEXT
                                  Expanded(
                                    flex: 1, // 35% OF THE REMAINING WIDTH
                                    child: Text(
                                      transaction.incomeRemarks,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15.sp, // FONT SIZE
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context).canvasColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w), // SPACING
                                  // TIME AGO TEXT
                                  Expanded(
                                    flex: 1, // 35% OF THE REMAINING WIDTH
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          timeAgo(transaction.incomeDate),
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12.sp, // FONT SIZE
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
                      if (index != recentIncome.length - 1)
                        Divider(
                          color: Theme.of(context).canvasColor.withOpacity(0.1),
                          thickness: 1.h, // THICKNESS
                        ),
                    ],
                  );
                }).toList(),
        ),
      ),
    );
  }
}