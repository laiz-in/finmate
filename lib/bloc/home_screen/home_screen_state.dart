import 'package:equatable/equatable.dart';

abstract class HomeScreenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeScreenLoading extends HomeScreenState {}

class HomeScreenLoaded extends HomeScreenState {
  final dynamic user;
  HomeScreenLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class HomeScreenError extends HomeScreenState {
  final String message;
  HomeScreenError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeScreenMonthlyIncomeLoaded extends HomeScreenState {
  final double income;
  HomeScreenMonthlyIncomeLoaded(this.income);

  @override
  List<Object?> get props => [income];
}

class HomeScreenWeeklyIncomeLoaded extends HomeScreenState {
  final double income;
  HomeScreenWeeklyIncomeLoaded(this.income);

  @override
  List<Object?> get props => [income];
}

class HomeScreenYearlyIncomeLoaded extends HomeScreenState {
  final double income;
  HomeScreenYearlyIncomeLoaded(this.income);

  @override
  List<Object?> get props => [income];
}
