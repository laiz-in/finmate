import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';
import 'package:moneyy/service_locator.dart';

class ResetDailyLimitUseCase {

  Future<Either> call({required int dailyLimit}) async {
    return sl<SettingsRepository>().resetDailyLimit(dailyLimit: dailyLimit);
  }
}