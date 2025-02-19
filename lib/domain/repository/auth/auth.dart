import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:moneyy/data/models/auth/create_user_req.dart';
import 'package:moneyy/data/models/auth/signin_user_req.dart';

abstract class AuthRepository {

  Future<Either> resetPassword({required String email});

  Future<Either> resetEmail({required String email});

  Future<Either> signOut();

  Future<Either> accountDeletion();

  Future<Either> signIn(UserSignInReq userSignInReq);

  Future<Either> signUp(UserCreateReq userCreateReq, String password);

}