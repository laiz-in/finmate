// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/home_screen/home_screen_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/domain/entities/auth/user.dart';
import 'package:moneyy/presentation/screens/expenses/add_expense_dialogue.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/appbar/app_bar_widget.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/loading_screen/loading_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/recent_expenses/recent_expenses_screen.dart';
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
                  color: Theme.of(context).primaryColor,
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
                              TitleCardWidget(
                                totalSpending:user.totalSpending,
                                userId: user.uid,
                              ),


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

                            RecentExpensesScreen(),


                              // RECENT TRANSACTIONS LIST

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
        elevation: 5,
        child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 35),
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
          // Navigator.pushNamed(context, '/TransactionScreen');
          },
          child: Row(
            children: [
              Text(
                'See all',
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