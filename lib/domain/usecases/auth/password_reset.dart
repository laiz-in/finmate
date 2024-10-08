import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';
import 'package:moneyy/service_locator.dart';

class ResetPasswordUseCase {
  Future<Either> call({required String email}) async {
    return sl<AuthRepository>().resetPassword(email: email);
  }
}
