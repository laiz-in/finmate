import 'dart:async';

import 'package:dartz/dartz.dart';


abstract class SettingsRepository {


  Future<Either> resetDailyLimit({required int dailyLimit});

  Future<Either> resetMonthlyLimit({required int monthlyLimit});

  Future<Either> sendFeedback({required String feedback});




}
