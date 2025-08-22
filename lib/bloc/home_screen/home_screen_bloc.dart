import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/bloc/network/network_bloc.dart'; // Use the correct path
import 'package:moneyy/data/repository/home/home_repository.dart';
import 'package:moneyy/domain/usecases/income/this_month_total_income.dart';
import 'package:moneyy/domain/usecases/income/this_week_total_income.dart';
import 'package:moneyy/domain/usecases/income/this_year_total_income.dart';


class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final UserRepository userRepository;
  final ConnectivityCubit connectivityCubit;
  final ThisMonthToatalIncomeUseCase fetchThisMonthIncomeUseCase;
  final ThisWeekToatalIncomeUseCase fetchThisWeekIncomeUseCase;
  final ThisYearToatalIncomeUseCase fetchThisYearIncomeUseCase;

  late final StreamSubscription connectivitySubscription;

  HomeScreenBloc({
    required this.userRepository,
    required this.connectivityCubit,
    required this.fetchThisMonthIncomeUseCase,
    required this.fetchThisWeekIncomeUseCase,
    required this.fetchThisYearIncomeUseCase,
  }) : super(HomeScreenLoading()) {

// EVENT FOR FETCHING USER DATA
on<FetchUserData>((event, emit) async {
  emit(HomeScreenLoading());
  final result = await userRepository.getUserData();
  result.fold(
    (error) => emit(HomeScreenError(error)),
    (user) => emit(HomeScreenLoaded(user)),
  );
});

    // THIS MONTH INCOME
    on<FetchThisMonthIncomeEvent>((event, emit) async {
      emit(HomeScreenLoading());

      final result = await fetchThisMonthIncomeUseCase();

      result.fold(
        (error) => emit(HomeScreenError(error)),
        (income) => emit(HomeScreenMonthlyIncomeLoaded(income)),
      );
    });

    // THIS WEEK INCOME
    on<FetchThisWeekIncomeEvent>((event, emit) async {
      emit(HomeScreenLoading());

      final result = await fetchThisWeekIncomeUseCase();

      result.fold(
        (error) => emit(HomeScreenError(error)),
        (income) => emit(HomeScreenWeeklyIncomeLoaded(income)),
      );
    });

    // THIS YEAR INCOME
    on<FetchThisYearIncomeEvent>((event, emit) async {
      emit(HomeScreenLoading());

      final result = await fetchThisYearIncomeUseCase();

      result.fold(
        (error) => emit(HomeScreenError(error)),
        (income) => emit(HomeScreenYearlyIncomeLoaded(income)),
      );
    });

  }

  @override
  Future<void> close() {
    connectivitySubscription.cancel();
    return super.close();
  }
}
