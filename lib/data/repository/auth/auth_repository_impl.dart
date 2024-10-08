import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/auth/create_user_req.dart';
import 'package:moneyy/data/models/auth/signin_user_req.dart';
import 'package:moneyy/data/sources/auth/auth_firebase_service.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';

import '../../../service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {

  @override
  Future<Either> signIn(UserSignInReq userSignInReq)async{
    return await sl<AuthFirebaseService>().signIn(userSignInReq);
  }

  @override
  Future<Either> signUp(UserCreateReq userCreateReq)async{
    return await sl<AuthFirebaseService>().signUp(userCreateReq);
  }

  @override
  Future<Either> resetPassword({required String email}) async {
    return await sl<AuthFirebaseService>().resetPassword(email: email);

  }
  
  @override
  Future<Either> resetEmail({required String email}) async {
      return await sl<AuthFirebaseService>().resetEmail(email: email);
  }
  
  @override
  Future<Either> signOut() async {
    return await sl<AuthFirebaseService>().signOut();
  }
  
  @override
  Future<Either> accountDeletion() async {
    return await sl<AuthFirebaseService>().accountDeletion();
  }


}
