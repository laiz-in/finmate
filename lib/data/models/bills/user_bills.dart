import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyy/domain/entities/bills/bills.dart';


class BillModel {
  // REQUIRED FIELDS WITH THEIR ORIGINAL TYPES
  final String uidOfBill;
  final DateTime addedDate;
  final double billAmount;
  final String billDescription;
  final DateTime billDueDate;
  final String billTitle;
  final double paidStatus;

  // CONSTRUCTOR WITH ORIGINAL DEFAULT VALUES
  BillModel({
    required this.uidOfBill,
    DateTime? addedDate,
    required this.billAmount,
    required this.billDescription,
    required this.billDueDate,
    required this.billTitle,
    this.paidStatus = 0.0,  // DEFAULT TO UNPAID STATUS
  }) : addedDate = addedDate?.toUtc() ?? DateTime.now().toUtc();  // ENSURE UTC TIME

  // COPY WITH METHOD FOR IMMUTABLE UPDATES
  BillModel copyWith({
    String? uidOfBill,
    DateTime? addedDate,
    double? billAmount,
    String? billDescription,
    DateTime? billDueDate,
    String? billTitle,
    double? paidStatus,
  }) {
    return BillModel(
      uidOfBill: uidOfBill ?? this.uidOfBill,
      addedDate: addedDate ?? this.addedDate,
      billAmount: billAmount ?? this.billAmount,
      billDescription: billDescription ?? this.billDescription,
      billDueDate: billDueDate ?? this.billDueDate,
      billTitle: billTitle ?? this.billTitle,
      paidStatus: paidStatus ?? this.paidStatus,
    );
  }

  // CONVERT FIREBASE JSON TO BILL MODEL WITH SAFETY CHECKS
  factory BillModel.fromJson(Map<String, dynamic> json, String id) {
    // VALIDATE REQUIRED FIELDS
    if (id.isEmpty) {
      throw Exception('Invalid UID in data');
    }

    // SAFELY CONVERT TIMESTAMP OR STRING TO DATETIME
    DateTime parsedAddedDate;
    DateTime parsedBillDueDate;
    try {
      parsedAddedDate = json['addedDate'] is Timestamp
          ? (json['addedDate'] as Timestamp).toDate().toUtc()
          : json['addedDate'] != null
              ? DateTime.parse(json['addedDate'].toString()).toUtc()
              : DateTime.now().toUtc();

      parsedBillDueDate = json['billDueDate'] is Timestamp
          ? (json['billDueDate'] as Timestamp).toDate().toUtc()
          : json['billDueDate'] != null
              ? DateTime.parse(json['billDueDate'].toString()).toUtc()
              : DateTime.now().toUtc();
    } catch (e) {
      parsedAddedDate = DateTime.now().toUtc();
      parsedBillDueDate = DateTime.now().toUtc();
    }

    // SAFELY CONVERT NUMERIC VALUES WITH VALIDATION
    final billAmount = (json['billAmount'] as num?)?.toDouble() ?? 0.0;
    final paidStatus = (json['paidStatus'] as num?)?.toDouble() ?? 0.0;

    // BASIC BUSINESS RULE VALIDATION
    if (billAmount < 0) {
      throw Exception('Bill amount cannot be negative');
    }
    if (paidStatus < 0 || paidStatus > 1) {
      throw Exception('Paid status must be between 0 and 1');
    }

    return BillModel(
      uidOfBill: id.trim(),
      addedDate: parsedAddedDate,
      billAmount: billAmount,
      billDescription: (json['billDescription'] as String?)?.trim() ?? '',
      billDueDate: parsedBillDueDate,
      billTitle: (json['billTitle'] as String?)?.trim() ?? '',
      paidStatus: paidStatus,
    );
  }

  // CONVERT BILL MODEL TO REGULAR JSON
  Map<String, dynamic> toJson() {
    return {
      'addedDate': Timestamp.fromDate(addedDate.toUtc()),  // PROPER TIMESTAMP CONVERSION
      'billAmount': billAmount,
      'billDescription': billDescription.trim(),
      'billDueDate': Timestamp.fromDate(billDueDate.toUtc()),  // PROPER TIMESTAMP CONVERSION
      'billTitle': billTitle.trim(),
      'paidStatus': paidStatus,
    };
  }

  // CONVERT BILL MODEL TO DOMAIN ENTITY
  BillsEntity toEntity() {
    return BillsEntity(
      uidOfBill: uidOfBill,
      addedDate: addedDate,
      billAmount: billAmount,
      billDescription: billDescription,
      billDueDate: billDueDate,
      billTitle: billTitle,
      paidStatus: paidStatus,
    );
  }

  // CONVERT FROM DOMAIN ENTITY TO BILL MODEL
  factory BillModel.fromEntity(BillsEntity entity) {
    return BillModel(
      uidOfBill: entity.uidOfBill,
      addedDate: entity.addedDate,
      billAmount: entity.billAmount,
      billDescription: entity.billDescription,
      billDueDate: entity.billDueDate,
      billTitle: entity.billTitle,
      paidStatus: entity.paidStatus,
    );
  }

  // OVERRIDE EQUALITY FOR PROPER COMPARISON
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillModel &&
          uidOfBill == other.uidOfBill &&
          addedDate.isAtSameMomentAs(other.addedDate) &&
          billAmount == other.billAmount &&
          billDescription == other.billDescription &&
          billDueDate.isAtSameMomentAs(other.billDueDate) &&
          billTitle == other.billTitle &&
          paidStatus == other.paidStatus;

  // OVERRIDE HASHCODE FOR PROPER SET/MAP OPERATIONS
  @override
  int get hashCode =>
      uidOfBill.hashCode ^
      addedDate.hashCode ^
      billAmount.hashCode ^
      billDescription.hashCode ^
      billDueDate.hashCode ^
      billTitle.hashCode ^
      paidStatus.hashCode;
}
