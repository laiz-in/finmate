import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';
import 'package:moneyy/service_locator.dart';

class ResetMonthlyLimitUseCase {

  Future<Either> call({required int monthlyLimit}) async {
    return sl<SettingsRepository>().resetMonthlyLimit(monthlyLimit: monthlyLimit);
  }
}