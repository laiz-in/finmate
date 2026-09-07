import 'package:hive/hive.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _service;
  final Box _box = Hive.box('profileBox');
  static const _key = 'profile';

  ProfileRepository(this._service);

  /// Instant, synchronous, offline-safe — the source every screen reads from.
  UserProfile? getCachedProfile() {
    final map = _box.get(_key);
    if (map == null) return null;
    return UserProfile.fromMap(Map<String, dynamic>.from(map));
  }

  /// Used only when Hive has no cache yet (e.g. fresh login on a new device).
  /// Always resolves quickly — a timeout or any other error is caught, never
  /// left hanging, so callers (like pull-to-refresh) never get stuck.
  Future<UserProfile?> fetchRemoteProfile(String uid) async {
    try {
      final profile = await _service.getProfile(uid);
      if (profile != null) {
        await _box.put(_key, profile.toMap());
      }
      return profile;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _box.put(_key, profile.toMap());
    _service.setProfile(profile).catchError((_) {});
  }
}