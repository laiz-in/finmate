class Owe {
  final String id;
  final String uid;
  final String personName;
  final double amount;
  final DateTime dueDate;
  final String note;
  final DateTime createdAt;
  final bool isSettled;
  final DateTime? settledAt;
  final String? settledNote;
  final bool isSynced;

  const Owe({
    required this.id,
    required this.uid,
    required this.personName,
    required this.amount,
    required this.dueDate,
    required this.note,
    required this.createdAt,
    required this.isSettled,
    this.settledAt,
    this.settledNote,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'personName': personName,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'isSettled': isSettled,
      'settledAt': settledAt?.toIso8601String(),
      'settledNote': settledNote,
      'isSynced': isSynced,
    };
  }

  factory Owe.fromMap(Map<String, dynamic> map) {
    return Owe(
      id: map['id'] as String,
      uid: map['uid'] as String,
      personName: map['personName'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate'] as String),
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['createdAt'] as String),
      isSettled: map['isSettled'] as bool? ?? false,
      settledAt: map['settledAt'] != null ? DateTime.parse(map['settledAt'] as String) : null,
      settledNote: map['settledNote'] as String?,
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }

  Owe copyWith({bool? isSynced, bool? isSettled, DateTime? settledAt, String? settledNote}) {
    return Owe(
      id: id,
      uid: uid,
      personName: personName,
      amount: amount,
      dueDate: dueDate,
      note: note,
      createdAt: createdAt,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      settledNote: settledNote ?? this.settledNote,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}