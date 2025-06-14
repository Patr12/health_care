class User {
  final String id;
  final String name;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      name: map['name'].toString(),
      role: map['role'].toString(),
    );
  }
}