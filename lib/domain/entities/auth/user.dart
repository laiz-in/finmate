import 'package:cloud_firestore/cloud_firestore.dart';

class UserEntity {
  String? email;
  String? firstName;
  String? lastName;
  DateTime? createdAt;
  int? status; // Status can be an enum or integer representing user status
  double? totalSpending; // Can be used to track total spending
  double? dailyLimit; // Daily spending limit
  double? monthlyLimit; // Monthly spending limit
  String? uid;
  bool isSynced; // New field to track sync status

  UserEntity({
    this.email,
    this.firstName,
    this.lastName,
    this.createdAt,
    this.status,
    this.totalSpending,
    this.dailyLimit,
    this.monthlyLimit,
    this.uid,
    this.isSynced = false, // Default value is false
  });

  // Factory method to create a UserEntity from a Firestore document
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uid: json['uid'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      status: json['status'],
      totalSpending: json['totalSpending']?.toDouble(),
      dailyLimit: json['dailyLimit']?.toDouble(),
      monthlyLimit: json['monthlyLimit']?.toDouble(),
      isSynced: json['isSynced'] ?? false, // Default to false if not found
    );
  }

  // Convert the UserEntity to a JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt,
      'status': status,
      'totalSpending': totalSpending,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
      'isSynced': isSynced, // Include isSynced in JSON
    };
  }

  // Add a copyWith method
  UserEntity copyWith({
    String? email,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
    int? status,
    double? totalSpending,
    double? dailyLimit,
    double? monthlyLimit,
    String? uid,
    bool? isSynced, // Allow updating isSynced
  }) {
    return UserEntity(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalSpending: totalSpending ?? this.totalSpending,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      uid: uid ?? this.uid,
      isSynced: isSynced ?? this.isSynced, // Preserve existing value if not updated
    );
  }
}
