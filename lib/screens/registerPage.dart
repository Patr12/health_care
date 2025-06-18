import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/screens/doctor_dashboard.dart';
import 'package:health/screens/admin_dashboard.dart';
import 'package:health/screens/home_screen.dart';
import 'package:health/screens/loginPage.dart';
import 'package:health/utils/config.dart';
import 'package:health/utils/text.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _selectedRole = DatabaseHelper.ROLE_PATIENT;
  String? _licenseNumber;
  String? _specialty;

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final userData = {
      'full_name': nameController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'phone_number': phoneController.text,
      'date_of_birth': '', // Add date picker later
      'blood_type': '', // Add dropdown later
      'role': _selectedRole,
    };

    // Handle different registration flows based on role
    if (_selectedRole == DatabaseHelper.ROLE_DOCTOR) {
      if (_licenseNumber == null || _licenseNumber!.isEmpty) {
        throw Exception('License number is required for doctors');
      }
      if (_specialty == null || _specialty!.isEmpty) {
        throw Exception('Specialty is required for doctors');
      }

      final doctorProfile = {
        'specialty': _specialty!,
        'license_number': _licenseNumber!,
        'hospital': '', // Can be added later
        'experience_years': 0, // Can be added later
        'consultation_fee': 0.0, // Can be added later
      };

      await _dbHelper.registerDoctor(userData, doctorProfile);
    } else {
      await _dbHelper.registerUser(userData, role: _selectedRole);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Registered successfully!")),
    );

    // Navigate to appropriate dashboard based on role
    Widget destination;
    switch (_selectedRole) {
      case DatabaseHelper.ROLE_DOCTOR:
        final userId = await _dbHelper.getUserIdByEmail(emailController.text);
        destination = DoctorDashboard(
          doctorId: userId.toString(),
          doctorName: nameController.text,
        );
        break;
      case DatabaseHelper.ROLE_ADMIN:
        destination = const AdminDashboard();
        break;
      case DatabaseHelper.ROLE_PATIENT:
      default:
        destination = HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error: ${e.toString()}")),
    );
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Register as:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Patient'),
                value: DatabaseHelper.ROLE_PATIENT,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Doctor'),
                value: DatabaseHelper.ROLE_DOCTOR,
                groupValue: _selectedRole,
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
            ),
          ],
        ),
        if (_selectedRole == DatabaseHelper.ROLE_DOCTOR) ...[
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'License Number',
              prefixIcon: Icon(Icons.medical_services),
            ),
            validator:
                (value) => value!.isEmpty ? 'License number is required' : null,
            onChanged: (value) => _licenseNumber = value,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Specialty',
              prefixIcon: Icon(Icons.work),
            ),
            validator:
                (value) => value!.isEmpty ? 'Specialty is required' : null,
            onChanged: (value) => _specialty = value,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),

                Center(
                  child: Text(
                    AppText.enText['welcome_text']!,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 350,
                    height: 100,
                    child: Image.asset("assets/home_banner.png"),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: 230,
                    height: 280,
                    child: Image.asset("assets/register.png"),
                  ),
                ),
                Center(
                  child: Text(
                    AppText.enText['register_text']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Config.spaceSmall,
                const SizedBox(height: 30),
                _buildRoleSelector(),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator:
                      (value) => value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator:
                      (value) =>
                          !value!.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator:
                      (value) =>
                          value!.length < 6
                              ? 'Password must be at least 6 characters'
                              : null,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            onPressed: _register,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginForm(),
                      ),
                    );
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
