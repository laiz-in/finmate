import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyy/domain/entities/auth/user.dart';

class UserCreateReq {
  // REQUIRED FIELDS WITH THEIR ORIGINAL TYPES
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime createdAt;
  final int status;
  final double dailyLimit;
  final double monthlyLimit;

  // CONSTRUCTOR WITH ORIGINAL DEFAULT VALUES
  UserCreateReq({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    DateTime? createdAt,
    this.status = 0,
    this.dailyLimit = 100.0,
    this.monthlyLimit = 1000.0,
  }) : createdAt = createdAt?.toUtc() ?? DateTime.now().toUtc();  // ENSURE UTC TIME

  // COPY WITH METHOD FOR IMMUTABLE UPDATES
  UserCreateReq copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? createdAt,
    int? status,
    double? dailyLimit,
    double? monthlyLimit,
  }) {
    return UserCreateReq(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  // CONVERT FIREBASE JSON TO USER MODEL WITH SAFETY CHECKS
  factory UserCreateReq.fromJson(Map<String, dynamic> json) {
    // VALIDATE REQUIRED FIELDS
    if (json['uid'] == null || (json['uid'] as String).isEmpty) {
      throw Exception('Invalid UID in data');
    }

    // SAFELY CONVERT TIMESTAMP OR STRING TO DATETIME
    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate().toUtc()
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'].toString()).toUtc()
              : DateTime.now().toUtc();
    } catch (e) {
      parsedCreatedAt = DateTime.now().toUtc();
    }

    // SAFELY CONVERT NUMERIC VALUES WITH VALIDATION
    final dailyLimit = (json['dailyLimit'] as num?)?.toDouble() ?? 100.0;
    final monthlyLimit = (json['monthlyLimit'] as num?)?.toDouble() ?? 1000.0;

    // BASIC BUSINESS RULE VALIDATION
    if (dailyLimit < 0 || monthlyLimit < 0) {
      throw Exception('Limits cannot be negative');
    }
    if (monthlyLimit < dailyLimit) {
      throw Exception('Monthly limit cannot be less than daily limit');
    }

    return UserCreateReq(
      uid: json['uid'].toString().trim(),
      email: (json['email'] as String?)?.toLowerCase().trim() ?? '',
      firstName: (json['firstName'] as String?)?.trim() ?? '',
      lastName: (json['lastName'] as String?)?.trim() ?? '',
      createdAt: parsedCreatedAt,
      status: json['status'] as int? ?? 0,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );
  }

  // CONVERT USER MODEL TO REGULAR JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid.trim(),
      'email': email.toLowerCase().trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'createdAt': createdAt.toUtc().toIso8601String(),  // CONSISTENT UTC STRING FORMAT
      'status': status,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
    };
  }

  // CONVERT FROM DOMAIN ENTITY WITH NULL SAFETY
  factory UserCreateReq.fromEntity(UserEntity entity) {
    return UserCreateReq(
      uid: entity.uid?.trim() ?? '',
      email: entity.email?.toLowerCase().trim() ?? '',
      firstName: entity.firstName?.trim() ?? '',
      lastName: entity.lastName?.trim() ?? '',
      createdAt: entity.createdAt?.toUtc() ?? DateTime.now().toUtc(),
      status: entity.status ?? 0,
      dailyLimit: entity.dailyLimit ?? 0.0,
      monthlyLimit: entity.monthlyLimit ?? 0.0,
    );
  }

  // CONVERT TO DOMAIN ENTITY
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      firstName: firstName,
      lastName: lastName,
      createdAt: createdAt,
      status: status,
      dailyLimit: dailyLimit,
      monthlyLimit: monthlyLimit,
    );
  }

  // CONVERT TO FIRESTORE-SPECIFIC JSON
  Map<String, dynamic> toFirestoreJson() {
    return {
      'uid': uid.trim(),
      'email': email.toLowerCase().trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'createdAt': Timestamp.fromDate(createdAt.toUtc()),  // PROPER TIMESTAMP CONVERSION
      'status': status,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
    };
  }

  // OVERRIDE EQUALITY FOR PROPER COMPARISON
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCreateReq &&
          uid == other.uid &&
          email.toLowerCase() == other.email.toLowerCase() &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          createdAt.isAtSameMomentAs(other.createdAt) &&
          status == other.status &&
          dailyLimit == other.dailyLimit &&
          monthlyLimit == other.monthlyLimit;

  // OVERRIDE HASHCODE FOR PROPER SET/MAP OPERATIONS
  @override
  int get hashCode =>
      uid.hashCode ^
      email.toLowerCase().hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      createdAt.hashCode ^
      status.hashCode ^
      dailyLimit.hashCode ^
      monthlyLimit.hashCode;
}