import '../../../data/models/user_profile.dart';

class ProfileState {
  final bool isLoading;
  final UserProfile? profile;

  const ProfileState({required this.isLoading, this.profile});

  const ProfileState.initial() : this(isLoading: true, profile: null);
}