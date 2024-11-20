import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseInitializer {
  static void enableOfflinePersistence() {
    FirebaseDatabase.instance.setPersistenceEnabled(true);
    FirebaseDatabase.instance.setPersistenceCacheSizeBytes(Settings.CACHE_SIZE_UNLIMITED); // Optional cache size
  }
}