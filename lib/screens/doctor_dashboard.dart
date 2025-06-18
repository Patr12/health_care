import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/screens/loginPage.dart';
import 'package:health/screens/patient_message_screen.dart';
import 'package:health/utils/contacts_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'dart:async';

class DoctorDashboard extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  const DoctorDashboard({
    required this.doctorId,
    required this.doctorName,
    super.key,
  });

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic> _doctor = {}; // Initialize as empty map instead of late
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  String _doctorName = "Doctor";
  int _unreadMessagesCount = 0;
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctorData();
      _loadUnreadMessagesCount();
      // Check for new messages every 30 seconds
      _notificationTimer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) => _loadUnreadMessagesCount(),
      );
    });
  }

  Future<void> _loadUnreadMessagesCount() async {
    try {
      final count = await DatabaseHelper().getUnreadMessagesCount(
        widget.doctorId,
      );
      if (mounted) {
        setState(() => _unreadMessagesCount = count);
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  Future<void> _deleteSchedule(int scheduleId) async {
    try {
      await _dbHelper.deleteDoctorSchedule(scheduleId);
      await _loadDoctorData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule deleted successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting schedule: ${e.toString()}")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getDoctorSchedules(int doctorId) async {
    final db = await _dbHelper.database;
    try {
      final schedules = await db.query(
        'doctor_schedules',
        where: 'doctor_id = ?',
        whereArgs: [doctorId],
      );

      debugPrint('Fetched ${schedules.length} schedules for doctor $doctorId');
      return schedules;
    } catch (e) {
      debugPrint('Error getting doctor schedules: $e');
      return [];
    }
  }

  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        throw Exception('No user ID found in storage');
      }

      // Load all doctor data in parallel with explicit types
      final results = await Future.wait([
        _dbHelper.getCurrentUser() as Future<Map<String, dynamic>?>,
        _dbHelper.getDoctorProfile(userId),
        _dbHelper.getDoctorAppointments(userId),
        _dbHelper.getDoctorSchedules(userId),
        _dbHelper.getConversation(userId, 0),
      ]);

      final currentUser = results[0] as Map<String, dynamic>?;
      final doctorProfile = results[1] as Map<String, dynamic>?;
      final appointments = results[2] as List<Map<String, dynamic>>;
      final schedules = results[3] as List<Map<String, dynamic>>;

      if (currentUser == null || doctorProfile == null) {
        throw Exception('Doctor profile not found');
      }

      setState(() {
        _doctor = {...currentUser, ...doctorProfile};
        _doctorName = _doctor['full_name'] ?? "Doctor";
        _appointments = appointments;
        _schedules = schedules;
        _isLoading = false;
      });

      // Update stored name if different
      if (_doctor['full_name'] != null) {
        await prefs.setString('userName', _doctor['full_name']);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: ${e.toString()}")),
      );
      debugPrint('Error loading doctor data: $e');
    }
  }

  Future<void> _updateAppointmentStatus(
    int appointmentId,
    String status,
  ) async {
    try {
      await _dbHelper.updateAppointmentStatus(appointmentId, status);
      await _loadDoctorData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Appointment $status successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating appointment: ${e.toString()}")),
      );
    }
  }

  Future<int> addDoctorSchedule(
    int doctorId,
    Map<String, dynamic> schedule,
  ) async {
    final db = _dbHelper;
    try {
      // Validate input data first
      if (doctorId <= 0) {
        throw ArgumentError('Invalid doctor ID');
      }

      if (schedule['day_of_week'] == null ||
          schedule['start_time'] == null ||
          schedule['end_time'] == null) {
        throw ArgumentError('Missing required schedule fields');
      }

      final id = await db.insert('doctor_schedules', {
        'doctor_id': doctorId,
        'day_of_week': schedule['day_of_week'],
        'start_time': schedule['start_time'],
        'end_time': schedule['end_time'],
      });

      if (id <= 0) {
        throw Exception('Insert operation returned invalid ID');
      }

      debugPrint('Added schedule with ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error adding doctor schedule: $e');
      if (e is sql.DatabaseException) {
        debugPrint('Database error details: ${e.toString()}');
        debugPrint('Result: ${e.getResultCode()}');
      }
      return -1;
    }
  }

  Future<void> _addSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null || userId <= 0) {
        throw Exception('No valid user ID found in SharedPreferences');
      }

      debugPrint('Adding schedule for doctor ID: $userId');
      debugPrint('Schedule data: $scheduleData');

      // Validate schedule data before insertion
      if (scheduleData['day_of_week'] == null ||
          scheduleData['start_time'] == null ||
          scheduleData['end_time'] == null) {
        throw Exception('Incomplete schedule data provided');
      }

      final result = await _dbHelper.addDoctorSchedule(userId, scheduleData);

      if (result > 0) {
        await _loadDoctorData(); // Refresh the data

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Schedule added successfully")),
          );
        }

        debugPrint('Current schedules count: ${_schedules.length}');
      } else {
        throw Exception('Database insertion failed (returned ID: $result)');
      }
    } catch (e) {
      debugPrint('Error in _addSchedule: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding schedule: ${e.toString()}")),
        );
      }
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. $_doctorName Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctorData,
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              PatientMessagesScreen(doctorId: widget.doctorId),
                    ),
                  ).then((_) => _loadUnreadMessagesCount());
                },
              ),
              if (_unreadMessagesCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$_unreadMessagesCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildSelectedTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      // Add this to your Scaffold's floatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getInt('userId');
          debugPrint('Current user ID: $userId');
          debugPrint('Current schedules: $_schedules');
          final dbSchedules = await _dbHelper.getDoctorSchedules(userId ?? 0);
          debugPrint('DB schedules: $dbSchedules');
        },
        child: const Icon(Icons.bug_report),
      ),
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedTab) {
      case 0:
        return _buildAppointmentsTab();
      case 1:
        return _buildScheduleTab();
      case 2:
        return ContactsListScreen();
      case 3:
        return _buildProfileTab();
      default:
        return Container();
    }
  }

  Widget _buildAppointmentsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Today: ${DateFormat('EEEE, MMM d').format(DateTime.now())}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: 'all',
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                    value: 'confirmed',
                    child: Text('Confirmed'),
                  ),
                ],
                onChanged: (value) {
                  // Filter appointments
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
                  title: Text(
                    'Patient: ${appointment['user_id']}',
                  ), // Should be patient name
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${appointment['appointment_date']} at ${appointment['appointment_time']}',
                      ),
                      Text(
                        'Reason: ${appointment['reason'] ?? 'Not specified'}',
                      ),
                      Text(
                        'Status: ${appointment['status']}',
                        style: TextStyle(
                          color: _getStatusColor(appointment['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          if (appointment['status'] == 'pending')
                            const PopupMenuItem(
                              value: 'confirm',
                              child: Text('Confirm Appointment'),
                            ),
                          if (appointment['status'] == 'confirmed')
                            const PopupMenuItem(
                              value: 'complete',
                              child: Text('Mark as Completed'),
                            ),
                          const PopupMenuItem(
                            value: 'cancel',
                            child: Text('Cancel Appointment'),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'confirm') {
                        _updateAppointmentStatus(
                          appointment['id'],
                          'confirmed',
                        );
                      } else if (value == 'complete') {
                        _updateAppointmentStatus(
                          appointment['id'],
                          'completed',
                        );
                      } else if (value == 'cancel') {
                        _updateAppointmentStatus(
                          appointment['id'],
                          'cancelled',
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text(
                'Your Availability',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddScheduleDialog(),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _schedules.isEmpty
                  ? const Center(
                    child: Text(
                      'No schedules available\nAdd your availability',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    itemCount: _schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = _schedules[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            schedule['day_of_week'] ?? 'Day not specified',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${schedule['start_time'] ?? ''} - ${schedule['end_time'] ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSchedule(schedule['id']),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    if (_doctor.isEmpty || _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    String getDoctorValue(String key, [String defaultValue = 'Not provided']) {
      final value = _doctor[key];
      return value?.toString() ?? defaultValue;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue[100],
              child: Text(
                getDoctorValue('full_name', 'D').substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileItem('Full Name', getDoctorValue('full_name')),
          _buildProfileItem('Email', getDoctorValue('email')),
          _buildProfileItem('Phone', getDoctorValue('phone_number')),
          _buildProfileItem(
            'Specialty',
            getDoctorValue('specialty', 'No specialty'),
          ),
          _buildProfileItem(
            'Hospital',
            getDoctorValue('hospital', 'No hospital'),
          ),
          _buildProfileItem(
            'Experience',
            '${getDoctorValue('experience_years', '0')} years',
          ),
          _buildProfileItem(
            'Consultation Fee',
            '\$${getDoctorValue('consultation_fee', '0')}',
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                // Implement edit profile
              },
              child: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: _confirmLogout,
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (shouldLogout == true) {
      await _performLogout();
    }
  }

  Future<void> _performLogout() async {
    setState(() => _isLoading = true);

    try {
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Navigate to login screen
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginForm()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showAddScheduleDialog() async {
    final dayController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add New Schedule'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Day of Week'),
                  items: const [
                    DropdownMenuItem(value: 'Monday', child: Text('Monday')),
                    DropdownMenuItem(value: 'Tuesday', child: Text('Tuesday')),
                    DropdownMenuItem(
                      value: 'Wednesday',
                      child: Text('Wednesday'),
                    ),
                    DropdownMenuItem(
                      value: 'Thursday',
                      child: Text('Thursday'),
                    ),
                    DropdownMenuItem(value: 'Friday', child: Text('Friday')),
                    DropdownMenuItem(
                      value: 'Saturday',
                      child: Text('Saturday'),
                    ),
                    DropdownMenuItem(value: 'Sunday', child: Text('Sunday')),
                  ],
                  onChanged: (value) => dayController.text = value!,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Start Time',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      startTimeController.text = time.format(context);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(
                    labelText: 'End Time',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      endTimeController.text = time.format(context);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (dayController.text.isNotEmpty &&
                      startTimeController.text.isNotEmpty &&
                      endTimeController.text.isNotEmpty) {
                    _addSchedule({
                      'day_of_week': dayController.text,
                      'start_time': startTimeController.text,
                      'end_time': endTimeController.text,
                    });
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
