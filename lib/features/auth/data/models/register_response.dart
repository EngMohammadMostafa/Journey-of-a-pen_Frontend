class RegisterResponse {
  final String token;
  final User user;

  RegisterResponse({required this.token, required this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }

  get message => null;
}

class User {
  final int id;
  final String username;
  final String email;
  final int userType;
  final int points;
  

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.userType,
    required this.points,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      userType: json['user_type'],
      points: json['points'],
    );
  }
}
