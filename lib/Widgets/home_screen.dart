// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/firebase/firebase_utils.dart' as firebase_utils;
import 'package:moneyy/ui/error_snackbar.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../firebase/firebase_utils.dart';
import '../firebase/user_service.dart';
import './transactions/add_spending_screen.dart';
import 'chart_graph_screens/daywise_barchart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserService _userService = UserService();
  List<CustomTransaction> _transactions = [];

  String? userName, userId;
  double? totalSpending,todaySpending,monthlyLimit,dailyLimit, dailyLimitPerecentage,monthlyLimitPercentage;
  bool isLoading = true;
  List<firebase_utils.CustomTransaction> recentTransactions = [];
  List<firebase_utils.CustomTransaction> allTransactions = [];


  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }


// Funtion to fetch user data
Future<void> _fetchUserData() async {
    try {
      final userData = await _userService.fetchUserData(context);

      if (mounted) {
        setState(() {
          userId = userData['userId'];
          userName = userData['userName'];
          totalSpending = userData['totalSpending'];
          monthlyLimit = userData['monthlyLimit'];
          dailyLimit = userData['dailyLimit'];
          todaySpending = userData['todaySpending'];
          recentTransactions = userData['recentTransactions'];
          isLoading = false;
        });
      }

      if (userId != null) {
        List<CustomTransaction> transactions = await getAllSpendings(context, userId!);
        if (mounted) {
          setState(() {
            allTransactions = transactions;
          });
        }
      }
    } catch (e) {
      if (mounted) {
      errorSnackbar(context, "Error fetching user data");
    }
  }
}



@override
Widget build(BuildContext context) {
  return Scaffold(
  backgroundColor: Theme.of(context).primaryColor,
      
      // App bar
      appBar: AppBar(
      toolbarHeight: 100,
      scrolledUnderElevation:0,
      automaticallyImplyLeading: false,
      backgroundColor:Theme.of(context).primaryColor,
      // Title text
      title:
      Container(
        padding: EdgeInsets.fromLTRB(5,8,0,0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Welcome back !',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).cardColor.withOpacity(0.6),
                ),
              ),
            Text(
                '${userName ?? ''} ',
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).cardColor,
                ),
              ),
          ],
        ),
      ),
      // Action button
      actions: [IconButton(
        icon: Icon(Icons.notification_add_outlined, color: Theme.of(context).cardColor,size: 25,),
        onPressed: () {
          // Add your notification logic here
        },
      ),
        IconButton(
          icon: Icon(Icons.person_outlined, color: Theme.of(context).cardColor,size: 25,),
          onPressed: () {
            Navigator.pushNamed(context, '/ProfileScreen');
          },
        ),
        SizedBox(width: 20,),
      ],
    ),

  // Body of the home screen with pull-to-refresh
  body: RefreshIndicator(
      color: Theme.of(context).cardColor,
      backgroundColor: Colors.white,
      strokeWidth: 2,
      onRefresh: _fetchUserData,
      child: Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColorDark,
                    strokeWidth: 2,
                  ),
                )
              : ListView(
                
                  children: [
                    // First Row title card
                    _titleCard(context, totalSpending, todaySpending),
                    SizedBox(height: 10,),

                    // Graph card
                    _graphCard(context,todaySpending,totalSpending,monthlyLimit, dailyLimit,allTransactions),

                    // Recent Transactions card
                    _transactionHeading(context),
                    _recentTransactionCard(recentTransactions, context),

                    SizedBox(height: 15,),
                  ],
                ),
        ),
      ),
    ),
  
        // floating button
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(25),
              child: AddSpendingBottomSheet(), // Renamed as AddSpendingDialog for clarity
            ),
          );
        },
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 35),
      ),

    );
  }
}


