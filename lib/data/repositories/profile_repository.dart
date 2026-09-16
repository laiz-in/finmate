import 'package:hive/hive.dart';

import '../models/user_profile.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _service;
  final Box _box = Hive.box('profileBox');
  static const _key = 'profile';

  ProfileRepository(this._service);

  /// Instant, synchronous, offline-safe — but only returned if it actually
  /// belongs to the given uid. Prevents a stale cached profile from a
  /// previously signed-in account leaking into a newly signed-in one.
  UserProfile? getCachedProfile(String uid) {
    final map = _box.get(_key);
    if (map == null) return null;
    final profile = UserProfile.fromMap(Map<String, dynamic>.from(map));
    if (profile.uid != uid) return null;
    return profile;
  }

  /// Used when Hive has no valid cache for this uid yet (e.g. fresh login,
  /// or a different account signed in on this device previously).
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

  /// Clears any locally cached profile — call this on sign out so a
  /// different account signing in next never sees stale cached data.
  Future<void> clearCache() async {
    await _box.delete(_key);
  }
}