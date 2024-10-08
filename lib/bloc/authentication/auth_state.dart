import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthUninitialized extends AuthState {}

class AuthLoading extends AuthState {}
