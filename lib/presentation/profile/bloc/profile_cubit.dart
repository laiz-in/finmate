import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_profile.dart';
import '../../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(const ProfileState.initial());

  Future<void> loadProfile(String uid) async {
    emit(const ProfileState(isLoading: true));
    final cached = _repository.getCachedProfile();
    if (cached != null) {
      emit(ProfileState(isLoading: false, profile: cached));
      return;
    }
    final remote = await _repository.fetchRemoteProfile(uid);
    emit(ProfileState(isLoading: false, profile: remote));
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    emit(ProfileState(isLoading: false, profile: profile));
  }
}