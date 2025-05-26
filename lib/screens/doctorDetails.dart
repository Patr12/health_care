import 'package:flutter/material.dart';
import '../components/customAppBar.dart';
import '../utils/config.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/utils/book_appointment_page.dart'; // Hakikisha hii ipo ikiwa unahitaji ku book appointment

class DoctorDetails extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetails({super.key, required this.doctor});

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

class _DoctorDetailsState extends State<DoctorDetails> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isFav = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _schedules = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadDoctorSchedules();
    }
  }

  Future<void> _loadDoctorSchedules() async {
    try {
      final schedules = await _dbHelper.getDoctorSchedules(widget.doctor['id']);
      if (mounted) {
        setState(() {
          _schedules = schedules;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error loading schedules: ${e.toString()}")),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final doctor = widget.doctor;

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Doctor Details",
        icon: const Icon(Icons.arrow_back),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Header
            Row(
              children: [
                _buildDoctorImage(doctor['image']),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dr. ${doctor['full_name']}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor['specialty'] ?? 'General Practitioner',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.medical_services, size: 16),
                          const SizedBox(width: 5),
                          Text(doctor['hospital'] ?? 'Clinic'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            "${doctor['rating'] ?? '5.0'} (${doctor['reviews'] ?? '0'} reviews)",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isFav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  onPressed: () => setState(() => _isFav = !_isFav),
                ),
              ],
            ),
            Config.spaceMedium,

            // About Doctor
            const Text(
              "About Doctor",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Config.spaceSmall,
            Text(
              doctor['bio'] ?? 'No information available',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Config.spaceMedium,

            // Schedule
            const Text(
              "Available Schedules",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Config.spaceSmall,
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _schedules.isEmpty
                ? const Text("No schedules available")
                : Column(
                  children:
                      _schedules
                          .map(
                            (schedule) => Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      schedule['day'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${schedule['start_time']} - ${schedule['end_time']}",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
            Config.spaceLarge,

            // Book Appointment Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Config.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  final booked = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookAppointmentPage(doctor: doctor),
                    ),
                  );
                  if (booked == true) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  "Book Appointment",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorImage(String? imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:
          imagePath != null && imagePath.isNotEmpty
              ? Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultDoctorIcon(),
              )
              : _buildDefaultDoctorIcon(),
    );
  }

  Widget _buildDefaultDoctorIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.person, size: 50, color: Colors.blue),
    );
  }
}
