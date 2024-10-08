import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';
import 'package:moneyy/service_locator.dart';

class SignOutUseCase {

  Future<Either> call() async {
    return sl<AuthRepository>().signOut();
  }
}
