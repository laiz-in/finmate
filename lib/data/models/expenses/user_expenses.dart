import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyy/domain/entities/expenses/expenses.dart';


class ExpensesModel {
  final String uidOfTransaction;
  final String spendingDescription;
  final String spendingCategory;
  final double spendingAmount;
  final DateTime spendingDate;
  final DateTime createdAt;

  ExpensesModel({
    required this.uidOfTransaction,
    required this.spendingDescription,
    required this.spendingCategory,
    required this.spendingAmount,
    required this.spendingDate,
    required this.createdAt,
  });

  // FIRESTORE MODEL --> EXPENSE MODEL
  factory ExpensesModel.fromJson(Map<String, dynamic> json, String id) {
    return ExpensesModel(
      uidOfTransaction: id,
      spendingDescription: json['spendingDescription'] as String,
      spendingCategory: json['spendingCategory'] as String,
      spendingAmount: (json['spendingAmount'] as num).toDouble(),
      spendingDate: (json['spendingDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // FIRESTORE MODEL --> JSON
  Map<String, dynamic> toJson() {
    return {
      'spendingDescription': spendingDescription,
      'spendingCategory': spendingCategory,
      'spendingAmount': spendingAmount,
      'spendingDate': Timestamp.fromDate(spendingDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // CONVERT EXPENSES MODEL TO DOMAIN ENTITY
  ExpensesEntity toEntity() {
    return ExpensesEntity(
      uidOfTransaction: uidOfTransaction,
      spendingDescription: spendingDescription,
      spendingCategory: spendingCategory,
      spendingAmount: spendingAmount,
      spendingDate: spendingDate,
      createdAt: createdAt,
    );
  }

  // CONVERT FROM DOMAIN ENTITY TO EXPENSES MODEL
  factory ExpensesModel.fromEntity(ExpensesEntity entity) {
    return ExpensesModel(
      uidOfTransaction: entity.uidOfTransaction,
      spendingDescription: entity.spendingDescription,
      spendingCategory: entity.spendingCategory,
      spendingAmount: entity.spendingAmount,
      spendingDate: entity.spendingDate,
      createdAt: entity.createdAt,
    );
  }
}
