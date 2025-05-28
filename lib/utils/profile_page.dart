import 'package:flutter/material.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/data/database_helper.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.userId, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  late Future<Map<String, dynamic>?> userFuture;
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? email;
  String? role;
  String? phoneNumber;
  String? dateOfBirth;
  String? bloodType;
  String? gender;

  // Define valid options for dropdowns
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    userFuture = _loadUserData();
  }

  Future<Map<String, dynamic>?> _loadUserData() async {
    return await dbHelper.getUserById(widget.userId);
  }

  Future<void> updateProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updates = {
        'full_name': name,
        'email': email,
        'phone_number': phoneNumber,
        'date_of_birth': dateOfBirth,
        'blood_type': bloodType,
        'gender': gender,
      };

      await dbHelper.updateUserProfile(widget.userId, updates);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        userFuture = _loadUserData();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        dateOfBirth = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // Helper function to validate dropdown values
  String? _validateDropdownValue(String? value, List<String> validOptions) {
    if (value == null || value.isEmpty) return null;
    return validOptions.contains(value) ? value : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(appTitle: "My Profile"),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("User not found"));
          }

          final user = snapshot.data!;
          name = user['full_name'];
          email = user['email'];
          role = user['role'];
          phoneNumber = user['phone_number'];
          dateOfBirth = user['date_of_birth'];

          // Validate and set dropdown values
          bloodType = _validateDropdownValue(user['blood_type'], bloodTypes);
          gender = _validateDropdownValue(user['gender'], genders);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            user['image'] != null
                                ? NetworkImage(user['image'])
                                : null,
                        child:
                            user['image'] == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // User Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role ?? ''),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role?.toUpperCase() ?? 'USER',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Profile Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildProfileField(
                        label: 'Full Name',
                        initialValue: name,
                        onSaved: (value) => name = value,
                        icon: Icons.person,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Email',
                        initialValue: email,
                        onSaved: (value) => email = value,
                        icon: Icons.email,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Required'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileField(
                        label: 'Phone Number',
                        initialValue: phoneNumber,
                        onSaved: (value) => phoneNumber = value,
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildProfileField(
                            label: 'Date of Birth',
                            initialValue: dateOfBirth,
                            onSaved: (value) => dateOfBirth = value,
                            icon: Icons.calendar_today,
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: bloodType,
                        decoration: InputDecoration(
                          labelText: 'Blood Type',
                          prefixIcon: const Icon(Icons.bloodtype),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items:
                            bloodTypes
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => bloodType = value,
                        onSaved: (value) => bloodType = value,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: gender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        items:
                            genders
                                .map(
                                  (gender) => DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) => gender = value,
                        onSaved: (value) => gender = value,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                          child: const Text(
                            "UPDATE PROFILE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: widget.onLogout,
                        child: const Text(
                          "LOGOUT",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String? initialValue,
    required FormFieldSetter<String> onSaved,
    IconData? icon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.redAccent;
      case 'doctor':
        return Colors.blueAccent;
      case 'patient':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }
}
