// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/home_screen/home_screen_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/domain/entities/auth/user.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/expenses/add_expense_dialogue.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/appbar/app_bar_widget.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/loading_screen/loading_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/recent_expenses/recent_expenses_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/recent_income/recent_income_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/titlecard/title_card.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/visualization/bar_chart.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/visualization/percentage_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isRefreshing = false;
  

  @override
  void initState() {
    super.initState();
    context.read<HomeScreenBloc>().add(FetchUserData());
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isRefreshing = true;
    });
    context.read<HomeScreenBloc>().add(FetchUserData());
    
    setState(() {
      isRefreshing = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeScreenBloc, HomeScreenState>(
        builder: (context, state) {
          if (state is HomeScreenLoading) {
            return ShimmerScreen();
            // Show shimmer effect while loading
          } else if (state is HomeScreenLoaded) {
            
            final UserEntity user = state.user;

            return Scaffold(
              appBar: CustomAppBar(userName: user.firstName.toString()),

              body: Center(
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.transparent.withOpacity(0.0),
                  strokeWidth: 2,
                  onRefresh: _fetchUserData,

                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,

                    child:isRefreshing
                    ? Center(
                        
                      ): ListView(
                      children: [
                        // Display user information
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // TITLE CARD
                              TitleCardWidget(userId: user.uid,),


                              //PERCENTAGE INDICATOR
                              GraphCardWidget(
                                              totalSpending: user.totalSpending ?? 0.0,
                                              monthlyLimit: user.monthlyLimit ?? 0.0,
                                              dailyLimit: user.dailyLimit ?? 0.0,
                                              userId: user.uid?? "",
                              ),


                              // BAR CHART FOR LAST 7 DAYS
                              SizedBox(height: 10,),
                              DaywiseBarchart(),


                              // RECENT TRANSACTION HEADING
                              _transactionHeading(context),
                            
                              // RECENT EXPENSES SHOWING
                              RecentExpensesScreen(),

                              // RECENT INCOME HEADING
                              _incomeHeading(context),
                            
                              // RECENT INCOME SHOWING
                              RecentIncomeScreen(),


                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ),
            );
          
          } else if (state is HomeScreenError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          return Container(); // Fallback empty container
        },
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true, // Allows the modal to extend beyond half the screen
                        backgroundColor: Colors.transparent, // Set transparent if you want rounded corners without clipping
                        builder: (BuildContext context) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: AddSpendingBottomSheet(),
                              );
                            },
                          ),
        backgroundColor: AppColors.foregroundColor,
        elevation: 5,
        child: Icon(Icons.add, color: Colors.white, size: 40),
    ),



    );
  }
}


Widget _transactionHeading(context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Recent expenses',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Theme.of(context).canvasColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.spendingScreen);
          },
          child: Row(
            children: [
              Text(
                'View all',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).canvasColor,
                ),
              ),
              SizedBox(width: 5,),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Theme.of(context).canvasColor,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _incomeHeading(context) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Recent income',
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Theme.of(context).canvasColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.incomeScreen);
          },
          child: Row(
            children: [
              Text(
                'View all',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).canvasColor,
                ),
              ),
              SizedBox(width: 5,),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
                color: Theme.of(context).canvasColor,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}