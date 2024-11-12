import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/bloc/network/network_bloc.dart';
import 'package:moneyy/bloc/network/network_state.dart';
import 'package:moneyy/data/repository/home/home_repository.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final UserRepository userRepository;
  final NetworkBloc networkBloc;
  late final StreamSubscription networkSubscription;

  HomeScreenBloc({
    required this.userRepository,
    required this.networkBloc,
  }) : super(HomeScreenLoading()) {
    // Listen to network status changes
    networkSubscription = networkBloc.stream.listen((networkState) {
      if (networkState is NetworkDisconnected) {
        // emit(HomeScreenError('No internet connection.'));
      } else if (networkState is NetworkConnected) {
        add(FetchUserData()); // Re-fetch data when internet is back
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

  @override
  Future<void> close() {
    networkSubscription.cancel(); // Clean up the subscription
    return super.close();
  }
}
