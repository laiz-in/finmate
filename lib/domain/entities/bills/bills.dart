class BillsEntity {
  final String uidOfBill;
  final DateTime addedDate;
  final double billAmount;
  final String billDescription;
  final DateTime billDueDate;
  final String billTitle;
  final double paidStatus;

  BillsEntity({
    required this.uidOfBill,
    required this.addedDate,
    required this.billAmount,
    required this.billDescription,
    required this.billDueDate,
    required this.billTitle,
    required this.paidStatus
  });
}
