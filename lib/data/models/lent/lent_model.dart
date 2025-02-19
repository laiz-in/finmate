import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moneyy/domain/entities/lent/lent.dart';


class LentModel {
  final String uidOfLent;
  final DateTime lentaddedDate;
  final double lentAmount;
  final String lentDescription;
  final DateTime lentReturnDate;
  final String lentPerson;

  LentModel({
    required this.uidOfLent,
    required this.lentaddedDate,
    required this.lentAmount,
    required this.lentDescription,
    required this.lentReturnDate,
    required this.lentPerson,
  });

  // FIRESTORE --> LENT MODEL
  factory LentModel.fromJson(Map<String, dynamic> json, String id) {
    return LentModel(
      uidOfLent: id,
      lentaddedDate: (json['lentaddedDate'] as Timestamp).toDate(),
      lentAmount: (json['lentAmount'] as num).toDouble(),
      lentDescription: json['lentDescription'] as String,
      lentReturnDate: (json['lentReturnDate'] as Timestamp).toDate(),
      lentPerson: json['lentPerson'] as String,
    );
  }

  // LENT MODEL --> JSON
  Map<String, dynamic> toJson() {
    return {
      'lentaddedDate': Timestamp.fromDate(lentaddedDate),
      'lentAmount': lentAmount,
      'lentDescription': lentDescription,
      'lentReturnDate': Timestamp.fromDate(lentReturnDate),
      'lentPerson': lentPerson,
    };
  }

  // CONVERT LENT MODEL TO DOMAIN ENTITY
  LentEntity toEntity() {
    return LentEntity(
      uidOfLent: uidOfLent,
      lentaddedDate: lentaddedDate,
      lentAmount: lentAmount,
      lentDescription: lentDescription,
      lentReturnDate: lentReturnDate,
      lentPerson: lentPerson,
    );
  }

  // CONVERT FROM DOMAIN ENTITY TO LENT MODEL
  factory LentModel.fromEntity(LentEntity entity) {
    return LentModel(
      uidOfLent: entity.uidOfLent,
      lentaddedDate: entity.lentaddedDate,
      lentAmount: entity.lentAmount,
      lentDescription: entity.lentDescription,
      lentReturnDate: entity.lentReturnDate,
      lentPerson: entity.lentPerson,
    );
  }
}