// MAIN TITLE CARD
Widget _titleCard(context, double? totalSpending, double? todaySpending){
    return Padding(
      
              padding: const EdgeInsets.fromLTRB(15,15,15,7),
              child: Container(
                
                decoration: BoxDecoration(
                image: DecorationImage(
                image: AssetImage('assets/images/logo_bg_removed.png'),
                fit:BoxFit.scaleDown,
                opacity: 0.3,),

                boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 71, 71, 71).withOpacity(0.18),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: Offset(0, 4), // changes position of shadow
                ),],

                color: Theme.of(context).cardColor,
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
                        style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                        ),
                        TextSpan(
                        text: totalSpending != null ? ' ₹ ${totalSpending.toStringAsFixed(2)}' : '',
                        style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                        ),
                        ),
                      ],
                    ),
                  )
                ),
                    
                    // Daily expense text
                    Padding(
                    padding:  EdgeInsets.fromLTRB(15.0,5,15,15),
                    child: RichText(
                    text: TextSpan(
                    children: [
                        
                        TextSpan(
                        text: 'Today               ',
                        style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                        ),

                        TextSpan(
                        text: todaySpending != null ? ' ₹ ${todaySpending.toStringAsFixed(2)}' : '',
                        style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                        ),
                        ),
                      ],
                    ),
                  )
                ),

                    // 4 Icon buttons
                    Padding(
                    padding: const EdgeInsets.all(0),
                    child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorDark,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          // Bills to pay
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.receipt,color: Theme.of(context).cardColor.withOpacity(0.6),size: 33,),
                              onPressed: () {
                              Navigator.pushNamed(context, '/AllBillsScreen');
                              },
                              ),
                              Text(
                                'Bills',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                            ],
                          ),

                          // Individual transactions
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.person_add,color: Theme.of(context).cardColor.withOpacity(0.6),size: 35,),
                                onPressed: () {
                              Navigator.pushNamed(context, '/AllIndividuals');
                              },
                              ),
                              Text(
                                'Interpersonal',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                            ],
                          ),

                          // Reminders
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.alarm_add,color: Theme.of(context).cardColor.withOpacity(0.6),size: 35,),
                                onPressed: () {
                                Navigator.pushNamed(context, '/AllReminders');

                                },
                              ),
                              Text(
                                'Reminders',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                            ],
                          ),

                          // Statistics
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.graphic_eq,color: Theme.of(context).cardColor.withOpacity(0.6),size: 35,),
                                onPressed: () {
                                Navigator.pushNamed(context, '/AllStatistics');
                                },
                              ),
                              Text(
                                'Insights',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
}

// RECENT TRANSACTION CARD
Widget _recentTransactionCard(List<CustomTransaction> recentTransactions, BuildContext context) {
  DateTime now = DateTime.now();

  // Function to find time ago
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
    padding: EdgeInsets.fromLTRB(15,0,15,0),
  child: Container(
    padding: EdgeInsets.fromLTRB(15,0,15,0),
    decoration: BoxDecoration(
      boxShadow: [
      BoxShadow(
        color: const Color.fromARGB(255, 49, 49, 49).withOpacity(0.25),
        spreadRadius: 5,
        blurRadius: 15,
        offset: Offset(0, 4), // changes position of shadow
      ),
    ],
      color: Theme.of(context).primaryColorDark,
      borderRadius: BorderRadius.circular(15.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: recentTransactions.isEmpty
          ? [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "No transactions found..",
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
            ]
          : recentTransactions.asMap().entries.map((entry) {
              int index = entry.key;
              CustomTransaction transaction = entry.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2,8,8,8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Amount text
                        Expanded(
                          flex: 3, // 30% of the width
                          child: Row(
                            children: [
                              Icon(Icons.arrow_outward,color: Colors.red.shade200,),
                            
                              Text(
                                '₹${transaction.spendingAmount.toStringAsFixed(1)}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
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
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).cardColor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              // Time ago text
                              Expanded(
                                flex: 1, // 35% of the remaining width
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children:[
                                  Text(
                                  timeAgo(transaction.date),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).cardColor.withOpacity(0.8),
                                  ),
                                ),]
                              ),

                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (index != recentTransactions.length - 1)
                    Divider(color: Color.fromARGB(255, 154, 184, 169)),
                ],
              );
            }).toList(),
    ),
  ),
);

}

