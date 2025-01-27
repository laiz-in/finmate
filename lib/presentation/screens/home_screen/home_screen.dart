// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/bloc/home_screen/home_screen_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/domain/entities/auth/user.dart';
import 'package:moneyy/presentation/routes/routes.dart';
import 'package:moneyy/presentation/screens/account_settings/profile_settings_main_screen.dart';
import 'package:moneyy/presentation/screens/bills/all_bills.dart';
import 'package:moneyy/presentation/screens/expenses/add_expense_dialogue.dart';
import 'package:moneyy/presentation/screens/expenses/all_expenses.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/appbar/app_bar_widget.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/loading_screen/loading_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/recent_expenses/recent_expenses_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/recent_income/recent_income_screen.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/titlecard/title_card.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/visualization/bar_chart.dart';
import 'package:moneyy/presentation/screens/home_screen/widgets/visualization/percentage_card.dart';
import 'package:moneyy/presentation/screens/income/all_income.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // TRACK THE CURRENT SELECTED TAB (0 = HOME)
  bool isRefreshing = false;

  // INITIALIZE THE HOME SCREEN WITH USER DATA FROM BLOC
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // FETCH USER DATA FROM BLOC
  Future<void> _fetchUserData() async {
    context.read<HomeScreenBloc>().add(FetchUserData());
  }

  // REFRESH THE DATA ON PULL DOWN
  Future<void> _onRefresh() async {
    setState(() {
      isRefreshing = true;
    });
    await _fetchUserData();
    setState(() {
      isRefreshing = false;
    });
  }

  // SWITCH SCREENS BASED ON THE SELECTED INDEX (BOTTOM NAVIGATION)
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 1:
        return SpendingScreen();
      case 2:
        return IncomeScreen();
      case 3:
        return BillScreen();
      case 4:
        return ProfileSettings();
      default:
        return BlocBuilder<HomeScreenBloc, HomeScreenState>(
          builder: (context, state) {
            if (state is HomeScreenLoading) {
              return ShimmerScreen(); // LOADING SCREEN IF DATA IS BEING FETCHED
            } else if (state is HomeScreenLoaded) {
              return _buildHomeContent(state.user); // BUILD HOME CONTENT WHEN DATA IS LOADED
            } else if (state is HomeScreenError) {
              return Center(child: Text("Error: ${state.message}")); // ERROR MESSAGE IF DATA FETCH FAILS
            }
            return Container(); // FALLBACK EMPTY CONTAINER
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenBloc, HomeScreenState>(
      builder: (context, state) {
        // CHECK IF THE USER DATA HAS BEEN LOADED
        if (state is HomeScreenLoaded) {
          final user = state.user; // ACCESS USER DATA SAFELY

          // BUILD THE SCREEN WITH BOTTOM NAVIGATION BAR
          return Scaffold(
            appBar: _selectedIndex == 0
                ? CustomAppBar(userName: user.firstName.toString()) // DISPLAY APPBAR ONLY ON HOME TAB
                : null,
            body: _getSelectedScreen(), // SWITCH BETWEEN SCREENS BASED ON SELECTED TAB
            bottomNavigationBar: _buildBottomNavigationBar(), // BOTTOM NAVIGATION BAR
            floatingActionButton: _selectedIndex == 0
                ? FloatingActionButton(
                    onPressed: () => _showAddExpenseModal(context), // OPEN ADD EXPENSE MODAL
                    backgroundColor: AppColors.foregroundColor,
                    child: Icon(Icons.add, color: Colors.white, size: 40.sp),
                  )
                : null, // ONLY SHOW FAB ON HOME TAB
          );
        } else if (state is HomeScreenLoading) {
          // SHOW LOADING INDICATOR WHILE USER DATA IS BEING FETCHED
          return ShimmerScreen();
        } else if (state is HomeScreenError) {
          // SHOW ERROR MESSAGE IF FETCHING USER DATA FAILS
          return Center(child: Text("Error: ${state.message}"));
        }
        return Container(); // FALLBACK EMPTY CONTAINER
      },
    );
  }

  // BOTTOM NAVIGATION BAR WITH TABS FOR DIFFERENT SCREENS
  Widget _buildBottomNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent, // REMOVE RIPPLE EFFECT
        highlightColor: Colors.transparent, // REMOVE HIGHLIGHT EFFECT
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index; // SWITCH TO SELECTED SCREEN BASED ON TAB
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        selectedItemColor: Theme.of(context).canvasColor,
        unselectedItemColor: Theme.of(context).canvasColor.withOpacity(0.3),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        iconSize: 30.sp,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
        items:  [
          // HOME SCREEN TAB
          BottomNavigationBarItem(
            icon: Icon(Symbols.cottage_rounded,weight: 800,size: 27.sp,),
            label: "",
          ),


          // INCOME SCREEN TAB
          BottomNavigationBarItem(
            icon: Icon(Symbols.north_east_rounded, weight: 600),
            label: "",
          ),


          // INCOME SCREEN TAB
          BottomNavigationBarItem(
            icon: Icon(Symbols.south_west_rounded, weight: 600),
            label: "",
          ),


          // BILL SCREEN TAB
          BottomNavigationBarItem(
            icon: Icon(Symbols.bar_chart, weight: 700),
            label: "",
          ),


          // PROFILE SCREEN TAB
          BottomNavigationBarItem(
            icon: Icon(Symbols.manage_accounts_rounded, weight: 600),
            label: "",
          ),
        ],
      ),
    );
  }

