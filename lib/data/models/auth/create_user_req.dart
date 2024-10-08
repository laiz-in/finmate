class UserCreateReq {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final DateTime createdAt;
  final int status; // Status representing the user's state (e.g., active, inactive)
  final double totalSpending; // Initial total spending
  final double dailyLimit; // Daily spending limit
  final double monthlyLimit; // Monthly spending limit
  final String? uid;

  UserCreateReq({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.uid,
    DateTime? createdAt,
    this.status = 0, // Default status to 0
    this.totalSpending = 0.0, // Default total spending to 0
    this.dailyLimit = 100.0, // Default daily limit
    this.monthlyLimit = 1000.0, // Default monthly limit
  }) : createdAt = createdAt ?? DateTime.now(); // Default createdAt to current time if not provided

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': createdAt,
      'status': status,
      'totalSpending': totalSpending,
      'dailyLimit': dailyLimit,
      'monthlyLimit': monthlyLimit,
      if (uid != null) 'uid': uid, // Include uid only if it's not null
    };
  }
}
