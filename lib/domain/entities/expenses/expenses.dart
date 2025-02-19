class ExpensesEntity {
  final String uidOfTransaction;
  final String spendingDescription;
  final String spendingCategory;
  final double spendingAmount;
  final DateTime spendingDate;
  final DateTime createdAt;

  ExpensesEntity({
    required this.uidOfTransaction,
    required this.spendingDescription,
    required this.spendingCategory,
    required this.spendingAmount,
    required this.spendingDate,
    required this.createdAt,
  });
}
