import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
// import your DB helper

class UserDetails extends StatefulWidget {
  final int userId; // pass userId to this page
  const UserDetails({super.key, required this.userId});

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final dbHelper = DatabaseHelper();

  // User fields
  String firstName = "";
  String lastName = "";
  String email = "";
  String contactNumber = "";
  String dateOfBirth = "";
  String gender = "";
  String bloodGroup = "";
  String maritalStatus = "";
  String height = "";
  String weight = "";

  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final db = await dbHelper.database;
    // Adjust this query to your DB schema (assuming a 'users' table with fields you want)
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [widget.userId],
    );

    if (result.isNotEmpty) {
      var user = result.first;
      setState(() {
        firstName = user['full_name']?.split(' ').first ?? "";
        lastName = user['full_name']?.split(' ').length > 1 ? user['full_name']?.split(' ')[1] : "";
        email = user['email'] ?? "";
        contactNumber = user['phone_number'] ?? "";
        dateOfBirth = user['date_of_birth'] ?? "";
        gender = user['gender'] ?? "";
        bloodGroup = user['blood_type'] ?? "";
        maritalStatus = user['marital_status'] ?? "";
        height = user['height']?.toString() ?? "";
        weight = user['weight']?.toString() ?? "";
      });
    }
  }

  Future<void> saveUserData() async {
    final db = await dbHelper.database;
    // Combine firstName and lastName to full_name
    String fullName = "$firstName $lastName";

    await db.update(
      'users',
      {
        'full_name': fullName,
        'email': email,
        'phone_number': contactNumber,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'blood_type': bloodGroup,
        'marital_status': maritalStatus,
        'height': double.tryParse(height) ?? 0,
        'weight': double.tryParse(weight) ?? 0,
      },
      where: 'id = ?',
      whereArgs: [widget.userId],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          isEditing
              ? IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    await saveUserData();
                    setState(() {
                      isEditing = false;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      isEditing = true;
                    });
                  },
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/profile1.jpg'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: buildTextFormField(
                      "First Name", firstName, "Enter first name",
                      isEditing ? (val) => setState(() => firstName = val) : null),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: buildTextFormField(
                      "Last Name", lastName, "Enter last name",
                      isEditing ? (val) => setState(() => lastName = val) : null),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: buildTextFormField(
                      "Email", email, "Enter email",
                      isEditing ? (val) => setState(() => email = val) : null),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: buildTextFormField(
                      "Contact Number", contactNumber, "Enter contact number",
                      isEditing ? (val) => setState(() => contactNumber = val) : null),
                ),
              ],
            ),
            // Repeat for other fields...
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: buildTextFormField(
                      "Date of Birth", dateOfBirth, "Enter date of birth",
                      isEditing ? (val) => setState(() => dateOfBirth = val) : null),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: buildTextFormField(
                      "Gender", gender, "Enter gender",
                      isEditing ? (val) => setState(() => gender = val) : null),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: buildTextFormField(
                      "Blood Group", bloodGroup, "Enter blood group",
                      isEditing ? (val) => setState(() => bloodGroup = val) : null),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: buildTextFormField(
                      "Marital Status", maritalStatus, "Enter marital status",
                      isEditing ? (val) => setState(() => maritalStatus = val) : null),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: buildTextFormField(
                      "Height", height, "Enter height",
                      isEditing ? (val) => setState(() => height = val) : null),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: buildTextFormField(
                      "Weight", weight, "Enter weight",
                      isEditing ? (val) => setState(() => weight = val) : null),
                ),
              ],
            ),
            SizedBox(height: 20),
            if (isEditing)
              ElevatedButton(
                onPressed: () async {
                  await saveUserData();
                  setState(() {
                    isEditing = false;
                  });
                },
                child: Text("Save"),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField(String label, String value, String hintText,
      ValueChanged<String>? onChanged) {
    return TextFormField(
      initialValue: value,
      enabled: isEditing,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
      ),
    );
  }
}
