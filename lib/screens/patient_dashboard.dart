import 'package:flutter/material.dart';
import 'package:health/components/appDrawer.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/screens/appointments.dart';
import 'package:health/screens/doctorDetails.dart';
import 'package:health/screens/messages.dart';
import 'package:health/screens/settings.dart';
import 'package:health/screens/symptomsPage.dart';
import 'package:health/screens/userDetails.dart';
import 'package:health/utils/config.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  int _currentPage = 0;
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> appointments = [];
  bool _isLoading = true;
  String _userName = "User";
  String _profilePictureUrl = '';
  String _searchQuery = '';
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await DatabaseHelper().getCurrentUser();
      final doctorsData = await DatabaseHelper().getDoctors();
      final appointmentsData = await DatabaseHelper().getUserAppointments(
        user['id'],
      );

      if (mounted) {
        setState(() {
          _userName = user['full_name'] ?? "User";
          _profilePictureUrl = user['image'] ?? '';
          doctors = doctorsData;
          appointments = appointmentsData;
          _isLoading = false;
          _userId = user['id'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading data: ${e.toString()}")),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    if (_searchQuery.isEmpty) return doctors;
    return doctors.where((doctor) {
      final name = doctor['full_name']?.toString().toLowerCase() ?? '';
      final specialty = doctor['specialty']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || specialty.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final bannerImages = [
      'assets/banner/1.jpg',
      'assets/banner/2.jpg',
      'assets/banner/3.jpg',
    ];

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Welcome, $_userName!",
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      drawer: AppDrawer(
        userName: _userName,
        profilePictureUrl: _profilePictureUrl,
        onProfilePressed: () {
          if (_userId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserDetails(userId: _userId!)),
            );
          }
        },

        onAppointmentPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Appointments(doctor: {})),
            ),
        onSymptomsPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SymptomsPage()),
            ),
        onNotificationsPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Messages()),
            ),
        onSettingsPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Settings()),
            ),
        onLogoutPressed: _logout,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search doctors...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged:
                            (value) => setState(() => _searchQuery = value),
                      ),
                    ),
                    // Banner Section
                    SizedBox(
                      height: 150,
                      child: PageView.builder(
                        itemCount: bannerImages.length,
                        onPageChanged:
                            (index) => setState(() => _currentPage = index),
                        itemBuilder:
                            (context, index) => Image.asset(
                              bannerImages[index],
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        bannerImages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _currentPage == index
                                    ? Colors.blue
                                    : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),

                    Config.spaceMedium,
                    // Upcoming Appointments
                    _buildAppointmentsSection(),

                    const SizedBox(height: 20),

                    // Available Doctors
                    _buildDoctorsSection(),
                  ],
                ),
              ),
    );
  }

  Widget _buildAppointmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Upcoming Appointments",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        appointments.isEmpty
            ? const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("You have no upcoming appointments"),
              ),
            )
            : SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dr. ${appointment['doctor_name'] ?? 'Unknown'}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text("Date: ${appointment['appointment_date']}"),
                          Text("Time: ${appointment['appointment_time']}"),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                appointment['status'],
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              appointment['status'] ?? 'Pending',
                              style: TextStyle(
                                color: _getStatusColor(appointment['status']),
                              ),
                            ),
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

  Widget _buildDoctorsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Doctors",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _filteredDoctors.isEmpty
              ? const Center(child: Text("No doctors found"))
              : Expanded(
                child: ListView.builder(
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _filteredDoctors[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: _buildDoctorImage(doctor['image']),
                        title: Text(
                          "Dr. ${doctor['full_name'] ?? 'Unknown'}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor['specialty'] ?? 'General Practitioner'),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.medical_services, size: 16),
                                const SizedBox(width: 4),
                                Text(doctor['hospital'] ?? 'Clinic'),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${doctor['rating'] ?? '5.0'} (${doctor['experience_years'] ?? '0'} yrs exp)",
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DoctorDetails(doctor: doctor),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDoctorImage(String? imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 50,
        height: 50,
        color: Colors.grey[200],
        child:
            imagePath != null && imagePath.isNotEmpty
                ? Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildDefaultDoctorIcon(),
                )
                : _buildDefaultDoctorIcon(),
      ),
    );
  }

  Widget _buildDefaultDoctorIcon() {
    return const Center(
      child: Icon(Icons.person, size: 30, color: Colors.grey),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Future<void> _logout() async {
    // Implement your logout logic here
    Navigator.pushReplacementNamed(context, '/login');
  }
}
