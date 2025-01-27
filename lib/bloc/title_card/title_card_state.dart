import 'package:equatable/equatable.dart';

class TitleCardState extends Equatable {
  final double todayTotalIncome;
  final double todayTotalExpense;
  final double thisMonthTotalIncome;
  final double thisMonthTotalExpense;
  final bool isLoading;
  final String? errorMessage;

  const TitleCardState({
    required this.todayTotalIncome,
    required this.todayTotalExpense,
    required this.thisMonthTotalIncome,
    required this.thisMonthTotalExpense,
    this.isLoading = false,
    this.errorMessage,
  });

  factory TitleCardState.initial() {
    return const TitleCardState(
      todayTotalIncome: 0.0,
      todayTotalExpense: 0.0,
      thisMonthTotalIncome: 0.0,
      thisMonthTotalExpense: 0.0,
      isLoading: false,
    );
  }

  TitleCardState copyWith({
    double? todayTotalIncome,
    double? todayTotalExpense,
    double? thisMonthTotalIncome,
    double? thisMonthTotalExpense,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TitleCardState(
      todayTotalIncome: todayTotalIncome ?? this.todayTotalIncome,
      todayTotalExpense: todayTotalExpense ?? this.todayTotalExpense,
      thisMonthTotalIncome: thisMonthTotalIncome ?? this.thisMonthTotalIncome,
      thisMonthTotalExpense: thisMonthTotalExpense ?? this.thisMonthTotalExpense,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        todayTotalIncome,
        todayTotalExpense,
        thisMonthTotalIncome,
        thisMonthTotalExpense,
        isLoading,
        errorMessage,
      ];
}
