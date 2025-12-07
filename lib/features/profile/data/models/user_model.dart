class UserModel {
  final int id;
  final String username;
  final String email;
  final int? age;
  final int? gender; // 1 male, 2 female
  final int userType;
  late final int points;
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

  ///  إنشاء كائن من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? 0,
      points: json['points'] ?? 0,
      purchasesCount: json['purchases_count'] ?? 0,
      age: json['age'],
      gender: _parseGender(json['gender']),
    );
  }

  ///  تحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    final data = {
      "username": username,
      "age": age,
      "gender": gender,
    };

    // إزالة المفاتيح ذات القيمة null (مفضل في PATCH)
    data.removeWhere((key, value) => value == null);

    return data;
  }

  /// ️ دالة تحديث copyWith
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

  ///  دالة لتحديث النقاط محليًا بدون التأثير على الباك
  UserModel updatePoints(int newPoints) {
    return copyWith(points: newPoints);
  }

  ///  لعرض البيانات
  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, points: $points, purchases: $purchasesCount)';
  }

  ///  أداة لتحويل الجنس من JSON
  static int? _parseGender(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return (value == 1 || value == 2) ? value : null;
    }

    if (value is String) {
      if (value.toLowerCase() == "male") return 1;
      if (value.toLowerCase() == "female") return 2;
    }

    return null;
  }
}
