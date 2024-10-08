import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/bloc/expenses/expenses_bloc.dart';
import 'package:moneyy/bloc/expenses/expenses_event.dart';
import 'package:moneyy/bloc/expenses/expenses_state.dart';
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_seven_day_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_three_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';
import 'package:moneyy/presentation/widgets/common_appbar.dart';
import 'package:moneyy/service_locator.dart';

class SpendingScreen extends StatelessWidget {
  const SpendingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // Use BlocProvider to provide ExpensesBloc to the widget tree
    return BlocProvider(
      create: (context) => ExpensesBloc(
        sl<TotalExpensesUseCase>(), // Use case for retrieving all expenses
        sl<LastThreeExpensesUseCase>(),
        sl<LastSevenDayExpensesUseCase>(), // Add this if needed for last three expenses

        sl<AddExpensesUseCase>(), // Use case for adding expenses

      )..add(FetchAllExpensesEvent()), // Dispatch event to fetch all expenses


      child: Scaffold(


        appBar: CustomAppBarCommon(
          title: 'View All Expenses',
        ),


        body: BlocConsumer<ExpensesBloc, ExpensesState>(
          listener: (context, state) {
            if (state is ExpensesError) {
              errorSnackbar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is ExpensesLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.yellow));
            } else if (state is ExpensesLoaded) {
              return ListView.builder(
                itemCount: state.expenses.length,
                itemBuilder: (context, index) {
                  final expense = state.expenses[index];
                  return ListTile(
                    title: Text(expense.spendingDescription),
                    subtitle: Text(expense.spendingCategory),
                    trailing: Text("\$${expense.spendingAmount.toStringAsFixed(2)}"),
                  );
                },
              );
            } else if (state is ExpensesError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('No Expenses Found'));
          },
        ),
      ),
    );
  }
}
