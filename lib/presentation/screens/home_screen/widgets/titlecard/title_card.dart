import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
    double todaySpending=0.0;
    double thisMonthSpending=0.0;
    String? userId;


    @override
  void initState() {
    super.initState();
    _fetchTodaySpending();
    _fetchThisMonthSpending(); // Fetch the spending when the widget is initialized
  }

Future<void> _fetchThisMonthSpending() async {
  if (widget.userId != null) {
    try {
      double totalmonthly = await firebaseUtils.getMonthTotalSpending(context, widget.userId!);

      if (mounted) {
        setState(() {
          thisMonthSpending = totalmonthly;
        });

      }
    } catch (e) {
      print("error hile loading totals total soending");
    }
  }
}

Future<void> _fetchTodaySpending() async {
  if (widget.userId != null) {
    try {
      double total = await firebaseUtils.getTodayTotalSpending(context, widget.userId!);
      if (mounted) {
        setState(() {
          todaySpending = total;
        });
      }
    } catch (e) {
      print("errro while loading totals total soending");
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 7),

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
            gradient: LinearGradient(
                colors: [
                  AppColors.foregroundColor.withOpacity(0.8),
                  AppColors.foregroundColor,
                  AppColors.foregroundColor.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),          borderRadius: BorderRadius.circular(16.0),
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
                      text: ' ₹ ${thisMonthSpending.toStringAsFixed(1)}',

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
                    text: ' ₹ ${todaySpending.toStringAsFixed(1)}',
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
                        icon: Icons.graphic_eq,
                        label: 'Insights',
                        onPressed: () {
                          // Navigator.pushNamed(context, AppRoutes.spendingScreen);
                        },
                      ),
                  
                      // INCOME
                      Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                      
                        onTap: (){ Navigator.pushNamed(context, AppRoutes.incomeScreen);},
                        child: Column(
                          children: [
                            Icon(Symbols.south_west,color: Colors.green.shade300,size: 30,),
                      
                                Text(
                                "Income",
                                style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                      // Expenses
                      Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                      
                        onTap: (){ Navigator.pushNamed(context, AppRoutes.spendingScreen);},
                        child: Column(
                          children: [
                            Icon(Symbols.north_east_rounded,color: Colors.red.shade200,size: 30,),
                      
                                Text(
                                "Expenses",
                                style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).canvasColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                      // INSIGHTS
                      _buildIconColumn(
                        context,
                        icon: Symbols.sell_rounded,
                        label: 'Bills',
                        onPressed: () {
                          // Navigator.pushNamed(context, '/AllStatistics');
                          
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
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        hoverColor:Colors.yellow,
        splashColor: Colors.red,
        
        onTap: onPressed,
        child: Column(
          children: [
            Icon(icon,
                color: Theme.of(context).canvasColor.withOpacity(0.6),
                size: 30,
                ),
      
                Text(
                label,
                style: GoogleFonts.poppins(
                fontSize: 13,
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
