import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String uidOfIncome; // Represents the document ID
  final String incomeRemarks;
  final String incomeCategory;
  final double incomeAmount;
  final DateTime incomeDate; // Date provided by user in UI
  final DateTime createdAt; // Auto-generated when adding

  IncomeModel({
    required this.uidOfIncome,
    required this.incomeRemarks,
    required this.incomeCategory,
    required this.incomeAmount,
    required this.incomeDate,
    required this.createdAt,
  });

  // Factory method for creating the model from Firestore data
  factory IncomeModel.fromJson(Map<String, dynamic> json, String id) {
    return IncomeModel(
      uidOfIncome: id, // The Firestore document ID is used as uidOfTransaction
      incomeRemarks: json['incomeRemarks'] as String,
      incomeCategory: json['incomeCategory'] as String,
      incomeAmount: (json['incomeAmount'] as num).toDouble(),
      incomeDate: (json['incomeDate'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
      createdAt: (json['createdAt'] as Timestamp).toDate(), // Convert Firestore Timestamp to DateTime
    );
  }

  // Convert the model to JSON for saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'incomeRemarks': incomeRemarks,
      'incomeCategory': incomeCategory,
      'incomeAmount': incomeAmount,
      'incomeDate': Timestamp.fromDate(incomeDate), // Convert DateTime to Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt), // Convert DateTime to Firestore Timestamp
    };
  }
}
