import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_profile.dart';
import '../../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  String? _currentUid;

  ProfileCubit(this._repository) : super(const ProfileState.initial());

  Future<void> loadProfile(String uid) async {
    if (_currentUid != uid) {
      emit(const ProfileState(isLoading: true));
    }
    _currentUid = uid;

    final cached = _repository.getCachedProfile(uid);
    if (cached != null) {
      emit(ProfileState(isLoading: false, profile: cached));
      return;
    }
    final remote = await _repository.fetchRemoteProfile(uid);
    emit(ProfileState(isLoading: false, profile: remote));
  }

  Future<void> saveProfile(UserProfile profile) async {
    _currentUid = profile.uid;
    await _repository.saveProfile(profile);
    emit(ProfileState(isLoading: false, profile: profile));
  }

  Future<void> clearOnSignOut() async {
    _currentUid = null;
    await _repository.clearCache();
    emit(const ProfileState.initial());
  }
}