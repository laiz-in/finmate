import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/expenses/expenses_event.dart';
import 'package:moneyy/bloc/expenses/expenses_state.dart';
import 'package:moneyy/common/widgets/basicAppbar.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/screens/expenses/add_expense_dialogue.dart';
import 'package:moneyy/presentation/screens/expenses/each_card.dart';
import 'package:moneyy/presentation/screens/expenses/filter_expenses_dialogue.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({Key? key}) : super(key: key);

  @override
  SpendingScreenState createState() => SpendingScreenState();
}

class SpendingScreenState extends State<SpendingScreen> {
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';
  String? activeFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpensesBloc>().add(ResetExpensesEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _fetchExpenses() {
    context.read<ExpensesBloc>().add(FetchAllExpensesEvent());
  }

  void _clearFilters() {
    setState(() => searchQuery = '');
    context.read<ExpensesBloc>().add(ClearFiltersEvent());
  }

  void _applyDateRangeFilter(String filterType) {
    final today = DateTime.now();
    DateTime startDate;
    DateTime endDate = today;
    switch (filterType) {
      case "all":
        startDate = DateTime(2000,1,1,0,0,0,0,0);
        endDate = today;
        break;
      case "today":
        startDate = today;
        endDate = today;
        break;
      case "last week":
        startDate = today.subtract(Duration(days: 6));
        break;
      case "this month":
        startDate = DateTime(today.year, today.month, 1);
        break;
      default:
        return;
    }
    context.read<ExpensesBloc>().add(FilterByDateRangeEvent(startDate, endDate));
  }

  void _toggleFilter(String label) {
    setState(() {
      if (activeFilter == label) {
        activeFilter = null;
        _clearFilters();
      } else {
        activeFilter = label;
        _applyDateRangeFilter(label.toLowerCase());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchAndFilterBar(),
            _buildQuickFilterRow(),
            Expanded(child: _buildExpensesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
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
        ),
        backgroundColor: AppColors.foregroundColor,
        elevation: 5,
        child: Icon(Icons.add, color: Colors.white, size: 40),
      ),
    );
  }

  Widget _buildAppBar() {
    return CommonAppBar(heading: "All expenses");
  }

  Widget _buildQuickFilterRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: _buildQuickFilterButton("all"),
          ),
                    SizedBox(width: 7),

          Expanded(
            flex: 2,
            child: _buildQuickFilterButton("this month"),
          ),
          SizedBox(width: 7),
          Expanded(
            flex: 2,
            child: _buildQuickFilterButton("last week"),
          ),
          SizedBox(width: 7),
          Expanded(
            flex: 2,
            child: _buildQuickFilterButton("today"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterButton(String label) {
    bool isActive = activeFilter == label;
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _toggleFilter(label.toLowerCase()),
      child: Container(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10),
              offset: const Offset(0, 4),
              blurRadius: 7.0,
              spreadRadius: 1.0,
            ),
          ],
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: isActive
              ? Border.all(
                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                  width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
                color: Theme.of(context).canvasColor, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.fromLTRB(15, 12, 15, 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10),
            offset: const Offset(0, 4),
            blurRadius: 10.0,
            spreadRadius: 3.0,
          ),
        ],
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.search,
                      color: Theme.of(context).canvasColor.withOpacity(0.5)),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).canvasColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor:
                          Theme.of(context).canvasColor.withOpacity(0.5),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                        context
                            .read<ExpensesBloc>()
                            .add(SearchExpensesEvent(searchQuery));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: GoogleFonts.poppins(
                          color:
                              Theme.of(context).canvasColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.sort,
                        color: Theme.of(context).canvasColor, size: 30),
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => FilterBottomSheet(
                          onClearFilters: _clearFilters,
                          onSortByAmount: (ascending) {
                            context
                                .read<ExpensesBloc>()
                                .add(SortByAmountEvent(ascending));
                          },
                          onFilterByCategory: (category) {
                            context
                                .read<ExpensesBloc>()
                                .add(FilterByCategoryEvent(category));
                          },
                          onFilterByDate: (startDate, endDate) {
                            context.read<ExpensesBloc>().add(
                                FilterByDateRangeEvent(startDate, endDate));
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
  return BlocConsumer<ExpensesBloc, ExpensesState>(
    listener: (context, state) {
      if (state is ExpensesError) {
        errorSnackbar(context, state.message);
      }
    },
    builder: (context, state) {
      // Show loading indicator during initial load
      if (state is ExpensesLoading && state.isFirstFetch) {
        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2, 
            color: Theme.of(context).canvasColor
          )
        );
      }
      
      // Show loaded expenses
      else if (state is ExpensesLoaded) {
        final expenses = state.expenses;

        // Show a message if no expenses are found
        if (expenses.isEmpty) {
          return _buildEmptyExpensesMessage();
        }

        // Show the list of expenses with "Load More" button if more items are available
        return RefreshIndicator(
          backgroundColor: Colors.transparent,
          color: Colors.white,
          strokeWidth: 2,
          displacement: 50,
          onRefresh: () async {
            setState(() {
              activeFilter = "all";
            });
            context.read<ExpensesBloc>().add(RefreshExpensesEvent());
          },
          child: VsScrollbar(
            scrollbarTimeToFade: Duration(milliseconds: 800),// default : Duration(milliseconds: 600)
            controller: _scrollController, // Attach the scroll controller
            isAlwaysShown:  false, // default false
            showTrackOnHover: true,// default false
            style: VsScrollbarStyle(
              
              color: Theme.of(context).canvasColor.withOpacity(0.8),
              thickness: 5
            ),
            child: ListView.builder(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: expenses.length + (state.hasMore && searchQuery.isEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < expenses.length) {
                  final expense = expenses[index];
                  return TransactionCard(
                    transaction: expense,
                    onUpdate: () => _fetchExpenses(),
                    onDelete: () {
                      context.read<ExpensesBloc>().add(DeleteExpenseEvent(expense.uidOfTransaction));
                      _fetchExpenses();
                    },
                  );
                } 
                
                // Display "Load More" button
                else if (state.hasMore && searchQuery.isEmpty&& expenses.length >=30)
                {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ExpensesBloc>().add(LoadMoreExpensesEvent());
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Button color
                        ),
                        child: Text(
                          'Load More',
                          style: GoogleFonts.poppins(
                            color:Theme.of(context).canvasColor.withOpacity(0.7 ),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                
                // Show an empty widget if no more items are available
                else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
        );
      } 
      
      // Display error message if loading fails
      else if (state is ExpensesError) {
        return _buildErrorMessage();
      }

      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2, 
          color: Theme.of(context).canvasColor
        )
      );
    },
  );
}

  Widget _buildEmptyExpensesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.disabled_by_default,
              size: 60, color: Theme.of(context).canvasColor.withOpacity(0.2)),
          Text(
            'No Expenses Found!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).canvasColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error,
              size: 60, color: Theme.of(context).canvasColor.withOpacity(0.2)),
          Text(
            'Error while loading!',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).canvasColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}