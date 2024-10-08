import 'package:cloud_firestore/cloud_firestore.dart';

class ExpensesModel {
  final String uidOfTransaction; // Represents the document ID
  final String spendingDescription;
  final String spendingCategory;
  final double spendingAmount;
  final DateTime spendingDate; // Date provided by user in UI
  final DateTime createdAt; // Auto-generated when adding

  ExpensesModel({
    required this.uidOfTransaction,
    required this.spendingDescription,
    required this.spendingCategory,
    required this.spendingAmount,
    required this.spendingDate,
    required this.createdAt,
  });

  // Factory method for creating the model from Firestore data
  factory ExpensesModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpensesModel(
      uidOfTransaction: id, // The Firestore document ID is used as uidOfTransaction
      spendingDescription: json['spendingDescription'] as String,
      spendingCategory: json['spendingCategory'] as String,
      spendingAmount: (json['spendingAmount'] as num).toDouble(),
      spendingDate: (json['spendingDate'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
      createdAt: (json['createdAt'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  // Convert the model to JSON for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'spendingDescription': spendingDescription,
      'spendingCategory': spendingCategory,
      'spendingAmount': spendingAmount,
      'spendingDate': Timestamp.fromDate(spendingDate), // Convert DateTime to Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Firestore Timestamp
    };
  }
}
