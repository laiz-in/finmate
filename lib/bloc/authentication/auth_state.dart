import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

// INITIAL AUTH STATE
class AuthInitial extends AuthState {}


//AUTHENTICATED STATE
class AuthAuthenticated extends AuthState {
  final dynamic user;
  AuthAuthenticated({required this.user});
}


// UN AUTHENTICATED STATE
class AuthUnauthenticated extends AuthState {}



//AUTH UN INITIALIZED STATE
class AuthUninitialized extends AuthState {}



//AUTH LOADING STATE
class AuthLoading extends AuthState {}


// AUTH FAILURE STATE
class AuthFailure extends AuthState {
  final String message;
  AuthFailure({required this.message});
}
