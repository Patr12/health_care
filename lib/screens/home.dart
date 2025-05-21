// import 'package:flutter/material.dart';
// import 'package:health/components/appDrawer.dart';
// import 'package:health/components/customAppBar.dart';
// import 'package:health/data/database_helper.dart';
// import 'package:health/screens/appointments.dart';
// import 'package:health/screens/doctorDetails.dart';
// import 'package:health/screens/messages.dart';
// import 'package:health/screens/settings.dart';
// import 'package:health/screens/symptomsPage.dart';
// import 'package:health/screens/userDetails.dart';
// import 'package:health/utils/config.dart';

// class PatientDashboard extends StatefulWidget {
//   const PatientDashboard({super.key});

//   @override
//   State<PatientDashboard> createState() => _PatientDashboardState();
// }

// class _PatientDashboardState extends State<PatientDashboard> {
//   int _currentPage = 0;
//   List<Map<String, dynamic>> doctors = [];
//   List<Map<String, dynamic>> appointments = [];
//   bool _isLoading = true;
//   String _userName = "User";
//   String _profilePictureUrl = '';

//   final List<Map<String, dynamic>> medCat = [
//     {"imageAsset": 'assets/symptoms/fever.png', "category": "Fever"},
//     {"imageAsset": 'assets/symptoms/dental.png', "category": "Dental"},
//     {"imageAsset": 'assets/symptoms/eyecare.png', "category": "Eye Care"},
//     {"imageAsset": 'assets/symptoms/stress.png', "category": "Stress"},
//     {"imageAsset": 'assets/symptoms/cardiology.png', "category": "Cardiology"},
//     {
//       "imageAsset": 'assets/symptoms/dermatology.png',
//       "category": "Dermatology",
//     },
//     {
//       "imageAsset": 'assets/symptoms/respirations.png',
//       "category": "Respirations",
//     },
//     {
//       "imageAsset": 'assets/symptoms/cholesterol.png',
//       "category": "Cholesterol",
//     },
//     {"imageAsset": 'assets/symptoms/diabetes.png', "category": "Diabetes"},
//     {"imageAsset": 'assets/symptoms/virus.png', "category": "Virus"},
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     try {
//       // Get current user data
//       final user = await DatabaseHelper().getCurrentUser();

//       // Fetch doctors and appointments
//       final doctorsData = await DatabaseHelper().getDoctors();
//       final appointmentsData = await DatabaseHelper().getUserAppointments(
//         user['id'],
//       );

//       setState(() {
//         _userName = user['full_name'] ?? "User";
//         _profilePictureUrl = user['image'] ?? '';
//         doctors = doctorsData;
//         appointments = appointmentsData;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error loading data: ${e.toString()}")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bannerImages = [
//       'assets/banner/1.jpg',
//       'assets/banner/2.jpg',
//       'assets/banner/3.jpg',
//     ];
//     Config().init(context);

//     return Scaffold(
//       appBar: CustomAppBar(appTitle: "WELCOME $_userName!", actions: []),
//       drawer: AppDrawer(
//         userName: _userName,
//         profilePictureUrl: _profilePictureUrl,
//         onProfilePressed:
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const UserDetails()),
//             ),
//         onAppointmentPressed:
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => Appointments(doctor: {})),
//             ),
//         onSymptomsPressed:
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => SymptomsPage()),
//             ),
//         onNotificationsPressed:
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => Messages()),
//             ),
//         onSettingsPressed:
//             () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => Settings()),
//             ),
//         onLogoutPressed: _logout,
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 15,
//                   vertical: 15,
//                 ),
//                 child: SafeArea(
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Banner Section
//                         SizedBox(
//                           height: 150,
//                           child: PageView.builder(
//                             itemCount: bannerImages.length,
//                             onPageChanged:
//                                 (index) => setState(() => _currentPage = index),
//                             itemBuilder:
//                                 (context, index) => Image.asset(
//                                   bannerImages[index],
//                                   fit: BoxFit.cover,
//                                 ),
//                           ),
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: List.generate(
//                             bannerImages.length,
//                             (index) => Container(
//                               margin: const EdgeInsets.symmetric(horizontal: 5),
//                               width: 10,
//                               height: 10,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color:
//                                     _currentPage == index
//                                         ? Colors.blue
//                                         : Colors.grey.withOpacity(0.5),
//                               ),
//                             ),
//                           ),
//                         ),

//                         Config.spaceMedium,

//                         // Appointments Section
//                         const Text(
//                           "Your Appointments",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         appointments.isEmpty
//                             ? const Padding(
//                               padding: EdgeInsets.symmetric(vertical: 20),
//                               child: Center(
//                                 child: Text("No upcoming appointments"),
//                               ),
//                             )
//                             : SizedBox(
//                               height: 110,
//                               child: ListView.builder(
//                                 scrollDirection: Axis.horizontal,
//                                 itemCount: appointments.length,
//                                 itemBuilder: (context, index) {
//                                   final appointment = appointments[index];
//                                   return Card(
//                                     margin: const EdgeInsets.only(right: 10),
//                                     elevation: 4,
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(10),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Dr. ${appointment['doctor_name'] ?? 'Unknown'}",
//                                             style: const TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           Text(
//                                             "Date: ${appointment['appointment_date']}",
//                                           ),
//                                           Text(
//                                             "Time: ${appointment['appointment_time']}",
//                                           ),
//                                           Text(
//                                             "Status: ${appointment['status']}",
//                                             style: TextStyle(
//                                               color: _getStatusColor(
//                                                 appointment['status'],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),

//                         Config.spaceMedium,

//                         // Symptoms Section
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               "Choose Your Symptoms",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             TextButton(
//                               onPressed:
//                                   () => Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder:
//                                           (_) => const SymptomsPage(
//                                             selectedCategory: null,
//                                           ),
//                                     ),
//                                   ),
//                               child: const Text(
//                                 "View All",
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Config.spaceSmall,
//                         SizedBox(
//                           height: 180,
//                           child: ListView(
//                             scrollDirection: Axis.horizontal,
//                             children: List.generate(
//                               medCat.length,
//                               (index) => Card(
//                                 elevation: 5,
//                                 child: InkWell(
//                                   onTap: () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder:
//                                             (_) => SymptomsPage(
//                                               selectedCategory:
//                                                   medCat[index]['category'],
//                                             ),
//                                       ),
//                                     );
//                                   },
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 20,
//                                       vertical: 10,
//                                     ),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Image.asset(
//                                           medCat[index]['imageAsset']!,
//                                           width: 80,
//                                           height: 80,
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           medCat[index]['category']!,
//                                           style: const TextStyle(fontSize: 16),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         Config.spaceMedium,

//                         // Doctors Section
//                         const Text(
//                           "Available Doctors",
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Config.spaceSmall,
//                         // In your PatientDashboard, modify the doctors list item builder:
//                         Column(
//                           children:
//                               doctors.map((doc) {
//                                 return Card(
//                                   elevation: 4,
//                                   margin: const EdgeInsets.symmetric(
//                                     vertical: 10,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   child: ListTile(
//                                     leading: _buildDoctorImage(doc['image']),
//                                     title: Text(
//                                       doc['name'] ?? 'Unknown',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     subtitle: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(doc['specialty'] ?? 'General'),
//                                         Text(
//                                           '${doc['hospital'] ?? 'Clinic'} • ${doc['experience_years'] ?? '0'} yrs exp',
//                                           style: const TextStyle(fontSize: 12),
//                                         ),
//                                       ],
//                                     ),
//                                     trailing: const Icon(
//                                       Icons.arrow_forward_ios,
//                                     ),
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder:
//                                               (_) => DoctorDetails(doctor: doc),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               }).toList(),
//                         ),

//                         Config.spaceMedium,

//                         // Book Appointment Button
//                         Center(
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.green,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 24,
//                                 vertical: 12,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => Appointments(doctor: {}),
//                                 ),
//                               );
//                             },
//                             icon: const Icon(Icons.add),
//                             label: const Text("Book New Appointment"),
//                           ),
//                         ),
//                         Config.spaceMedium,
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//     );
//   }

//   Widget _buildDoctorImage(String? imagePath) {
//     if (imagePath != null && imagePath.isNotEmpty) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Image.asset(
//           imagePath,
//           width: 50,
//           height: 50,
//           fit: BoxFit.cover,
//           errorBuilder:
//               (context, error, stackTrace) => _buildDefaultDoctorIcon(),
//         ),
//       );
//     }
//     return _buildDefaultDoctorIcon();
//   }

//   Widget _buildDefaultDoctorIcon() {
//     return Container(
//       width: 50,
//       height: 50,
//       decoration: BoxDecoration(
//         color: Colors.blue[100],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Icon(Icons.person, size: 30, color: Colors.blue),
//     );
//   }

//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
//       case 'confirmed':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Future<void> _logout() async {
//     // Implement your logout logic here
//     Navigator.pushReplacementNamed(context, '/login');
//   }
// }
