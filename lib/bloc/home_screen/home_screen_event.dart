import 'package:equatable/equatable.dart';

abstract class HomeScreenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserData extends HomeScreenEvent {}

class FetchThisMonthIncomeEvent extends HomeScreenEvent {}

class FetchThisWeekIncomeEvent extends HomeScreenEvent {}

class FetchThisYearIncomeEvent extends HomeScreenEvent {}

class NoInternetEvent extends HomeScreenEvent {}
