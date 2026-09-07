import '../../../data/models/expense.dart';

class ExpenseState {
  final bool isLoading;
  final List<Expense> expenses;

  const ExpenseState({required this.isLoading, required this.expenses});

  const ExpenseState.initial() : this(isLoading: true, expenses: const []);
}