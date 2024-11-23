import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/bloc/network/network_bloc.dart'; // Use the correct path
import 'package:moneyy/common/widgets/error_snackbar.dart';
import 'package:moneyy/data/repository/home/home_repository.dart';
import 'package:moneyy/main.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final UserRepository userRepository;
  final ConnectivityCubit connectivityCubit;

  late final StreamSubscription connectivitySubscription;

  HomeScreenBloc({
    required this.userRepository,
    required this.connectivityCubit,
  }) : super(HomeScreenLoading()) {
    // Listen to connectivity changes
    connectivitySubscription = connectivityCubit.stream.listen((isConnected) {
      if (!isConnected) {
        emit(HomeScreenError("OH NO INTERNET"));
      } else {
        add(FetchUserData()); // Re-fetch data when back online
      }
    });

    // Event handling
    on<FetchUserData>((event, emit) async {
      emit(HomeScreenLoading());

      final result = await userRepository.getUserData();

      result.fold(
        (error) => emit(HomeScreenError(error)),
        (user) => emit(HomeScreenLoaded(user)),
      );
    });
  }

  void _showNoInternetPopup() {
    final context = navigatorKey.currentContext;
    if (context != null) {
        errorSnackbar(context, "You are currently in offline mode") ;
    }
  }

  @override
  Future<void> close() {
    connectivitySubscription.cancel(); // Clean up the subscription
    return super.close();
  }
}
