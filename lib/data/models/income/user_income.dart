import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyy/domain/entities/income/income.dart';



class IncomeModel {
  final String uidOfIncome;
  final String incomeRemarks;
  final String incomeCategory;
  final double incomeAmount;
  final DateTime incomeDate;
  final DateTime createdAt;

  IncomeModel({
    required this.uidOfIncome,
    required this.incomeRemarks,
    required this.incomeCategory,
    required this.incomeAmount,
    required this.incomeDate,
    required this.createdAt,
  });

  // FIRESTORE MODEL --> INCOME MODEL
  factory IncomeModel.fromJson(Map<String, dynamic> json, String id) {
    return IncomeModel(
      uidOfIncome: id,
      incomeRemarks: json['incomeRemarks'] as String,
      incomeCategory: json['incomeCategory'] as String,
      incomeAmount: (json['incomeAmount'] as num).toDouble(),
      incomeDate: (json['incomeDate'] as Timestamp).toDate(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // INCOME MODEL --> JSON
  Map<String, dynamic> toJson() {
    return {
      'incomeRemarks': incomeRemarks,
      'incomeCategory': incomeCategory,
      'incomeAmount': incomeAmount,
      'incomeDate': Timestamp.fromDate(incomeDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // CONVERT INCOME MODEL TO DOMAIN ENTITY
  IncomeEntity toEntity() {
    return IncomeEntity(
      uidOfIncome: uidOfIncome,
      incomeRemarks: incomeRemarks,
      incomeCategory: incomeCategory,
      incomeAmount: incomeAmount,
      incomeDate: incomeDate,
      createdAt: createdAt,
    );
  }

  // CONVERT FROM DOMAIN ENTITY TO INCOME MODEL
  factory IncomeModel.fromEntity(IncomeEntity entity) {
    return IncomeModel(
      uidOfIncome: entity.uidOfIncome,
      incomeRemarks: entity.incomeRemarks,
      incomeCategory: entity.incomeCategory,
      incomeAmount: entity.incomeAmount,
      incomeDate: entity.incomeDate,
      createdAt: entity.createdAt,
    );
  }
}
