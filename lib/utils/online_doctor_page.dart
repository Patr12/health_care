import 'package:flutter/material.dart';
import 'package:health/data/database_helper.dart';

class OnlineDoctorPage extends StatefulWidget {
  const OnlineDoctorPage({super.key});

  @override
  State<OnlineDoctorPage> createState() => _OnlineDoctorPageState();
}

class _OnlineDoctorPageState extends State<OnlineDoctorPage> {
  String? _selectedDoctorId;
  String _communicationType = 'video';
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daktari Mtandaoni')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pata huduma za daktari kupitia video call au ujumbe',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // Communication type selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chagua njia ya mawasiliano:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Video Call'),
                              value: 'video',
                              groupValue: _communicationType,
                              onChanged: (value) {
                                setState(() {
                                  _communicationType = value!;
                                  _selectedDoctorId = null;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('SMS'),
                              value: 'sms',
                              groupValue: _communicationType,
                              onChanged: (value) {
                                setState(() {
                                  _communicationType = value!;
                                  _selectedDoctorId = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Doctor selection dropdown
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseHelper().getAvailableDoctors(
                  _communicationType,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Hitilafu: ${snapshot.error}');
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _communicationType == 'video'
                              ? 'Hakuna madaktari wanaopokea simu za video kwa sasa'
                              : 'Hakuna madaktari wanaopokea ujumbe kwa sasa',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final doctors = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chagua Daktari:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            menuMaxHeight: 200,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 24.0,
                              ),
                            ),
                            hint: const Text('Chagua daktari...'),
                            value: _selectedDoctorId,
                            items:
                                doctors.map((doctor) {
                                  return DropdownMenuItem<String>(
                                    value: doctor['id'].toString(),
                                    child: ConstrainedBox(
                                      // <-- Constrain dropdown item height
                                      constraints: BoxConstraints(
                                        maxHeight: 100,
                                      ), // Adjust as needed
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${doctor['full_name']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${doctor['specialty']} - ${doctor['hospital']}',
                                          ),
                                          Text(
                                            'Miaka ${doctor['experience_years']} ya uzoefu',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDoctorId = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              if (_communicationType == 'sms') ...[
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Andika Ujumbe:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Andika ujumbe wako kwa daktari...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed:
                        _selectedDoctorId == null
                            ? null
                            : _initiateCommunication,
                    child: Text(
                      _communicationType == 'video'
                          ? 'ANZA SIMU YA VIDEO'
                          : 'TUMa UJUMBE',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initiateCommunication() async {
    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getCurrentUser();

      if (user['phone_number'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tafadhali thibitisha namba yako ya simu kwanza'),
          ),
        );
        return;
      }

      if (_communicationType == 'video') {
        await _startVideoCall();
      } else {
        await _sendSms();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hitilafu: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startVideoCall() async {
    // Get doctor's phone number
    final doctorPhone = await DatabaseHelper().getDoctorPhoneNumber(
      int.parse(_selectedDoctorId!),
    );

    if (doctorPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daktari hana namba ya simu iliyosajiliwa'),
        ),
      );
      return;
    }

    // TODO: Implement actual video call functionality
    // You would typically use a package like agora_rtc_engine or connect to your video API

    // For now, show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Inaanza simu ya video na daktari #$_selectedDoctorId'),
      ),
    );

    // You might want to navigate to a video call screen
    // Navigator.push(context, MaterialPageRoute(
    //   builder: (context) => VideoCallScreen(doctorId: _selectedDoctorId!),
    // ));
  }

  Future<void> _sendSms() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tafadhali andika ujumbe')));
      return;
    }

    // Get doctor's phone number
    final doctorPhone = await DatabaseHelper().getDoctorPhoneNumber(
      int.parse(_selectedDoctorId!),
    );

    if (doctorPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daktari hana namba ya simu iliyosajiliwa'),
        ),
      );
      return;
    }

    // TODO: Implement actual SMS sending
    // You would typically use a package like flutter_sms or connect to an SMS gateway API

    // For now, show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ujumbe umetumwa kwa daktari #$_selectedDoctorId'),
      ),
    );

    // Clear the message field
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
