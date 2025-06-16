import 'package:health/models/user_model.dart';

class Doctor extends User {
  @override
  final String specialty;

  Doctor({
    required super.id,
    required super.name,
    required this.specialty,
  }) : super(role: 'doctor');
}