import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String uidOfBill; // Represents the document ID
  final DateTime addedDate; // Auto-generated when adding
  final double billAmount;
  final String billDescription;
  final DateTime billDueDate;
  final String billTitle;
  final double paidStatus;

  BillModel({
    required this.uidOfBill,
    required this.addedDate,
    required this.billAmount,
    required this.billDescription,
    required this.billDueDate,
    required this.billTitle,
    required this.paidStatus
  });

  // Factory method for creating the model from Firestore data
  factory BillModel.fromJson(Map<String, dynamic> json, String id) {
    return BillModel(
      uidOfBill: id, // The Firestore document ID is used as uidOfTransaction
      addedDate: (json['addedDate'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
      billAmount: (json['billAmount'] as num).toDouble(),
      billDescription: json['billDescription'] as String,
      billDueDate: (json['billDueDate'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
      billTitle: json['billTitle'] as String,
      paidStatus: (json['paidStatus'] as num).toDouble(),
    );
  }

  // Convert the model to JSON for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'addedDate': Timestamp.fromDate(addedDate),
      'billAmount':billAmount,
      'billDescription': billDescription,
      'billDueDate': Timestamp.fromDate(billDueDate),
      'billTitle': billTitle,
      'paidStatus':paidStatus,
    };
  }
}
