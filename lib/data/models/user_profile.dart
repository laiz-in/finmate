class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String currencyCode;
  final String currencySymbol;
  final double dailyBudget;
  final double monthlyBudget;
  final List<String> spendingCategories;

  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.currencyCode,
    required this.currencySymbol,
    required this.dailyBudget,
    required this.monthlyBudget,
    required this.spendingCategories,
  });

  String get fullName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'dailyBudget': dailyBudget,
      'monthlyBudget': monthlyBudget,
      'spendingCategories': spendingCategories,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      currencyCode: map['currencyCode'] as String,
      currencySymbol: map['currencySymbol'] as String,
      dailyBudget: (map['dailyBudget'] as num).toDouble(),
      monthlyBudget: (map['monthlyBudget'] as num).toDouble(),
      spendingCategories: List<String>.from(map['spendingCategories'] as List),
    );
  }
}