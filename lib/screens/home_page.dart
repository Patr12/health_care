import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';
import 'package:health/screens/doctorDetails.dart';
import 'package:health/utils/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _doctors = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final doctors = await _dbHelper.getDoctors();
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading doctors: ${e.toString()}")),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    if (_searchQuery.isEmpty) return _doctors;
    return _doctors.where((doctor) {
      final name = doctor['name']?.toString().toLowerCase() ?? '';
      final specialty = doctor['specialty']?.toString().toLowerCase() ?? '';
      final hospital = doctor['hospital']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || 
             specialty.contains(query) || 
             hospital.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDoctors,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search doctors...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Doctors List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? const Center(child: Text('No doctors found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          return _buildDoctorCard(doctor);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDoctorDetails(doctor),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Doctor Image
              _buildDoctorImage(doctor['image']),
              const SizedBox(width: 16),
              
              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Dr. ${doctor['name'] ?? 'Unknown'}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor['specialty'] ?? 'General Practitioner',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.medical_services, size: 16),
                        const SizedBox(width: 4),
                        Text(doctor['hospital'] ?? 'Clinic'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text("${doctor['rating'] ?? '5.0'} (${doctor['experience_years'] ?? '0'} yrs exp)"),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Book Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Config.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _navigateToDoctorDetails(doctor),
                child: const Text('Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorImage(String? imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child: imagePath != null && imagePath.isNotEmpty
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
      child: Icon(Icons.person, size: 40, color: Colors.grey),
    );
  }

  void _navigateToDoctorDetails(Map<String, dynamic> doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetails(doctor: doctor),
      ),
    );
  }
}