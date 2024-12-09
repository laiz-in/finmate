class IncomeEntity {
  final String uidOfIncome;
  final String incomeRemarks;
  final String incomeCategory;
  final double incomeAmount;
  final DateTime incomeDate;
  final DateTime createdAt;

  IncomeEntity({
    required this.uidOfIncome,
    required this.incomeRemarks,
    required this.incomeCategory,
    required this.incomeAmount,
    required this.incomeDate,
    required this.createdAt,
  });
}
