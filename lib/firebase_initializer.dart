import 'package:firebase_database/firebase_database.dart';

class FirebaseInitializer {
  static void enableOfflinePersistence(String databaseURL) {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(1024 * 10);  // 1GB
    FirebaseDatabase.instance.databaseURL = databaseURL;
  }
}