import 'package:flutter/material.dart';
import 'package:health/components/appDrawer.dart';
import 'package:health/components/customAppBar.dart';

import 'package:health/data/database_helper.dart';
import 'package:health/screens/appointments.dart';
import 'package:health/screens/messages.dart';
import 'package:health/screens/settings.dart';
import 'package:health/screens/symptomsPage.dart';
import 'package:health/screens/userDetails.dart';
import 'package:health/utils/config.dart';

class NewHomePage extends StatefulWidget {
  const NewHomePage({super.key});

  @override
  State<NewHomePage> createState() => _NewHomePageState();
}

class _NewHomePageState extends State<NewHomePage> {
  int _currentPage = 0;
  List<Map<String, dynamic>> doctors = [];

  List<Map<String, dynamic>> appointments = [
    {
      'doctorName': 'Jane Smith',
      'date': '2025-05-10',
      'time': '10:00 AM',
    },
    {
      'doctorName': 'John Doe',
      'date': '2025-05-12',
      'time': '2:00 PM',
    },
  ];

  List<Map<String, dynamic>> medCat = [
    {"imageAsset": 'assets/symptoms/fever.png', "category": "  Fever  "},
    {"imageAsset": 'assets/symptoms/dental.png', "category": "  Dental  "},
    {"imageAsset": 'assets/symptoms/eyecare.png', "category": "Eye Care"},
    {"imageAsset": 'assets/symptoms/stress.png', "category": "  Stress  "},
    {"imageAsset": 'assets/symptoms/cardiology.png', "category": "Cardiology"},
    {"imageAsset": 'assets/symptoms/dermatology.png', "category": "Dermatology"},
    {"imageAsset": 'assets/symptoms/respirations.png', "category": "Respirations"},
    {"imageAsset": 'assets/symptoms/cholesterol.png', "category": "Cholesterol"},
    {"imageAsset": 'assets/symptoms/diabetes.png', "category": "Diabetes"},
    {"imageAsset": 'assets/symptoms/virus.png', "category": "Virus"},
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    final data = await DatabaseHelper().getDoctors();
    setState(() {
      doctors = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannerImages = ['assets/banner/1.jpg', 'assets/banner/2.jpg', 'assets/banner/3.jpg'];
    Config().init(context);

    return Scaffold(
      appBar: const CustomAppBar(appTitle: "WELCOME USER!", actions: []),
      drawer: AppDrawer(
        userName: "User",
        profilePictureUrl: '',
        onProfilePressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserDetails())),
        onAppointmentPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Appointments(doctor: {}))),
        onSymptomsPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomsPage())),
        onNotificationsPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Messages())),
        onSettingsPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Settings())),
        onLogoutPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Section
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    itemCount: bannerImages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) => Image.asset(bannerImages[index], fit: BoxFit.cover),
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
                        color: _currentPage == index ? Colors.blue : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                Config.spaceMedium,

                // Appointments Section
                const Text("Your Appointments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return Card(
                        margin: const EdgeInsets.only(right: 10),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dr. ${appointment['doctorName']}"),
                              Text("Date: ${appointment['date']}"),
                              Text("Time: ${appointment['time']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Config.spaceMedium,

                // Symptoms Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Choose Your Symptoms", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomsPage())),
                      child: const Text("View All", style: TextStyle(fontSize: 16, color: Colors.blue)),
                    ),
                  ],
                ),
                Config.spaceSmall,
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: List.generate(
                      medCat.length,
                      (index) => Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(medCat[index]['imageAsset']!, width: 80, height: 80),
                              const SizedBox(height: 8),
                              Text(medCat[index]['category']!, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Config.spaceMedium,

                // Doctors Section
                const Text("Choose Your Doctor", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Config.spaceSmall,
                doctors.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: doctors.map((doc) {
                          final String name = doc['name'] ?? 'Unknown';
                          final String specialty = doc['specialty'] ?? 'General';
                          final String? imagePath = doc['image'];
                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: imagePath != null && imagePath.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        imagePath,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.person, size: 50),
                                      ),
                                    )
                                  : const Icon(Icons.person, size: 50),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(specialty),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // Handle doctor tap
                              },
                            ),
                          );
                        }).toList(),
                      ),

                Config.spaceMedium,

                // Social Media Section
                const Text("Connect with Us", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.email, color: Colors.red),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.purple),
                      onPressed: () {},
                    ),
                  ],
                ),

                Config.spaceMedium,

                // Book Appointment Button
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // Add appointment logic here
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Book Appointment"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
