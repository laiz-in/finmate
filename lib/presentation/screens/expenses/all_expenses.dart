import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/expenses/expenses_event.dart';
import 'package:moneyy/bloc/expenses/expenses_state.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_seven_day_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_three_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';
import 'package:moneyy/presentation/screens/expenses/each_card.dart';
import 'package:moneyy/presentation/widgets/common_appbar.dart';
import 'package:moneyy/service_locator.dart';

class SpendingScreen extends StatefulWidget {
  const SpendingScreen({super.key});

  @override
  _SpendingScreenState createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  final ScrollController _scrollController = ScrollController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Set up scroll listener to detect when user reaches bottom for lazy loading
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // Fetch more expenses when scrolled to bottom
        BlocProvider.of<ExpensesBloc>(context).add(FetchMoreExpensesEvent());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Move the BlocProvider higher up in the widget tree
    return BlocProvider(
      create: (context) => ExpensesBloc(
        sl<TotalExpensesUseCase>(),
        sl<LastThreeExpensesUseCase>(),
        sl<LastSevenDayExpensesUseCase>(),
        sl<AddExpensesUseCase>(),
      )..add(FetchAllExpensesEvent()),

      // The rest of the SpendingScreen is inside the BlocProvider now
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: CustomAppBarCommon(
          title: 'View All Expenses',
        ),

        body: Column(
          children: [
            // Sticky Search Bar and Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Search Bar
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).highlightColor,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Theme.of(context).canvasColor.withOpacity(0.5),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: TextField(
                              cursorColor: Theme.of(context).canvasColor.withOpacity(0.5),
                              autofocus: false,
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });

                                // Use parent context to trigger search event
                                final expensesBloc = context.read<ExpensesBloc>();
                                expensesBloc.add(SearchExpensesEvent(searchQuery));
                              },
                              autocorrect: false,
                              enableSuggestions: false,
                              style: GoogleFonts.poppins(
                                  color: Theme.of(context).canvasColor,
                                  fontWeight: FontWeight.w400),
                              decoration: InputDecoration(
                                hintText: ' Search..',
                                hintStyle: GoogleFonts.poppins(
                                  color: Theme.of(context)
                                      .canvasColor.withOpacity(0.2)
                                      .withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Filter Icon
                  IconButton(
                    icon: Icon(
                      Icons.sort,
                      color: Theme.of(context).canvasColor,
                      size: 35,
                    ),
                    onPressed: () {
                      // Filter logic can go here
                    },
                  ),
                ],
              ),
            ),

            // Expenses List with Lazy Loading
            Expanded(
              child: BlocConsumer<ExpensesBloc, ExpensesState>(
                listener: (context, state) {
                  if (state is ExpensesError) {
                    errorSnackbar(context, state.message);
                  }
                },
                builder: (context, state) {
                  if (state is ExpensesLoading && state.isFirstFetch) {
                    return Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).canvasColor));
                  } else if (state is ExpensesLoaded) {
                    final expenses = state.expenses;

                    if (expenses.isEmpty) {
                      return const Center(child: Text('No Expenses Found'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: expenses.length + (state.hasMore ? 1 : 0), // +1 for lazy loading indicator
                      itemBuilder: (context, index) {
                        if (index < expenses.length) {
                          final expense = expenses[index];
                          return TransactionCard(
                            transaction: expense,
                            onUpdate: () {
    // Update logic
  },
  onDelete: () {
    // Refresh the expenses list or state after deletion
  },
                          );

                        } else {
                          // Display loading indicator when fetching more
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).canvasColor,
                            ),
                          );
                        }
                      },
                    );
                  } else if (state is ExpensesError) {
                    return Center(child: Text('Error in loading expenses'));
                  }

                  return const Center(child: Text('No Expenses Found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
