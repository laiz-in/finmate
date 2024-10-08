// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/domain/entities/auth/user.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/appbar/app_bar_widget.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/loading_screen/loading_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/titlecard/title_card.dart';


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
    // Dispatch the event to fetch user data
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
            return ShimmerScreen(); // Show shimmer effect while loading
          
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
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColorDark,
                          strokeWidth: 2,
                        ),
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
                                totalSpending:user.monthlyLimit,
                                todaySpending: user.dailyLimit,
                              ),


                              // PERCENTAGE INDICATOR
//                               GraphCardWidget(
//   todaySpending: user.todaySpending,
//   totalSpending: user.totalSpending,
//   monthlyLimit: user,monthlyLimit,
//   dailyLimit: dailyLimit,
//   allTransactions: allTransactions,
// ),

                              // RECENT TRANSACTION HEADING

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
          // showDialog(
          //   context: context,
          //   builder: (context) => Dialog(
          //     backgroundColor: Colors.transparent,
          //     insetPadding: EdgeInsets.all(25),
          //     child: AddSpendingBottomSheet(), // Renamed as AddSpendingDialog for clarity
          //   ),
          // );
        },
        backgroundColor: Theme.of(context).cardColor,
        elevation: 5,
        child: Icon(Icons.add, color: Theme.of(context).primaryColor, size: 35),
      ),
    );
  }
}
