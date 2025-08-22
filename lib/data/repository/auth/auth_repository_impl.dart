import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/auth/create_user_req.dart';
import 'package:moneyy/data/models/auth/signin_user_req.dart';
import 'package:moneyy/data/sources/remote/auth/auth_firebase_service.dart';
import 'package:moneyy/domain/repository/auth/auth.dart';

import '../../../service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  
  // SIGN IN REPOSITORY IMPLIMENTATION
  @override
  Future<Either> signIn(UserSignInReq userSignInReq)async{
    return await sl<AuthFirebaseService>().signIn(userSignInReq);
  }

  // SIGN UP REPOSITORY IMPLIMENTATION
  @override
  Future<Either> signUp(UserCreateReq userCreateReq,String password) async{
    return await sl<AuthFirebaseService>().signUp(userCreateReq,password);
  }

  // PASSWORD RESET REPOSITORY IMPLIMENTATION
  @override
  Future<Either> resetPassword({required String email}) async {
    return await sl<AuthFirebaseService>().resetPassword(email: email);
  }

  // EMAIL RESET REPOSITORY IMPLIMENTATION
  @override
  Future<Either> resetEmail({required String email}) async {
      return await sl<AuthFirebaseService>().resetEmail(email: email);
  }

  // SIGN OUT REPOSITORY IMPLIMENTATION
  @override
  Future<Either> signOut() async {
    return await sl<AuthFirebaseService>().signOut();
  }
  
  // ACCOUNT DELETION REPOSITORY IMPLIMENTATION
  @override
  Future<Either> accountDeletion() async {
    return await sl<AuthFirebaseService>().accountDeletion();
  }


}
