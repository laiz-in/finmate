import 'package:dartz/dartz.dart';
import 'package:moneyy/data/sources/home/home_firebase_services.dart';
import 'package:moneyy/domain/entities/auth/user.dart';

class UserRepository {
  final FirebaseHomeService firebaseAuthService;

  UserRepository(this.firebaseAuthService);

  Future<Either<String, UserEntity>> getUserData() async {
    try {
      return await firebaseAuthService.fetchCurrentUserData();
    } catch (e) {
      return Left("Failed to load user data");
    }
  }
}
