import 'package:moneyy/domain/entities/auth/user.dart';

abstract class HomeScreenState {}

class HomeScreenLoading extends HomeScreenState {}

class HomeScreenLoaded extends HomeScreenState {
  final UserEntity user;

  HomeScreenLoaded(this.user);
}

class HomeScreenError extends HomeScreenState {
  final String message;

  HomeScreenError(this.message);
}
