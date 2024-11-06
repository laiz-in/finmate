import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/expenses/expenses_event.dart';
import 'package:moneyy/bloc/expenses/expenses_state.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/core/colors/colors.dart';
import 'package:moneyy/presentation/screens/expenses/add_expense_dialogue.dart';
import 'package:moneyy/presentation/screens/expenses/each_card.dart';
import 'package:moneyy/presentation/screens/expenses/filter_expenses_dialogue.dart';
import 'package:moneyy/presentation/widgets/common_appbar.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({Key? key}) : super(key: key);

  @override
  SpendingScreenState createState() => SpendingScreenState();
}

class SpendingScreenState extends State<SpendingScreen> {
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';

  @override
void initState() {
  super.initState();
  _scrollController.addListener(_onScroll);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<ExpensesBloc>().add(ResetExpensesEvent());
  });
}

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<ExpensesBloc>().add(FetchMoreExpensesEvent());
    }
  }

  void _fetchExpenses() {
    context.read<ExpensesBloc>().add(FetchAllExpensesEvent());
  }

  void _clearFilters() {
    setState(() => searchQuery = '');
    context.read<ExpensesBloc>().add(ClearFiltersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarCommon(title: 'All expenses'),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(child: _buildExpensesList()),
        ],
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

  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Theme.of(context).canvasColor.withOpacity(0.5)),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: TextField(
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).canvasColor,
                        fontSize: 15,fontWeight:FontWeight.w500
                      ),
                      cursorColor: Theme.of(context).canvasColor.withOpacity(0.5),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                        context.read<ExpensesBloc>().add(SearchExpensesEvent(searchQuery));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: GoogleFonts.poppins(
                          color: Theme.of(context).canvasColor.withOpacity(0.5),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.sort, color: Theme.of(context).canvasColor, size: 30),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => FilterDialog(
                          onClearFilters: _clearFilters,
                          onSortByAmount: (ascending) {
                            context.read<ExpensesBloc>().add(SortByAmountEvent(ascending));
                          },
                          onFilterByCategory: (category) {
                            context.read<ExpensesBloc>().add(FilterByCategoryEvent(category));
                          },
                          onFilterByDate: (startDate, endDate) {
                            context.read<ExpensesBloc>().add(FilterByDateRangeEvent(startDate, endDate));
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

      if (state is ExpensesLoading && state.isFirstFetch) {
        return Center(child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).canvasColor));
      }
      
      else if (state is ExpensesLoaded) {
        final expenses = state.expenses;

        if (expenses.isEmpty) return _buildEmptyExpensesMessage();


        return RefreshIndicator(
          backgroundColor: Colors.transparent,color: Colors.white,strokeWidth: 2,
          onRefresh: () async {
            context.read<ExpensesBloc>().add(RefreshExpensesEvent());
          },

          child: ListView.builder(
            controller: _scrollController,
            itemCount: expenses.length + (state.hasMore ? 1 : 0),

            itemBuilder: (context, index) {
              if (index < expenses.length) {
                final expense = expenses[index];
                return TransactionCard(
                  transaction: expense,
                  onUpdate: () => _fetchExpenses(),
                  onDelete: () => _fetchExpenses(),
                );
              }
              else if (state.hasMore) {
                return Center(child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).canvasColor));

              }
              else {
                return SizedBox.shrink(); // Don't show loading indicator if there are no more items
              }
            },
          ),
        );
      } else if (state is ExpensesError) {
        return _buildErrorMessage();
      }
        return Center(child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).canvasColor));
    },
  );
}
  Widget _buildEmptyExpensesMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.disabled_by_default, size: 60, color: Theme.of(context).canvasColor.withOpacity(0.2)),
          Text(
            'No Expenses Found!',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).canvasColor.withOpacity(0.7)),
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
          Icon(Icons.error, size: 60, color: Theme.of(context).canvasColor.withOpacity(0.2)),
          Text(
            'Error while loading!',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Theme.of(context).canvasColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}