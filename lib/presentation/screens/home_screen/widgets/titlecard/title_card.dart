import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebaseUtils;
import 'package:moneyy/presentation/routes/routes.dart';

class TitleCardWidget extends StatefulWidget {
  final String? userId;

  const TitleCardWidget({
    super.key,
    required this.userId,
  });

  @override
  State<TitleCardWidget> createState() => _TitleCardWidgetState();
}

class _TitleCardWidgetState extends State<TitleCardWidget> {
  double todaySpending = 0.0;
  double thisMonthSpending = 0.0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchTodaySpending();
    _fetchThisMonthSpending(); // FETCH THE SPENDING WHEN THE WIDGET IS INITIALIZED
  }

  Future<void> _fetchThisMonthSpending() async {
    if (widget.userId != null) {
      try {
        double totalmonthly = await firebaseUtils.getMonthTotalSpending( widget.userId!);

        if (mounted) {
          setState(() {
            thisMonthSpending = totalmonthly;
          });
        }
      } catch (e) {
        if (mounted) {
          errorSnackbar(context, "Error while loading monthly spending");
        }      }
    }
  }

  Future<void> _fetchTodaySpending() async {
    if (widget.userId != null) {
      try {
        double total = await firebaseUtils.getTodayTotalSpending(widget.userId!);
        if (mounted) {
          setState(() {
            todaySpending = total;
          });
        }
      } catch (e) {
        if (mounted) {
          errorSnackbar(context, "Error while loading today's spending");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5.h, 0, 7.h), // PADDING
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logo_bg_removed.png'),
            fit: BoxFit.scaleDown,
            opacity: 0.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 71, 71, 71).withOpacity(0.10),
              spreadRadius: 8.r,
              blurRadius: 15.r,
              offset: Offset(0, 4.h), // CHANGES POSITION OF SHADOW
            ),
          ],
          gradient: LinearGradient(
            colors: [
              AppColors.foregroundColor.withOpacity(0.8),
              AppColors.foregroundColor,
              AppColors.foregroundColor.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MONTHLY EXPENSE TEXT
            Padding(
              padding: EdgeInsets.all(15.w),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'This month    ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    TextSpan(
                      text: ' ₹ ${thisMonthSpending.toStringAsFixed(1)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // DAILY EXPENSE TEXT
            Padding(
              padding: EdgeInsets.fromLTRB(15.w, 5.h, 15.w, 15.h),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Today               ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    TextSpan(
                      text: ' ₹ ${todaySpending.toStringAsFixed(1)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4 ICON BUTTONS
            Padding(
              padding: EdgeInsets.all(0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // INSIGHTS
                      _buildIconColumn(
                        context,
                        icon: Icons.graphic_eq,
                        label: 'Insights',
                        onPressed: () {
                          // Navigator.pushNamed(context, AppRoutes.spendingScreen);
                        },
                      ),

                      // INCOME
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.incomeScreen);
                          },
                          child: Column(
                            children: [
                              Icon(
                                Symbols.south_west,
                                color: Colors.green.shade300,
                                size: 30.sp,
                              ),
                              Text(
                                "Income",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // EXPENSES
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.spendingScreen);
                          },
                          child: Column(
                            children: [
                              Icon(
                                Symbols.north_east_rounded,
                                color: Colors.red.shade200,
                                size: 30.sp,
                              ),
                              Text(
                                "Expenses",
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // BILLS
                      _buildIconColumn(
                        context,
                        icon: Symbols.sell_rounded,
                        label: 'Bills',
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.billScreen);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _buildIconColumn(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: InkWell(
        hoverColor: Colors.yellow,
        splashColor: Colors.red,
        onTap: onPressed,
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).canvasColor.withOpacity(0.6),
              size: 30.sp,
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}