class Expense {
  final String id;
  final String uid;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final bool isSynced;

  const Expense({
    required this.id,
    required this.uid,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isSynced': isSynced,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as String,
      uid: map['uid'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      note: map['note'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  Expense copyWith({bool? isSynced}) {
    return Expense(
      id: id,
      uid: uid,
      amount: amount,
      category: category,
      note: note,
      date: date,
      createdAt: createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}