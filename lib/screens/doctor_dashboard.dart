import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:intl/intl.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Map<String, dynamic> _doctor;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    try {
      final currentUser = await _dbHelper.getCurrentUser();
      final doctorProfile = await _dbHelper.getDoctorProfile(currentUser['id']);
      final appointments = await _dbHelper.getDoctorAppointments(
        currentUser['id'],
      );
      final schedules = await _dbHelper.getDoctorSchedules(currentUser['id']);
      final messages = await _dbHelper.getConversation(
        currentUser['id'],
        0,
      ); // 0 for admin

      setState(() {
        _doctor = {...currentUser, ...?doctorProfile};
        _appointments = appointments;
        _schedules = schedules;
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading data: ${e.toString()}")),
      );
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

  Future<void> _addSchedule(Map<String, dynamic> scheduleData) async {
    try {
      final currentUser = await _dbHelper.getCurrentUser();
      await _dbHelper.addDoctorSchedule(currentUser['id'], scheduleData);
      await _loadDoctorData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Schedule added successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding schedule: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${_doctor['full_name']} Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctorData,
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
    );
  }

  Widget _buildSelectedTab() {
    switch (_selectedTab) {
      case 0:
        return _buildAppointmentsTab();
      case 1:
        return _buildScheduleTab();
      case 2:
        return _buildMessagesTab();
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
          child: ListView.builder(
            itemCount: _schedules.length,
            itemBuilder: (context, index) {
              final schedule = _schedules[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(schedule['day_of_week']),
                  subtitle: Text(
                    '${schedule['start_time']} - ${schedule['end_time']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Implement delete schedule
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

  Widget _buildMessagesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return Align(
          alignment:
              message['sender_id'] == _doctor['id']
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  message['sender_id'] == _doctor['id']
                      ? Colors.blue[100]
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['message_text'],
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat(
                    'hh:mm a',
                  ).format(DateTime.parse(message['sent_at'])),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              child: Text(
                _doctor['full_name'].toString().substring(0, 1),
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileItem('Full Name', _doctor['full_name']),
          _buildProfileItem('Email', _doctor['email']),
          _buildProfileItem('Phone', _doctor['phone_number'] ?? 'Not provided'),
          _buildProfileItem(
            'Specialty',
            _doctor['specialty'] ?? 'Has no Specility',
          ),
          _buildProfileItem(
            'Hospital',
            _doctor['hospital'] ?? 'Has no Hospital',
          ),
          _buildProfileItem(
            'Experience',
            '${_doctor['experience_years']} years',
          ),
          _buildProfileItem(
            'Consultation Fee',
            '\$${_doctor['consultation_fee']}',
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
        ],
      ),
    );
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
                  items:
                      const [
                            'Monday',
                            'Tuesday',
                            'Wednesday',
                            'Thursday',
                            'Friday',
                            'Saturday',
                            'Sunday',
                          ]
                          .map(
                            (day) =>
                                DropdownMenuItem(value: day, child: Text(day)),
                          )
                          .toList(),
                  onChanged: (value) => dayController.text = value!,
                ),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Start Time'),
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
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: 'End Time'),
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
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }
}
