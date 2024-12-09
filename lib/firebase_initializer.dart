import 'package:firebase_database/firebase_database.dart';

class FirebaseInitializer {
  static Future<void> enableOfflinePersistence(String databaseURL) async {
    try {
      // Set the database URL
      FirebaseDatabase.instance.databaseURL = databaseURL;

      // Enable offline persistence
      FirebaseDatabase.instance.setPersistenceEnabled(true);

      // Set cache size (e.g., 10MB)
      FirebaseDatabase.instance.setPersistenceCacheSizeBytes(1024 * 1024 * 10);

      print('Firebase Realtime Database offline persistence enabled.');
    } catch (e) {
      print('Error enabling offline persistence: $e');
    }
  }
}
