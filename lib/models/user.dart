class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String gender;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      gender: json['gender'],
      role: json['role'],
    );
  }
}
