import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyy/domain/entities/borrowed/borrowed.dart';

class BorrowedModel {
  // REQUIRED FIELDS WITH THEIR ORIGINAL TYPES
  final String uidOfBorrowed;
  final DateTime borrowedaddedDate;
  final double borrowedAmount;
  final String borrowedDescription;
  final DateTime borrowedDueDate;
  final String borrowedPerson;

  // CONSTRUCTOR WITH ORIGINAL DEFAULT VALUES
  BorrowedModel({
    required this.uidOfBorrowed,
    required this.borrowedaddedDate,
    required this.borrowedAmount,
    required this.borrowedDescription,
    required this.borrowedDueDate,
    required this.borrowedPerson,
  });

  // COPY WITH METHOD FOR IMMUTABLE UPDATES
  BorrowedModel copyWith({
    String? uidOfBorrowed,
    DateTime? borrowedaddedDate,
    double? borrowedAmount,
    String? borrowedDescription,
    DateTime? borrowedDueDate,
    String? borrowedPerson,
  }) {
    return BorrowedModel(
      uidOfBorrowed: uidOfBorrowed ?? this.uidOfBorrowed,
      borrowedaddedDate: borrowedaddedDate ?? this.borrowedaddedDate,
      borrowedAmount: borrowedAmount ?? this.borrowedAmount,
      borrowedDescription: borrowedDescription ?? this.borrowedDescription,
      borrowedDueDate: borrowedDueDate ?? this.borrowedDueDate,
      borrowedPerson: borrowedPerson ?? this.borrowedPerson,
    );
  }

  // CONVERT FIRESTORE JSON TO BORROWED MODEL WITH SAFETY CHECKS
  factory BorrowedModel.fromJson(Map<String, dynamic> json, String id) {
    // SAFELY CONVERT TIMESTAMP TO DATETIME
    DateTime parsedBorrowedaddedDate;
    try {
      parsedBorrowedaddedDate = (json['borrowedaddedDate'] as Timestamp).toDate();
    } catch (e) {
      parsedBorrowedaddedDate = DateTime.now().toUtc(); // Default to current time if invalid
    }

    DateTime parsedBorrowedDueDate;
    try {
      parsedBorrowedDueDate = (json['borrowedDueDate'] as Timestamp).toDate();
    } catch (e) {
      parsedBorrowedDueDate = DateTime.now().toUtc(); // Default to current time if invalid
    }

    // SAFELY CONVERT NUMERIC VALUES WITH VALIDATION
    final borrowedAmount = (json['borrowedAmount'] as num?)?.toDouble() ?? 0.0;

    return BorrowedModel(
      uidOfBorrowed: id,
      borrowedaddedDate: parsedBorrowedaddedDate,
      borrowedAmount: borrowedAmount,
      borrowedDescription: json['borrowedDescription'] as String? ?? '',
      borrowedDueDate: parsedBorrowedDueDate,
      borrowedPerson: json['borrowedPerson'] as String? ?? '',
    );
  }

  // CONVERT BORROWED MODEL TO REGULAR JSON
  Map<String, dynamic> toJson() {
    return {
      'borrowedaddedDate': Timestamp.fromDate(borrowedaddedDate),
      'borrowedAmount': borrowedAmount,
      'borrowedDescription': borrowedDescription,
      'borrowedDueDate': Timestamp.fromDate(borrowedDueDate),
      'borrowedPerson': borrowedPerson,
    };
  }

  // CONVERT TO FIRESTORE-SPECIFIC JSON
  Map<String, dynamic> toFirestoreJson() {
    return {
      'borrowedaddedDate': Timestamp.fromDate(borrowedaddedDate),
      'borrowedAmount': borrowedAmount,
      'borrowedDescription': borrowedDescription,
      'borrowedDueDate': Timestamp.fromDate(borrowedDueDate),
      'borrowedPerson': borrowedPerson,
    };
  }

  // OVERRIDE EQUALITY FOR PROPER COMPARISON
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BorrowedModel &&
          uidOfBorrowed == other.uidOfBorrowed &&
          borrowedaddedDate.isAtSameMomentAs(other.borrowedaddedDate) &&
          borrowedAmount == other.borrowedAmount &&
          borrowedDescription == other.borrowedDescription &&
          borrowedDueDate.isAtSameMomentAs(other.borrowedDueDate) &&
          borrowedPerson == other.borrowedPerson;

  // OVERRIDE HASHCODE FOR PROPER SET/MAP OPERATIONS
  @override
  int get hashCode =>
      uidOfBorrowed.hashCode ^
      borrowedaddedDate.hashCode ^
      borrowedAmount.hashCode ^
      borrowedDescription.hashCode ^
      borrowedDueDate.hashCode ^
      borrowedPerson.hashCode;

  // STRING REPRESENTATION (SAFE)
  @override
  String toString() {
    return 'BorrowedModel(uidOfBorrowed: $uidOfBorrowed, borrowedAmount: $borrowedAmount, borrowedDescription: $borrowedDescription, borrowedDueDate: $borrowedDueDate, borrowedPerson: $borrowedPerson)';
  }

  // CONVERT TO DOMAIN ENTITY
  BorrowedEntity toEntity() {
    return BorrowedEntity(
      uidOfBorrowed: uidOfBorrowed,
      borrowedaddedDate: borrowedaddedDate,
      borrowedAmount: borrowedAmount,
      borrowedDescription: borrowedDescription,
      borrowedDueDate: borrowedDueDate,
      borrowedPerson: borrowedPerson,
    );
  }

  // CONVERT FROM DOMAIN ENTITY
  factory BorrowedModel.fromEntity(BorrowedEntity entity) {
    return BorrowedModel(
      uidOfBorrowed: entity.uidOfBorrowed,
      borrowedaddedDate: entity.borrowedaddedDate,
      borrowedAmount: entity.borrowedAmount,
      borrowedDescription: entity.borrowedDescription,
      borrowedDueDate: entity.borrowedDueDate,
      borrowedPerson: entity.borrowedPerson,
    );
  }
}
