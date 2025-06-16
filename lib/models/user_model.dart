class User {
  final String id;
  final String name;
  final String role;
  final String? specialty;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.specialty,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      name: map['full_name'].toString(),
      role: map['role'].toString(),
    );
  }
}
