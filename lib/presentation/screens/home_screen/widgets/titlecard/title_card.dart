import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebaseUtils;
import 'package:moneyy/presentation/routes/routes.dart';

class TitleCardWidget extends StatefulWidget {
  final double? totalSpending;
  final String? userId;
  

  const TitleCardWidget({
    super.key,
    required this.totalSpending,
    required this.userId,
  });

  @override
  State<TitleCardWidget> createState() => _TitleCardWidgetState();
}

class _TitleCardWidgetState extends State<TitleCardWidget> {
    double todaySpending=0.0;
    String? userId;


    @override
  void initState() {
    super.initState();
    _fetchTodaySpending(); // Fetch the spending when the widget is initialized
  }

  Future<void> _fetchTodaySpending() async {
    if (widget.userId != null) {
      double total = await firebaseUtils.getTodayTotalSpending(context, widget.userId!);
      setState(() {
        todaySpending = total;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 7),

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
              spreadRadius: 8,
              blurRadius: 15,
              offset: Offset(0, 4), // Changes position of shadow
            ),
          ],
          color: AppColors.foregroundColor,
          borderRadius: BorderRadius.circular(16.0),
        ),


        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Monthly expense text
            Padding(
              padding: EdgeInsets.all(15.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'This month    ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    TextSpan(
                      text: widget.totalSpending != null
                          ? ' ₹ ${widget.totalSpending!.toStringAsFixed(2)}'
                          : '',
                      style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daily expense text
            Padding(
              padding: EdgeInsets.fromLTRB(15.0, 5, 15, 15),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Today               ',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    TextSpan(
                    text: ' ₹ ${todaySpending.toStringAsFixed(2)}',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  ],
                ),
              ),
            ),

            // 4 Icon buttons
            Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // ALL BILLS
                      _buildIconColumn(
                        context,
                        icon: Icons.receipt,
                        label: 'Bills',
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.spendingScreen);
                        },
                      ),

                      // PERSONAL LIABILITIES
                      _buildIconColumn(
                        context,
                        icon: Icons.person_add,
                        label: 'Interpersonal',
                        onPressed: () {
                          // Navigator.pushNamed(context, '/AllIndividuals');
                        },
                      ),

                      // REMINDERS
                      _buildIconColumn(
                        context,
                        icon: Icons.alarm_add,
                        label: 'Reminders',
                        onPressed: () {
                          // Navigator.pushNamed(context, '/AllReminders');
                        },
                      ),

                      // INSIGHTS
                      _buildIconColumn(
                        context,
                        icon: Icons.graphic_eq,
                        label: 'Insights',
                        onPressed: () {
                          // Navigator.pushNamed(context, '/AllStatistics');
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

  Column _buildIconColumn(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: Theme.of(context).canvasColor.withOpacity(0.6),
            size: 25,
          ),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).canvasColor,
          ),
        ),
      ],
    );
  }
}
