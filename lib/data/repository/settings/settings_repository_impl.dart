import 'package:dartz/dartz.dart';
import 'package:moneyy/data/sources/settings/settings_firebase_services.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';

import '../../../service_locator.dart';

class SettingsRepositoryImpl extends SettingsRepository{

@override
Future<Either> updateProfilePicture({required String profilePictureURL}) async {
    return await sl<SettingsFirebaseService>().updateProfilePicture(profilePictureURL: profilePictureURL);
}

@override
Future<Either> resetMonthlyLimit({required int monthlyLimit}) async {
    return await sl<SettingsFirebaseService>().resetMonthlyLimit(monthlyLimit: monthlyLimit);
}

@override
Future<Either> resetDailyLimit({required int dailyLimit}) async {
    return await sl<SettingsFirebaseService>().resetDailyLimit(dailyLimit: dailyLimit);
}

@override
Future<Either> sendFeedback({required String feedback}) async {
    return await sl<SettingsFirebaseService>().sendFeedback(feedback: feedback);
}

@override
Future<Either> resetName({required String firstName, required String lastName}) async{
    return await sl<SettingsFirebaseService>().resetName(firstName: firstName, lastName: lastName);

}

}
