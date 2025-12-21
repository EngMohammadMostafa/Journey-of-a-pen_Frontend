class UserLiteModel {
  final int id;
  final String username;

  UserLiteModel({
    required this.id,
    required this.username,
  });

  factory UserLiteModel.fromJson(Map<String, dynamic> json) {
    return UserLiteModel(
      id: json['id'],
      username: json['username'],
    );
  }
}
