import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/components/doctorCard.dart';
import 'package:health/providers/dioProvider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../utils/config.dart';

class Symptoms extends StatefulWidget {
  final String symptomName;

  const Symptoms({super.key, required this.symptomName});

  @override
  State<Symptoms> createState() => _SymptomsState();
}

class _SymptomsState extends State<Symptoms> {
  List<dynamic> filteredDoctors = [];
  Map<String, dynamic> user = {};
  bool _isLoading = true;
  String? _errorMessage;

  Future<void> _fetchUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        setState(() {
          _errorMessage = "No token found. Please log in.";
          _isLoading = false;
        });
        return;
      }

      final response = await DioProvider().getUser(token);
      if (response == null) {
        setState(() {
          _errorMessage = "Failed to fetch user data.";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        user = json.decode(response);
        _filterDoctors();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An error occurred: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _filterDoctors() {
    if (user['doctor'] != null) {
      filteredDoctors =
          user['doctor']
              .where((doctor) => doctor['category'] == widget.symptomName)
              .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didUpdateWidget(covariant Symptoms oldWidget) {
    if (oldWidget.symptomName != widget.symptomName) {
      _filterDoctors();
    }
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildAdviceCard(String advice) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.medical_services, color: Colors.blue, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                advice,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceSection() {
    final adviceMap = {
      'Fever': [
        "Measure your temperature regularly",
        "Take Paracetamol as directed",
        "Stay hydrated with plenty of fluids",
        "Get adequate rest",
        "Use cool compresses if needed",
      ],
      'Dental': [
        "Rinse with warm salt water 2-3 times daily",
        "Avoid extremely hot or cold foods",
        "Use over-the-counter pain relievers",
        "Apply clove oil for temporary relief",
      ],
    };

    final adviceList =
        adviceMap[widget.symptomName] ??
        [
          "Consult a healthcare professional for proper guidance",
          "Follow your doctor's recommendations",
          "Monitor your symptoms closely",
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Text(
                "Managing ${widget.symptomName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Here are some recommendations to help you feel better:",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        ...adviceList.map((advice) => _buildAdviceCard(advice)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDoctorHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Available Doctors",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Chip(
            label: Text(
              "${filteredDoctors.length} found",
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorsList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchUserData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredDoctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medical_services_outlined,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                "No specialists available for ${widget.symptomName}",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                "Check back later or try another symptom",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildDoctorHeader(),
        ...filteredDoctors.map(
          (doctor) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DoctorCard(route: 'doctor', doctor: doctor),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Config().init(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        appTitle: widget.symptomName,
        icon: const Icon(Icons.arrow_back_ios),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement temperature action
            },
            icon: const Icon(Icons.thermostat, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdviceSection(),
              _buildDoctorsList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
