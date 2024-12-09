import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';
import 'package:moneyy/service_locator.dart';

class ResetNameUseCase {

  Future<Either> call({required String firstName, required String lastName}) async {
    return sl<SettingsRepository>().resetName(firstName:firstName, lastName:lastName);
  }
}