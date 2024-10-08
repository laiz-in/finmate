import 'package:dartz/dartz.dart';
import 'package:moneyy/core/usecase/usecase.dart';
import 'package:moneyy/data/models/auth/create_user_req.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';
import 'package:moneyy/service_locator.dart';


class SignUpUseCase implements Usecase<Either,UserCreateReq> {

  @override
  Future<Either> call({UserCreateReq? params}) async {
    return sl<AuthRepository>().signUp(params!);
  }
}
