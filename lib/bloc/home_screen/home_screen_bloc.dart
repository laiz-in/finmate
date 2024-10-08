

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moneyy/bloc/home_screen/home_screen_event.dart';
import 'package:moneyy/bloc/home_screen/home_screen_state.dart';
import 'package:moneyy/data/repository/home/home_repository.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  final UserRepository userRepository;

  HomeScreenBloc(this.userRepository) : super(HomeScreenLoading()) {
    on<FetchUserData>((event, emit) async {
      emit(HomeScreenLoading());

      final result = await userRepository.getUserData();

      result.fold(
        (error) => emit(HomeScreenError(error)),
        (user) => emit(HomeScreenLoaded(user)),
      );
    });
  }
}
