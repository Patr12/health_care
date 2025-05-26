import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/utils/config.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _currentIndex = 0;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final users = await _dbHelper.getAllUsers();
      final doctors = await _dbHelper.getVerifiedDoctors();
      final appointments = await _dbHelper.rawQuery(
        'SELECT a.*, u1.full_name as patient_name, u2.full_name as doctor_name FROM appointments a '
        'JOIN users u1 ON a.user_id = u1.id '
        'JOIN users u2 ON a.doctor_id = u2.id '
        'ORDER BY a.appointment_date DESC LIMIT 50',
      );

      setState(() {
        _users = users;
        _doctors = doctors;
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCurrentTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _buildUsersTab();
      case 1:
        return _buildDoctorsTab();
      case 2:
        return _buildAppointmentsTab();
      case 3:
        return _buildSettingsTab();
      default:
        return Container();
    }
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (query) {
              // Implement search functionality
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['full_name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['email'] ?? ''),
                      Text('Role: ${user['role']}'),
                      Text(user['is_verified'] == 1 ? 'Verified' : 'Not Verified'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit Role'),
                        onTap: () => _showEditRoleDialog(user['id'], user['role']),
                      ),
                      PopupMenuItem(
                        child: const Text('Delete User'),
                        onTap: () => _confirmDeleteUser(user['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search doctors...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddDoctorDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _doctors.length,
            itemBuilder: (context, index) {
              final doctor = _doctors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: Text(doctor['full_name'] ?? 'Unknown'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor['specialty'] ?? ''),
                      Text(doctor['hospital'] ?? ''),
                      Text('${doctor['experience_years']} years experience'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit Profile'),
                        onTap: () => _showEditDoctorDialog(doctor['id']),
                      ),
                      PopupMenuItem(
                        child: const Text('View Schedule'),
                        onTap: () => _showDoctorSchedule(doctor['id']),
                      ),
                      PopupMenuItem(
                        child: Text(doctor['is_verified'] == 1 ? 'Revoke Verification' : 'Verify'),
                        onTap: () => _toggleDoctorVerification(doctor['id'], doctor['is_verified'] != 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search appointments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                  DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                ],
                onChanged: (value) {
                  // Filter appointments by status
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _appointments.length,
            itemBuilder: (context, index) {
              final appointment = _appointments[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text('${appointment['patient_name']} with Dr. ${appointment['doctor_name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${appointment['appointment_date']} at ${appointment['appointment_time']}'),
                      Text('Status: ${appointment['status']}'),
                      Text('Reason: ${appointment['reason'] ?? 'Not specified'}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit Status'),
                        onTap: () => _showEditAppointmentStatusDialog(appointment['id'], appointment['status']),
                      ),
                      PopupMenuItem(
                        child: const Text('Cancel Appointment'),
                        onTap: () => _updateAppointmentStatus(appointment['id'], 'cancelled'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSystemSettingCard(
          'App Maintenance Mode',
          'maintenance_mode',
          'false',
          'Temporarily disable the app for maintenance',
        ),
        _buildSystemSettingCard(
          'New Registrations',
          'allow_registrations',
          'true',
          'Enable/disable new user registrations',
        ),
        _buildSystemSettingCard(
          'Appointment Booking',
          'allow_booking',
          'true',
          'Enable/disable new appointment bookings',
        ),
        _buildSystemSettingCard(
          'Doctor Verification Required',
          'doctor_verification',
          'true',
          'Require admin verification for new doctors',
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showAddSettingDialog,
          child: const Text('Add New System Setting'),
        ),
      ],
    );
  }

  Widget _buildSystemSettingCard(String title, String settingName, String defaultValue, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>?>(
              future: _dbHelper.rawQuery(
                'SELECT * FROM admin_controls WHERE setting_name = ?',
                [settingName],
              ).then((value) => value.isNotEmpty ? value.first : null),
              builder: (context, snapshot) {
                final currentValue = snapshot.data?['setting_value'] ?? defaultValue;
                return SwitchListTile(
                  title: Text('Current: $currentValue'),
                  value: currentValue == 'true',
                  onChanged: (value) {
                    _dbHelper.updateSystemSetting(
                      settingName,
                      value.toString(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Setting updated')),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Dialog methods
  Future<void> _showEditRoleDialog(int userId, String currentRole) async {
    final roleController = TextEditingController(text: currentRole);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User Role'),
        content: DropdownButtonFormField<String>(
          value: currentRole,
          items: const [
            DropdownMenuItem(value: 'patient', child: Text('Patient')),
            DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: (value) => roleController.text = value!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.updateUserRole(userId, roleController.text);
              _loadData();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDoctorDialog() async {
    // Implement doctor registration form
  }

  Future<void> _showEditDoctorDialog(int doctorId) async {
    // Implement doctor profile editing
  }

  Future<void> _showDoctorSchedule(int doctorId) async {
    final schedules = await _dbHelper.getDoctorSchedules(doctorId);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Doctor Schedule'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              return ListTile(
                title: Text(schedule['day_of_week']),
                subtitle: Text('${schedule['start_time']} - ${schedule['end_time']}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditAppointmentStatusDialog(int appointmentId, String currentStatus) async {
    final statusController = TextEditingController(text: currentStatus);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Appointment Status'),
        content: DropdownButtonFormField<String>(
          value: currentStatus,
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
          ],
          onChanged: (value) => statusController.text = value!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _updateAppointmentStatus(appointmentId, statusController.text);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSettingDialog() async {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final descriptionController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Setting'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Setting Name'),
            ),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: 'Default Value'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.insert('admin_controls', {
                'setting_name': nameController.text,
                'setting_value': valueController.text,
                'description': descriptionController.text,
              });
              _loadData();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Action methods
  Future<void> _confirmDeleteUser(int userId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.delete('users', where: 'id = ?', whereArgs: [userId]);
      _loadData();
    }
  }

  Future<void> _toggleDoctorVerification(int doctorId, bool verify) async {
    await _dbHelper.update(
      'users',
      {'is_verified': verify ? 1 : 0},
      where: 'id = ?',
      whereArgs: [doctorId],
    );
    _loadData();
  }

  Future<void> _updateAppointmentStatus(int appointmentId, String status) async {
    await _dbHelper.updateAppointmentStatus(appointmentId, status);
    _loadData();
  }
}