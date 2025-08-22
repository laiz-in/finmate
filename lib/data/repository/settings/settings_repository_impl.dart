import 'package:dartz/dartz.dart';
import 'package:moneyy/data/sources/remote/settings/settings_firebase_services.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';

import '../../../service_locator.dart';

class SettingsRepositoryImpl extends SettingsRepository{

// RESET MONTHLY LIMIT
@override
Future<Either> resetMonthlyLimit({required int monthlyLimit}) async {
    return await sl<SettingsFirebaseService>().resetMonthlyLimit(monthlyLimit: monthlyLimit);
}

// RESET DAILY LIMIT
@override
Future<Either> resetDailyLimit({required int dailyLimit}) async {
    return await sl<SettingsFirebaseService>().resetDailyLimit(dailyLimit: dailyLimit);
}

// SEDN FEEDBACK
@override
Future<Either> sendFeedback({required String feedback}) async {
    return await sl<SettingsFirebaseService>().sendFeedback(feedback: feedback);
}

// RESET NAME
@override
Future<Either> resetName({required String firstName, required String lastName}) async{
    return await sl<SettingsFirebaseService>().resetName(firstName: firstName, lastName: lastName);

}

}
