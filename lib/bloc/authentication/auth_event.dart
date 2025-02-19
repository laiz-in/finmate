import 'package:meta/meta.dart';

@immutable
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class UserLoggedIn extends AuthEvent {}

class UserLoggedOut extends AuthEvent {}


