
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

  });

  //Factory method to create a UserEntity from a Firestore document
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      uid: json['uid'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: json['status'],
      totalSpending: json['totalSpending']?.toDouble(),
      dailyLimit: json['dailyLimit']?.toDouble(),
      monthlyLimit: json['monthlyLimit']?.toDouble(),
    );
  }

  get todaySpending => null;

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
    };
  }
}
