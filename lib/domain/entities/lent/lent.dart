class LentEntity {
  final String uidOfLent;
  final DateTime lentaddedDate;
  final double lentAmount;
  final String lentDescription;
  final DateTime lentReturnDate;
  final String lentPerson;

  LentEntity({
    required this.uidOfLent,
    required this.lentaddedDate,
    required this.lentAmount,
    required this.lentDescription,
    required this.lentReturnDate,
    required this.lentPerson,
  });
}
