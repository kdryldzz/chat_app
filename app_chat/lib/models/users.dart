class Users {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final String password;

  Users({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.password,
  });

  // Map'ten User nesnesine dönüşüm
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      password: map['password'] as String,
    );
  }

  // User nesnesinden Map'e dönüşüm
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'password': password,
    };
  }
}
