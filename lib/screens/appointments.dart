import 'package:flutter/material.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/utils/config.dart';
import 'package:intl/intl.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key, required this.doctor});

  final Map<String, dynamic> doctor;

  @override
  State<Appointments> createState() => _AppointmentsState();
}

enum FilterStatus { Upcoming, Completed, Canceled }

class _AppointmentsState extends State<Appointments> {
  FilterStatus status = FilterStatus.Upcoming;
  Alignment _alignment = Alignment.centerLeft;
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final user = await _dbHelper.getCurrentUser();
      final data = await _dbHelper.getUserAppointments(user['id']);
      setState(() {
        appointments = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading appointments: ${e.toString()}")),
      );
    }
  }

  Future<void> _updateAppointmentStatus(int id, String status) async {
    try {
      await _dbHelper.updateAppointmentStatus(id, status);
      await _loadAppointments(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating appointment: ${e.toString()}")),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    return appointments.where((appointment) {
      switch (status) {
        case FilterStatus.Upcoming:
          return appointment['status'] == 'pending';
        case FilterStatus.Completed:
          return appointment['status'] == 'completed';
        case FilterStatus.Canceled:
          return appointment['status'] == 'canceled';
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Your Appointments",
        icon: const Icon(Icons.arrow_back),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status filter tabs
            _buildStatusFilter(),
            Config.spaceMedium,

            // Appointments list
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredAppointments.isEmpty
                      ? const Center(child: Text("No appointments found"))
                      : ListView.builder(
                        itemCount: _filteredAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _filteredAppointments[index];
                          return _buildAppointmentCard(appointment);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (FilterStatus filterStatus in FilterStatus.values)
                Expanded(
                  child: GestureDetector(
                    onTap:
                        () => setState(() {
                          status = filterStatus;
                          _alignment =
                              filterStatus == FilterStatus.Upcoming
                                  ? Alignment.centerLeft
                                  : filterStatus == FilterStatus.Completed
                                  ? Alignment.center
                                  : Alignment.centerRight;
                        }),
                    child: Center(
                      child: Text(
                        filterStatus.name,
                        style: TextStyle(
                          fontWeight:
                              status == filterStatus
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        AnimatedAlign(
          alignment: _alignment,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Config.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                status.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final date = DateFormat(
      'yyyy-MM-dd',
    ).parse(appointment['appointment_date']);
    final time = appointment['appointment_time'];

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info
            Row(
              children: [
                CircleAvatar(
                  backgroundImage:
                      appointment['image'] != null
                          ? AssetImage(appointment['image'])
                          : const AssetImage('assets/doctor.jpg'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr. ${appointment['full_name']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      appointment['specialty'] ?? 'General Practitioner',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Appointment time
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 5),
                      Text(DateFormat('EEEE, MMM d').format(date)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 5),
                      Text(time),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Appointment reason
            if (appointment['reason'] != null &&
                appointment['reason'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reason:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(appointment['reason']),
                  const SizedBox(height: 10),
                ],
              ),

            // Action buttons
            if (status == FilterStatus.Upcoming)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed:
                          () => _updateAppointmentStatus(
                            appointment['id'],
                            'completed',
                          ),
                      child: const Text('Mark Completed'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed:
                          () => _updateAppointmentStatus(
                            appointment['id'],
                            'canceled',
                          ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
