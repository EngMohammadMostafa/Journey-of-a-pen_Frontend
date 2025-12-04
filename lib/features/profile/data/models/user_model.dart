class UserModel {
  final int id;
  final String username;
  final String email;
  final int? age;
  final int? gender;
  final int userType;
  final int points;
  final int purchasesCount;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    required this.points,
    required this.purchasesCount,
    this.age,
    this.gender,
  });

  /// 🟩 إنشاء كائن من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? 0,
      points: json['points'] ?? 0,
      purchasesCount: json['purchases_count'] ?? 0,
      age: json['age'],
      gender: json['gender'],
    );
  }

  /// 🔄 تحويل الكائن إلى JSON لتحديث المستخدم
  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "age": age,
      "gender": gender,
      // ملاحظات: لا نرسل points أو purchasesCount لأنها محسوبة في الباك
    };
  }

  /// ✏️ دالة copyWith لتحديث القيم بسهولة
  UserModel copyWith({
    String? username,
    String? email,
    int? age,
    int? gender,
    int? userType,
    int? points,
    int? purchasesCount,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      points: points ?? this.points,
      purchasesCount: purchasesCount ?? this.purchasesCount,
      age: age ?? this.age,
      gender: gender ?? this.gender,
    );
  }

  /// 🧩 لتحسين عرض البيانات (debug)
  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, points: $points, purchases: $purchasesCount)';
  }
}
