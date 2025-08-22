class BorrowedEntity {
  final String uidOfBorrowed;
  final DateTime borrowedaddedDate;
  final double borrowedAmount;
  final String borrowedDescription;
  final DateTime borrowedDueDate;
  final String borrowedPerson;

  BorrowedEntity({
    required this.uidOfBorrowed,
    required this.borrowedaddedDate,
    required this.borrowedAmount,
    required this.borrowedDescription,
    required this.borrowedDueDate,
    required this.borrowedPerson,
  });
}
