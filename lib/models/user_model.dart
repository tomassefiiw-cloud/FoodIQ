class UserModel {
  final String id;
  final String name;
  final String email;
  final int calorieGoal;
  final int waterGoal;
  final bool isPremium;
  final DateTime? premiumExpiry;
  final int age;
  final double weight;
  final double height;
  final String gender;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.calorieGoal = 2000,
    this.waterGoal = 2000,
    this.isPremium = false,
    this.premiumExpiry,
    this.age = 25,
    this.weight = 70.0,
    this.height = 170.0,
    this.gender = 'Not specified',
    required this.createdAt,
  });

  bool get isPremiumActive => isPremium && (premiumExpiry?.isAfter(DateTime.now()) ?? false);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'calorie_goal': calorieGoal,
    'water_goal': waterGoal,
    'is_premium': isPremium,
    'premium_expiry': premiumExpiry?.toIso8601String(),
    'age': age,
    'weight': weight,
    'height': height,
    'gender': gender,
    'created_at': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    calorieGoal: (json['calorie_goal'] as num?)?.toInt() ?? 2000,
    waterGoal: (json['water_goal'] as num?)?.toInt() ?? 2000,
    isPremium: (json['is_premium'] as bool?) ?? false,
    premiumExpiry: json['premium_expiry'] != null ? DateTime.parse(json['premium_expiry'] as String) : null,
    age: (json['age'] as num?)?.toInt() ?? 25,
    weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
    height: (json['height'] as num?)?.toDouble() ?? 170.0,
    gender: (json['gender'] as String?) ?? 'Not specified',
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  UserModel copyWith({
    String? name,
    String? email,
    int? calorieGoal,
    int? waterGoal,
    bool? isPremium,
    DateTime? premiumExpiry,
    int? age,
    double? weight,
    double? height,
    String? gender,
  }) => UserModel(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    calorieGoal: calorieGoal ?? this.calorieGoal,
    waterGoal: waterGoal ?? this.waterGoal,
    isPremium: isPremium ?? this.isPremium,
    premiumExpiry: premiumExpiry ?? this.premiumExpiry,
    age: age ?? this.age,
    weight: weight ?? this.weight,
    height: height ?? this.height,
    gender: gender ?? this.gender,
    createdAt: createdAt,
  );
}
