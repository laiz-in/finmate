import 'dart:async';

import 'package:dartz/dartz.dart';


abstract class SettingsRepository {


  Future<Either> updateProfilePicture({required String profilePictureURL});

  Future<Either> resetDailyLimit({required int dailyLimit});

  Future<Either> resetMonthlyLimit({required int monthlyLimit});

  Future<Either> sendFeedback({required String feedback});

  Future<Either> resetName({required String firstName, required String lastName});





}