// BUILD HOME SCREEN CONTENT WITH USER DATA
Widget _buildHomeContent(UserEntity user) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.transparent,
      strokeWidth: 2,
      onRefresh: _onRefresh, // ALLOW PULL DOWN TO REFRESH DATA
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleCardWidget(userId: user.uid), // DISPLAY USER TITLE CARD
                GraphCardWidget(
                  totalSpending: user.totalSpending ?? 0.0,
                  monthlyLimit: user.monthlyLimit ?? 0.0,
                  dailyLimit: user.dailyLimit ?? 0.0,
                  userId: user.uid ?? "",
                ),
                SizedBox(height: 10.h),
                DaywiseBarchart(), // DISPLAY DAYWISE BAR CHART
                SizedBox(height: 5.h),
                TransactionHeading(
                  onViewAll: () {
                    Navigator.pushNamed(context, AppRoutes.spendingScreen);
                  },
                ),
                RecentExpensesScreen(),
                SizedBox(height: 5.h),
                IncomeHeading(
                  onViewAll: () {
                    Navigator.pushNamed(context, AppRoutes.incomeScreen);
                  },
                ),
                RecentIncomeScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

// OPEN MODAL TO ADD EXPENSE
void _showAddExpenseModal(BuildContext context) {
      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddSpendingBottomSheet(),
          );
        },
      );
    }
  }

// HELPER WIDGETS FOR RECENT EXPENSE
class TransactionHeading extends StatelessWidget {
  final VoidCallback onViewAll;

  const TransactionHeading({required this.onViewAll, super.key});

  @override
  Widget build(BuildContext context) {
    return _heading(
      context,
      title: 'Recent Expenses',
      onViewAll: onViewAll,
    );
  }
}

// HELPER WIDGETS FOR RECENT INCOME
class IncomeHeading extends StatelessWidget {
  final VoidCallback onViewAll;

  const IncomeHeading({required this.onViewAll, super.key});

  @override
  Widget build(BuildContext context) {
    return _heading(
      context,
      title: 'Recent Income',
      onViewAll: onViewAll,
    );
  }
}

// HELPER WIDGET TO BUILD HEADINGS FOR TRANSACTIONS AND INCOME
Widget _heading(BuildContext context, {required String title, required VoidCallback onViewAll}) {
  return Container(
    margin: EdgeInsets.only(top: 20.h),
    decoration: BoxDecoration(
      color: AppColors.foregroundColor,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.r),
        topRight: Radius.circular(15.r),
      ),
    ),
    child: Padding(
      padding: EdgeInsets.fromLTRB(10.w, 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Row(
              children: [
                Text(
                  'View all',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                SizedBox(width: 5.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 15.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
