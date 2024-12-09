import 'package:dartz/dartz.dart';
import 'package:moneyy/domain/repository/settings/settings.dart';
import 'package:moneyy/service_locator.dart';

class UpdateProfilePictureUseCase {

  Future<Either> call({required String profilePictureURL}) async {
    return sl<SettingsRepository>().updateProfilePicture(profilePictureURL:profilePictureURL );
  }
}