// TRANSACTION HEADING
Widget _transactionHeading(context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Recent expenses',
          style: GoogleFonts.montserrat(
            fontSize: 15,
            color: Theme.of(context).cardColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: () {
          Navigator.pushNamed(context, '/TransactionScreen');
          },
          child: Row(
            children: [
              Text(
                'See all',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).cardColor,
                ),
              ),
              SizedBox(width: 5,),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Theme.of(context).cardColor,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// GRAPHS
Widget _graphCard(context,double? todaySpending, double? totalSpending, double? monthlyLimit, double? dailyLimit ,allTransactions) {

  final dailySpendingPercentage  = (todaySpending!/dailyLimit!) *100;
  final monthlyLimitPercentage = (totalSpending!/monthlyLimit!) *100;
  double dailySpendingPercentageForGraph =0;

  if((dailySpendingPercentage/100) >1){
    dailySpendingPercentageForGraph =1.0;
  }
  else{
    dailySpendingPercentageForGraph = dailySpendingPercentage/100;
  }

  return Padding(
    padding: const EdgeInsets.all(15),
    
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 49, 49, 49).withOpacity(0.10),
                  spreadRadius: 5,
                  blurRadius: 5,
                  offset: Offset(0, 4), // changes position of shadow
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(25)),

              ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,


            children: [
              Row(
              children: [

              // circular progress indicator for monthly limit
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25.0),
                  ),
                width: MediaQuery.of(context).size.width * 0.43,
                height: 200,
                child: Column(
                children: [
                  SizedBox(height: 10,),
                  Text('Monthly limit'
                  ,style: GoogleFonts.montserrat(color: Theme.of(context).cardColor,fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 12.0), // Add some space between children
                  CircularPercentIndicator(
                    radius: 50.0,
                    lineWidth: 10.0,
                    percent:monthlyLimitPercentage/100 ,
                    center: Text('${monthlyLimitPercentage.toStringAsFixed(0)}%',
                    style: GoogleFonts.montserrat(color: Theme.of(context).cardColor,fontSize: 18, fontWeight: FontWeight.w800),),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor:Theme.of(context).cardColor,
                    backgroundColor: Theme.of(context).cardColor.withOpacity(0.3),
                  ),
                ],
              ),
              ),
          
              // Cicular progress indicator for daily limit
              Container(
                decoration: BoxDecoration(
                  color:Theme.of(context).primaryColorDark,
                  borderRadius: BorderRadius.circular(25.0),
                  ),
                width: MediaQuery.of(context).size.width * 0.43,
                height: 165,
                child: Column(
                children: [
                  Text('Daily limit'
                  ,style: GoogleFonts.montserrat(color:Theme.of(context).cardColor,fontWeight: FontWeight.w700),
                  ),

                  SizedBox(height: 12.0), // Add some space between children
                  CircularPercentIndicator(
                    radius: 50.0,
                    lineWidth: 10.0,
                    percent: dailySpendingPercentageForGraph,
                    center: Text('${dailySpendingPercentage?.toStringAsFixed(0)}%',
                    style: GoogleFonts.montserrat(color: Theme.of(context).cardColor, fontWeight: FontWeight.w800,fontSize: 18),),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor:Theme.of(context).cardColor,
                    backgroundColor: Theme.of(context).cardColor.withOpacity(0.3),
                  ),
                  SizedBox(height: 5,),
                  Text( '${todaySpending.toStringAsFixed(1)}/${dailyLimit.toStringAsFixed(0)}'
                  ,style: GoogleFonts.montserrat(color:Theme.of(context).cardColor.withOpacity(0.8),fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              ),
              ]
              ),

              DaywiseBarchart(transactions: allTransactions),

            
            ],
          ),
        ),
      ),
    
  );
}



