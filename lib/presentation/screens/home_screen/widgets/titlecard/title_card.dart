import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebaseUtils;

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
  double thisMonthIncome = 0.0;
  double todayIncome = 0.0;

  String? userId;

  @override
  void initState() {
    super.initState();
    _fetchTodaySpending();
    _fetchTodayTotalIncome();
    _fetchThisMonthIncome();
    _listenToThisMonthSpending();
  }

    void _listenToThisMonthSpending() {
    if (widget.userId != null) {
      firebaseUtils.getMonthTotalSpending(widget.userId!).listen((total) {
        if (mounted) {
          setState(() {
            thisMonthSpending = total;
          });
        }
      }, onError: (e) {
        if (mounted) {
          errorSnackbar(context, "Error while loading monthly spending");
        }
      });
    }
  }
  Future<void> _fetchThisMonthIncome() async {
    if (widget.userId != null) {
      try {
        double totalmonthlyincome = await firebaseUtils.getMonthTotalIncome( widget.userId!);
        if (mounted) {
          setState(() {
            thisMonthIncome = totalmonthlyincome;
          });
        }
      } catch (e) {
        if (mounted) {
          errorSnackbar(context, "Error while loading monthly income");
        }      }
    }
  }

  Future<void> _fetchTodayTotalIncome() async {
    if (widget.userId != null) {
      try {
        double todayincome = await firebaseUtils.getTodayTotalIncome( widget.userId!);

        if (mounted) {
          setState(() {
            todayIncome = todayincome;
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

    String currentMonth = DateFormat("MMMM'yy").format(DateTime.now());
    String currentYear = DateFormat('yy').format(DateTime.now());


    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 7.h), // PADDING
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
          
            
 // MONTHLY TEXT
  Padding(
  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0.h),
  child: Padding(
    padding: EdgeInsets.all(5.w), // Padding inside the container
    child: Row(
      children: [
        // Current Month Text (30%)
        Expanded(
          flex: 3, // 30%
          child: Text(
            '$currentMonth\'$currentYear',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      
        SizedBox(width: 15.w,),
        // Spending and Income Column (70%)
        Expanded(
          flex: 7, // 70%
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.north_east_rounded,
                    color: Colors.red.shade100,
                    size: 25.sp,
                  ),
                  SizedBox(width: 5.w), // Spacing between icon and text
                  Expanded(
                    child: Text(
                      '₹${thisMonthSpending.toStringAsFixed(0)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Symbols.south_west,
                    color: Colors.green.shade100,
                    size: 25.sp,
                  ),
                  SizedBox(width: 5.w), // Spacing between icon and text
                  Expanded(
                    child: Text(
                      '₹${thisMonthIncome.toStringAsFixed(0)}',
                      style: GoogleFonts.montserrat(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),

          
 // DAILY TEXT
  Padding(
  padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 10.h),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(15.r), // To clip the backdrop filter
    child: Padding(
      padding: EdgeInsets.all(5.w), // Padding inside the container
      child: Row(
        children: [
          // Current Month Text (30%)
          Expanded(
            flex: 3, // 30%
            child: Text(
              'Today',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.5),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
    
          SizedBox(width: 15.w,),
          // Spending and Income Column (70%)
          Expanded(
            flex: 7, // 70%
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.north_east_rounded,
                      color: Colors.red.shade100,
                      size: 25.sp,
                    ),
                    SizedBox(width: 5.w), // Spacing between icon and text
                    Expanded(
                      child: Text(
                        '₹${todaySpending.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Symbols.south_west,
                      color: Colors.green.shade100,
                      size: 25.sp,
                    ),
                    SizedBox(width: 5.w), // Spacing between icon and text
                    Expanded(
                      child: Text(
                        '₹${todayIncome.toStringAsFixed(0)}',
                        style: GoogleFonts.montserrat(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
          Expanded(
            child: _buildIconColumn(
              context,
              icon: Icons.graphic_eq,
              label: 'Insights',
              onPressed: () {
                // Navigator.pushNamed(context, AppRoutes.spendingScreen);
              },
            ),
          ),

          Expanded(
            child: _buildIconColumn(
              context,
              icon: Symbols.swap_vert,
              label: 'Liability',
              onPressed: () {
                // Navigator.pushNamed(context, AppRoutes.spendingScreen);
              },
            ),
          ),

          Expanded(
            child: _buildIconColumn(
              context,
              icon: Symbols.bar_chart,
              label: 'Stats',
              onPressed: () {
                // Navigator.pushNamed(context, AppRoutes.billScreen);
              },
            ),
          ),


          Expanded(
            child: _buildIconColumn(
              context,
              icon: Symbols.diversity_3,
              label: 'Groups',
              onPressed: () {
                // Navigator.pushNamed(context, AppRoutes.spendingScreen);
              },
            ),
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
        onTap: onPressed,
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).canvasColor.withOpacity(0.6),
              size: 30.sp,
              weight: 600,
            ),
            SizedBox(height: 5.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
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