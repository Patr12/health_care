import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClinicRegistrationPage extends StatefulWidget {
  const ClinicRegistrationPage({super.key});

  @override
  State<ClinicRegistrationPage> createState() => _ClinicRegistrationPageState();
}

class _ClinicRegistrationPageState extends State<ClinicRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _insuranceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedClinic;
  bool _isSubmitting = false;

  // Sample clinics data - in practice you would fetch this from your database
  final List<Map<String, dynamic>> _clinics = [
    {'id': '1', 'name': 'Aga Khan Hospital', 'location': 'Dar es Salaam'},
    {'id': '2', 'name': 'Muhimbili National Hospital', 'location': 'Upanga'},
    {'id': '3', 'name': 'Kairuki Hospital', 'location': 'Mikocheni'},
    {'id': '4', 'name': 'TMJ Hospital', 'location': 'Mbezi'},
    {'id': '5', 'name': 'Mwananyamala Hospital', 'location': 'Kinondoni'},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null; // Reset time when date changes
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tafadhali chagua tarehe kwanza')),
      );
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClinic == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tafadhali chagua kliniki')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tafadhali chagua tarehe')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Here you would typically send data to your backend/database
      // For example:
      // await ClinicService.register(
      //   name: _nameController.text,
      //   phone: _phoneController.text,
      //   email: _emailController.text,
      //   location: _locationController.text,
      //   clinicId: _selectedClinic!,
      //   appointmentDate: _selectedDate!,
      //   appointmentTime: _selectedTime!,
      //   insurance: _insuranceController.text,
      // );

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Umefanikiwa kujiandikisha!'),
          action: SnackBarAction(label: 'Sawa', onPressed: () {}),
        ),
      );

      // Clear form after successful submission
      _formKey.currentState!.reset();
      setState(() {
        _selectedClinic = null;
        _selectedDate = null;
        _selectedTime = null;
        _isSubmitting = false;
      });

      // Navigate to confirmation page or back
      // Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hitilafu: ${e.toString()}')));
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _insuranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kujiandikisha Kliniki'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.medical_services,
                        size: 50,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Jaza fomu hii kujiandikisha kwenye kliniki',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  menuMaxHeight: 290,
                  decoration: const InputDecoration(
                    labelText: 'Chagua Kliniki',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  value: _selectedClinic,
                  items:
                      _clinics.map<DropdownMenuItem<String>>((clinic) {
                        return DropdownMenuItem<String>(
                          value: clinic['id'].toString(),
                          child: Text(
                            '${clinic['name']} - ${clinic['location']}',
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedClinic = value;
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Tafadhali chagua kliniki' : null,
                ),
              ),
              const SizedBox(height: 20),

              // Personal Information Section
              const Text(
                'Taarifa Binafsi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Jina Kamili',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Tafadhali ingiza jina lako' : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Namba ya Simu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Tafadhali ingiza namba ya simu'
                            : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Barua Pepe (Si lazima)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Mahali unapoishi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Tafadhali ingiza mahali unapoishi'
                            : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _insuranceController,
                decoration: const InputDecoration(
                  labelText: 'Namba ya Bima (Kama uko na bima)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.health_and_safety),
                ),
              ),
              const SizedBox(height: 20),

              // Appointment Section
              const Text(
                'Muda wa Kukutana:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),

              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tarehe unayopendelea',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Chagua tarehe'
                            : DateFormat(
                              'EEEE, d MMMM y',
                            ).format(_selectedDate!),
                      ),
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _selectedDate = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Time Picker
              InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Muda unayopendelea',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? 'Chagua muda'
                            : _selectedTime!.format(context),
                      ),
                      if (_selectedTime != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _selectedTime = null),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Wasilisha Maombi',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
