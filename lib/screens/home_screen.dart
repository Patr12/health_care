import 'package:flutter/material.dart';
import 'package:health/chart/message_chat_page.dart';
import 'package:health/screens/appointments.dart';
import 'package:health/screens/loginPage.dart';
import 'package:health/screens/patient_dashboard.dart';
import 'package:health/screens/symptomsPage.dart';
import 'package:health/utils/clinic_page.dart';
import 'package:health/utils/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/data/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int? loggedInUserId;
  Map<String, dynamic>? currentUser;
  bool _isLoading = true;
  String userName = 'Guest'; // Added for drawer display
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    _loadUserName(); // Load user name for drawer
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'Guest';
    });
  }

  Future<void> _initializeUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId != null) {
        final user = await _dbHelper.getUserById(userId);
        setState(() {
          loggedInUserId = userId;
          currentUser = user;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing user data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('userName'); // Remove stored name
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginForm()),
    );
  }

  List<Widget> get _pages {
    if (_isLoading) {
      return List.filled(4, const Center(child: CircularProgressIndicator()));
    }

    return [
      const PatientDashboard(),
      const ClinicPage(),
      const SymptomsPage(),
      if (loggedInUserId != null)
        ProfilePage(userId: loggedInUserId!, onLogout: _logout)
      else
        _buildLoginRequiredView(),
    ];
  }

  Widget _buildLoginRequiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Profile Not Available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Please login to access your profile'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginForm()),
              );
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    if (index == 3 && loggedInUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to access profile'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> get _navItems => [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Clinic'),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Welcom $userName")),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: _navItems,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text(
              loggedInUserId != null ? 'Patient' : 'Guest',
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'G',
                style: TextStyle(fontSize: 24),
              ),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              setState(() => _selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.local_hospital),
            title: Text('Clinic'),
            onTap: () {
              setState(() => _selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              setState(() => _selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SymptomsPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Appointments'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Appointments(doctor: {}),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Message'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => const MessageChatPage(
                        currentUserId: '',
                        currentUserName: '',
                      ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              if (loggedInUserId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please login to access profile')),
                );
                Navigator.pop(context);
                return;
              }
              setState(() => _selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
}
