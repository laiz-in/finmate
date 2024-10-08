import 'package:dartz/dartz.dart';
import 'package:moneyy/core/usecase/usecase.dart';
import 'package:moneyy/data/models/auth/signin_user_req.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';
import 'package:moneyy/service_locator.dart';

class SignInUseCase implements Usecase<Either,UserSignInReq> {

  @override
  Future<Either> call({UserSignInReq? params}) async {
    return sl<AuthRepository>().signIn(params!);
  }
}
