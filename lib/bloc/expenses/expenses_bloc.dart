import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/domain/entities/spending/expenses.dart';
import 'package:moneyy/domain/usecases/expenses/add_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_seven_day_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/last_three_expense_usecase.dart';
import 'package:moneyy/domain/usecases/expenses/total_expenses_usecase.dart';

import 'expenses_event.dart'; // Import the events
import 'expenses_state.dart'; // Import the states

// BLoC
class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final TotalExpensesUseCase _totalExpensesUseCase;
  final LastThreeExpensesUseCase _lastThreeExpensesUseCase;
  final LastSevenDayExpensesUseCase? _lastSevenDayExpensesUseCase;

  final AddExpensesUseCase _addExpensesUseCase;

  ExpensesBloc(
    this._totalExpensesUseCase,
    this._lastThreeExpensesUseCase,
    this._lastSevenDayExpensesUseCase,
    this._addExpensesUseCase,
  ) : super(ExpensesLoading()) {
    on<FetchAllExpensesEvent>(_onFetchAllExpenses);
    on<FetchLastThreeExpensesEvent>(_onFetchLastThreeExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<FetchLastSevenDayExpensesEvent>(_onFetchLastSevenDayExpenses);
  }

  void _onFetchAllExpenses(FetchAllExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final Either<String, List<ExpensesEntity>> result = await _totalExpensesUseCase();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  void _onFetchLastThreeExpenses(FetchLastThreeExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final Either<String, List<ExpensesEntity>> result = await _lastThreeExpensesUseCase();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expenses) => emit(ExpensesLoaded(expenses)),
    );
  }

  void _onAddExpense(AddExpenseEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final Either<String, void> result = await _addExpensesUseCase(event.expense);
    result.fold(
      (error) => emit(ExpensesError(error)),
      (_) => add(FetchAllExpensesEvent()), // Fetch all expenses after adding
    );
  }

  void _onFetchLastSevenDayExpenses(FetchLastSevenDayExpensesEvent event, Emitter<ExpensesState> emit) async {
    emit(ExpensesLoading());
    final Either<String, Map<String, double>> result = await _lastSevenDayExpensesUseCase!();
    result.fold(
      (error) => emit(ExpensesError(error)),
      (expensesMap) => emit(LastSevenDayExpensesLoaded(expensesMap)), // Create a new state for this if needed
    );
  }
}
