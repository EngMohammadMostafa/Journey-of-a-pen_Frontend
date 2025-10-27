class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final int age;
  final String gender;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.age,
    required this.gender,
  });

  Map<String, dynamic> toJson() => {
    "username": username,
    "email": email,
    "password": password,
    "age": age,
    "gender": gender,
  };
}
