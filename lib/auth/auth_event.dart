import 'package:meta/meta.dart';

@immutable
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class UserLoggedIn extends AuthEvent {}

class UserLoggedOut extends AuthEvent {}

class AppStarted extends AuthEvent {} // This could be used to trigger the check on app launch
