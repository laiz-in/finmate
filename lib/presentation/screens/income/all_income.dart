import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:moneyy/bloc/income/income_bloc.dart';
import 'package:moneyy/bloc/income/income_event.dart';
import 'package:moneyy/bloc/income/income_state.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/screens/income/add_income_dialogue.dart';
import 'package:moneyy/presentation/screens/income/each_income.dart';
import 'package:moneyy/presentation/screens/income/filter_income_dialogue.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  IncomeScreenState createState() => IncomeScreenState();
}

class IncomeScreenState extends State<IncomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController(); // Add this

  String searchQuery = '';
  String? activeFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncomeBloc>().add(ResetIncomeEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
    
  }

  void _fetchIncome() {
    context.read<IncomeBloc>().add(FetchAllIncomeEvent());
  }

  void _clearFilters() {
    setState(() => searchQuery = '');
    context.read<IncomeBloc>().add(ClearFiltersEvent());
  }

  void _applyDateRangeFilter(String filterType) {
  final today = DateTime.now();
  DateTime startDate;
  DateTime endDate = today;

  switch (filterType) {
    case "load all":
      context.read<IncomeBloc>().add(FetchCompleteIncomeEvent());
      return; // Return early as we don't need to filter by date.
    case "today":
      startDate = today;
      endDate = today;
      break;

    case "this month":
      startDate = DateTime(today.year, today.month, 1);
      break;
    default:
      return;
  }

  context.read<IncomeBloc>().add(FilterByDateRangeEvent(startDate, endDate));
}

  void _toggleFilter(String label) {
  setState(() {
    if (activeFilter?.toLowerCase() == label.toLowerCase()) {
      activeFilter = null;
      _clearFilters();
    } else {
      activeFilter = label; // Store original case
      _applyDateRangeFilter(label.toLowerCase());
    }
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            
      // APP BAR
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.h), // ADJUST THIS HEIGHT AS NEEDED
        child: AppBar(
          automaticallyImplyLeading: false, // Disable automatic back button
          scrolledUnderElevation: 0,
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Container(
            alignment: Alignment.bottomLeft, // ALIGN TITLE TO THE BOTTOM-LEFT
            child: Text(
              ' Income ',
              style: GoogleFonts.poppins(
                fontSize: 22.sp, // FONT SIZE
                fontWeight: FontWeight.w500,
                color: Theme.of(context).canvasColor,
              ),
            ),
          ),
        ),
      ),

      // MAIN BODY
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchAndFilterBar(),
            _buildQuickFilterRow(),
            Expanded(child: _buildExpensesList()),
          ],
        ),
      ),
      
      // FLOATING ACTION BUTTON
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
              child: AddIncomeBottomSheet(),
            );
          },
        ),
        backgroundColor: AppColors.foregroundColor,
        elevation: 5,
        child: Icon(Icons.add, color: Colors.white, size: 40.sp), // ICON SIZE
      ),
    );
  }


  Widget _buildQuickFilterRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 15.h, 15.w, 10.h), // PADDING
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: _buildQuickFilterButton("Load all"),
          ),
          SizedBox(width: 7.w), // SPACING
          Expanded(
            flex: 2,
            child: _buildQuickFilterButton("this month"),
          ),
          SizedBox(width: 7.w), // SPACING

          Expanded(
            flex: 2,
            child: _buildQuickFilterButton("today"),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterButton(String label) {
  bool isActive = activeFilter?.toLowerCase() == label.toLowerCase();
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _toggleFilter(label.toLowerCase()),
      child: Container(
        padding: EdgeInsets.only(top: 12.h, bottom: 12.h), // PADDING
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10),
              offset: const Offset(0, 4),
              blurRadius: 7.0.r, // BLUR RADIUS
              spreadRadius: 1.0.r, // SPREAD RADIUS
            ),
          ],
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(15.r)), // RADIUS
          border: isActive
              ? Border.all(
                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                  width: 1.w, // BORDER WIDTH
                )
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Theme.of(context).canvasColor,
              fontSize: 12.sp, // FONT SIZE
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.fromLTRB(15.w, 12.h, 15.w, 0), // MARGIN
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 65, 64, 64).withOpacity(0.10),
            offset: const Offset(0, 4),
            blurRadius: 10.0.r, // BLUR RADIUS
            spreadRadius: 3.0.r, // SPREAD RADIUS
          ),
        ],
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(15.r)), // RADIUS
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0.w), // PADDING
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0.r), // RADIUS
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Theme.of(context).canvasColor.withOpacity(0.5),
                  ),
                  SizedBox(width: 10.0.w), // SPACING
                  Expanded(
                    child: TextField(
                      controller: _searchController, // Add the controller here

                      style: GoogleFonts.poppins(
                        color: Theme.of(context).canvasColor,
                        fontSize: 15.sp, // FONT SIZE
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: Theme.of(context).canvasColor.withOpacity(0.5),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                        context.read<IncomeBloc>().add(SearchIncomeEvent(searchQuery));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          fontSize: 14.sp, // FONT SIZE
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.sort,
                      color: Theme.of(context).canvasColor,
                      size: 30.sp, // ICON SIZE
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.r), // RADIUS
                            topRight: Radius.circular(30.r), // RADIUS
                          ),
                        ),
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => IncomeFilterBottomSheet(
                          onClearFilters: _clearFilters,
                          onSortByAmount: (ascending) {
                            context.read<IncomeBloc>().add(SortByAmountEvent(ascending));
                          },
                          onFilterByCategory: (category) {
                            context.read<IncomeBloc>().add(FilterByCategoryEvent(category));
                          },
                          onFilterByDate: (startDate, endDate) {
                            context.read<IncomeBloc>().add(FilterByDateRangeEvent(startDate, endDate));
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
    return BlocConsumer<IncomeBloc, IncomeState>(
      listener: (context, state) {
        if (state is IncomeError) {
          errorSnackbar(context, state.message);
        }
      },
      builder: (context, state) {
        // SHOW LOADING INDICATOR DURING INITIAL LOAD
        if (state is IncomeLoading && state.isFirstFetch) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.w, // STROKE WIDTH
              color: Theme.of(context).canvasColor,
            ),
          );
        }

        // SHOW LOADED EXPENSES
        else if (state is IncomeLoaded) {
          final income = state.income;

          // SHOW A MESSAGE IF NO EXPENSES ARE FOUND
          if (income.isEmpty) {
            return _buildEmptyExpensesMessage();
          }

          // SHOW THE LIST OF EXPENSES WITH "LOAD MORE" BUTTON IF MORE ITEMS ARE AVAILABLE
          return RefreshIndicator(
            backgroundColor: Colors.transparent,
            color: Colors.white,
            strokeWidth: 2.w, // STROKE WIDTH
            displacement: 50.h, // DISPLACEMENT
            onRefresh: () async {
          setState(() {
            activeFilter = null; // Reset active filter on pull-down refresh
            searchQuery = ''; // Also reset search query if needed
            _searchController.clear(); // Clear the actual text field
          });
          context.read<IncomeBloc>().add(RefreshIncomeEvent());
        },
            child: VsScrollbar(
              scrollbarTimeToFade: Duration(milliseconds: 800), // SCROLLBAR FADE DURATION
              controller: _scrollController, // ATTACH THE SCROLL CONTROLLER
              isAlwaysShown: false, // DEFAULT FALSE
              showTrackOnHover: true, // DEFAULT FALSE
              style: VsScrollbarStyle(
                color: Theme.of(context).canvasColor.withOpacity(0.8),
                thickness: 5.w, // THICKNESS
              ),
              child: ListView.builder(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: income.length + (state.hasMore && searchQuery.isEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < income.length) {
                    final incomes = income[index];
                    return IncomeCard(
                      transaction: incomes,
                      onUpdate: () => _fetchIncome(),
                      onDelete: () {
                        context.read<IncomeBloc>().add(DeleteIncomeEvent(incomes.uidOfIncome));
                        _fetchIncome();
                      },
                    );
                  }

                  // DISPLAY "LOAD MORE" BUTTON
                  else if (state.hasMore && searchQuery.isEmpty && income.length >= 30) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0.w), // PADDING
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<IncomeBloc>().add(LoadMoreIncomeEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Theme.of(context).scaffoldBackgroundColor, // BUTTON COLOR
                          ),
                          child: Text(
                            'Load More',
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).canvasColor.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp, // FONT SIZE
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // SHOW AN EMPTY WIDGET IF NO MORE ITEMS ARE AVAILABLE
                  else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
          );
        }

        // DISPLAY ERROR MESSAGE IF LOADING FAILS
        else if (state is IncomeError) {
          return _buildErrorMessage();
        }

        return Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.w, // STROKE WIDTH
            color: Theme.of(context).canvasColor,
          ),
        );
      },
    );
  }

  Widget _buildEmptyExpensesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.search_off,
            size: 80.sp, // ICON SIZE
            color: Theme.of(context).canvasColor.withOpacity(0.2),
          ),
          Text(
            'No Income Found!',
            style: GoogleFonts.poppins(
              fontSize: 14.sp, // FONT SIZE
              fontWeight: FontWeight.w400,
              color: Theme.of(context).canvasColor.withOpacity(0.5),
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
          Icon(
            Icons.error,
            size: 60.sp, // ICON SIZE
            color: Theme.of(context).canvasColor.withOpacity(0.2),
          ),
          Text(
            'Error while loading!',
            style: GoogleFonts.poppins(
              fontSize: 18.sp, // FONT SIZE
              fontWeight: FontWeight.w500,
              color: Theme.of(context).canvasColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}