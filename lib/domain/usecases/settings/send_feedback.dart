import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';
import 'package:moneyy/service_locator.dart';

class SendFeedbackUseCase {
  Future<Either> call({required String feedback}) async {
    return sl<SettingsRepository>().sendFeedback(feedback: feedback);
  }
}