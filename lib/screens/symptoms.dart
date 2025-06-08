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
  // Constants for advice and colors
 static const Map<String, List<String>> SYMPTOM_ADVICE = {
  'Fever': [
    "Measure your temperature regularly",
    "Take Paracetamol as directed",
    "Stay hydrated with plenty of fluids",
    "Get adequate rest",
    "Use cool compresses if needed",
    "Seek medical help if fever exceeds 39°C or lasts more than 3 days"
  ],
  'Dental': [
    "Rinse with warm salt water 2-3 times daily",
    "Avoid extremely hot or cold foods",
    "Use over-the-counter pain relievers",
    "Apply clove oil for temporary relief",
    "See a dentist if pain persists more than 2 days"
  ],
  'Eye Care': [
    "Rest your eyes every 20 minutes (20-20-20 rule)",
    "Use lubricating eye drops",
    "Wear sunglasses in bright sunlight",
    "Avoid rubbing your eyes",
    "Consult an ophthalmologist for persistent redness or pain"
  ],
  'Stress': [
    "Practice deep breathing exercises",
    "Get regular physical activity",
    "Maintain a consistent sleep schedule",
    "Limit caffeine and alcohol intake",
    "Consider meditation or yoga"
  ],
  'Cardiology': [
    "Monitor your blood pressure regularly",
    "Reduce sodium intake",
    "Exercise for at least 30 minutes daily",
    "Avoid smoking and secondhand smoke",
    "Seek immediate help for chest pain or shortness of breath"
  ],
  'Dermatology': [
    "Keep the affected area clean and dry",
    "Use hypoallergenic moisturizers",
    "Avoid scratching irritated skin",
    "Wear loose, breathable clothing",
    "Consult a dermatologist for persistent rashes"
  ],
  'Respirations': [
    "Stay hydrated to thin mucus",
    "Use a humidifier to moisten air",
    "Practice steam inhalation",
    "Avoid smoking and polluted air",
    "Seek help for difficulty breathing or wheezing"
  ],
  'Cholesterol': [
    "Eat more fruits, vegetables and whole grains",
    "Choose lean protein sources",
    "Limit saturated and trans fats",
    "Increase physical activity",
    "Get regular cholesterol screenings"
  ],
  'Diabetes': [
    "Monitor blood sugar levels regularly",
    "Follow a balanced meal plan",
    "Inspect feet daily for cuts or blisters",
    "Stay physically active",
    "Never skip medications without consulting your doctor"
  ],
  'Virus': [
    "Get plenty of rest",
    "Drink fluids to stay hydrated",
    "Use over-the-counter remedies for symptoms",
    "Practice good hygiene to prevent spread",
    "Isolate yourself to protect others"
  ],
  'Headache': [
    "Rest in a quiet, dark room",
    "Apply a cold compress to forehead",
    "Massage neck and shoulder muscles",
    "Stay hydrated and avoid skipping meals",
    "Seek medical attention for severe or persistent headaches"
  ],
  'Stomach Ache': [
    "Drink clear fluids in small amounts",
    "Avoid solid foods initially",
    "Use a heating pad for comfort",
    "Try peppermint or ginger tea",
    "See a doctor if pain is severe or lasts more than 48 hours"
  ],
  'Back Pain': [
    "Maintain good posture",
    "Apply ice or heat to affected area",
    "Do gentle stretching exercises",
    "Avoid heavy lifting",
    "Consider physical therapy for chronic pain"
  ],
  'Allergies': [
    "Identify and avoid triggers",
    "Use antihistamines as directed",
    "Keep windows closed during high pollen seasons",
    "Shower after being outdoors",
    "Consider allergy testing for persistent symptoms"
  ],
  'Arthritis': [
    "Maintain a healthy weight",
    "Do low-impact exercises regularly",
    "Use assistive devices if needed",
    "Apply warm compresses to stiff joints",
    "Follow prescribed treatment plans"
  ],
  'Hypertension': [
    "Reduce salt in your diet",
    "Monitor blood pressure at home",
    "Limit alcohol consumption",
    "Manage stress through relaxation techniques",
    "Take medications as prescribed"
  ],
  'Insomnia': [
    "Maintain a regular sleep schedule",
    "Create a relaxing bedtime routine",
    "Avoid screens before bedtime",
    "Limit caffeine in the afternoon",
    "Make your bedroom quiet and comfortable"
  ],
  'Common Cold': [
    "Get plenty of rest",
    "Drink warm liquids to soothe throat",
    "Use saline nasal drops",
    "Gargle with warm salt water",
    "Take over-the-counter cold medicines as needed"
  ],
  'Anxiety': [
    "Practice deep breathing exercises",
    "Limit caffeine and alcohol",
    "Get regular physical activity",
    "Try mindfulness meditation",
    "Seek professional help if symptoms persist"
  ],
  'Asthma': [
    "Identify and avoid triggers",
    "Use inhalers as prescribed",
    "Monitor your breathing regularly",
    "Create an asthma action plan",
    "Seek emergency care for severe attacks"
  ],
  'Depression': [
    "Maintain a regular routine",
    "Stay connected with loved ones",
    "Get regular exercise",
    "Eat a balanced diet",
    "Seek professional help when needed"
  ],
  'Migraine': [
    "Identify and avoid triggers",
    "Rest in a dark, quiet room",
    "Apply cold packs to head or neck",
    "Stay hydrated",
    "Keep a headache diary to track patterns"
  ],
  'Heartburn': [
    "Eat smaller, more frequent meals",
    "Avoid lying down after eating",
    "Elevate the head of your bed",
    "Identify and avoid trigger foods",
    "Use antacids as needed"
  ],
  'Flu': [
    "Get plenty of rest",
    "Stay hydrated with water and clear broths",
    "Use over-the-counter pain relievers",
    "Stay home to avoid spreading germs",
    "Consider antiviral medications if caught early"
  ],
  'UTI': [
    "Drink plenty of water",
    "Empty bladder frequently",
    "Avoid irritating feminine products",
    "Use heating pad for discomfort",
    "See a doctor for proper antibiotics"
  ],
  'Constipation': [
    "Increase fiber intake gradually",
    "Drink plenty of fluids",
    "Exercise regularly",
    "Establish regular bathroom habits",
    "Consider fiber supplements if needed"
  ],
  'Diarrhea': [
    "Stay hydrated with oral rehydration solutions",
    "Avoid dairy, fatty foods, and high-fiber foods",
    "Eat bland foods like bananas, rice, applesauce, toast",
    "Wash hands frequently to prevent spread",
    "See a doctor if it lasts more than 2 days"
  ],
  'Pneumonia': [
    "Get plenty of rest",
    "Stay hydrated to loosen mucus",
    "Take prescribed antibiotics fully",
    "Use a humidifier to ease breathing",
    "Seek emergency care for difficulty breathing"
  ],
  'Malaria': [
    "Take antimalarial drugs as prescribed",
    "Stay hydrated",
    "Use mosquito nets to prevent reinfection",
    "Monitor for high fever",
    "Seek immediate medical attention for severe symptoms"
  ],
  'Typhoid': [
    "Complete course of antibiotics",
    "Practice good hand hygiene",
    "Drink only boiled or bottled water",
    "Eat well-cooked foods",
    "Get vaccinated if traveling to endemic areas"
  ],
  'Cholera': [
    "Use oral rehydration solutions frequently",
    "Take prescribed antibiotics",
    "Practice strict hand hygiene",
    "Drink only treated or boiled water",
    "Seek immediate medical care for severe dehydration"
  ],
  'Hepatitis': [
    "Get plenty of rest",
    "Avoid alcohol completely",
    "Eat small, frequent meals",
    "Stay hydrated",
    "Follow up with liver function tests"
  ],
  'HIV/AIDS': [
    "Take antiretroviral therapy consistently",
    "Practice safe sex",
    "Eat a nutritious diet",
    "Get regular medical checkups",
    "Join support groups for emotional health"
  ],
  'Tuberculosis': [
    "Complete full course of medications",
    "Cover mouth when coughing",
    "Get plenty of rest and good nutrition",
    "Attend all follow-up appointments",
    "Isolate as directed to prevent spread"
  ],
  'Cancer': [
    "Follow treatment plan carefully",
    "Manage side effects with your healthcare team",
    "Maintain good nutrition",
    "Seek emotional support",
    "Attend all follow-up screenings"
  ],
  'Epilepsy': [
    "Take medications as prescribed",
    "Get adequate sleep",
    "Avoid known seizure triggers",
    "Wear medical alert identification",
    "Have a seizure response plan"
  ],
  'Stroke': [
    "Follow rehabilitation plan",
    "Take medications to prevent recurrence",
    "Monitor blood pressure regularly",
    "Attend all follow-up appointments",
    "Make necessary lifestyle changes"
  ],
  'Kidney Disease': [
    "Follow prescribed diet restrictions",
    "Monitor fluid intake",
    "Take medications as directed",
    "Attend all dialysis appointments if needed",
    "Monitor blood pressure regularly"
  ],
  'Liver Disease': [
    "Avoid alcohol completely",
    "Follow prescribed diet",
    "Take medications as directed",
    "Monitor for signs of worsening condition",
    "Get regular liver function tests"
  ],
  'Osteoporosis': [
    "Ensure adequate calcium and vitamin D intake",
    "Do weight-bearing exercises",
    "Prevent falls with home safety measures",
    "Take prescribed medications",
    "Get regular bone density tests"
  ],
  'Anemia': [
    "Eat iron-rich foods",
    "Take iron supplements if prescribed",
    "Combine iron sources with vitamin C for absorption",
    "Manage underlying causes",
    "Get regular blood tests"
  ],
  'Thyroid Disorders': [
    "Take medications consistently",
    "Get regular blood tests",
    "Monitor for symptom changes",
    "Manage weight carefully",
    "Follow up with endocrinologist"
  ],
  'Pregnancy': [
    "Attend all prenatal appointments",
    "Take prenatal vitamins",
    "Avoid alcohol, tobacco and drugs",
    "Eat a balanced diet",
    "Get moderate exercise as approved by doctor"
  ],
  'Menstrual Cramps': [
    "Use heating pad on lower abdomen",
    "Try over-the-counter pain relievers",
    "Do gentle exercise like walking",
    "Practice relaxation techniques",
    "See a doctor for severe pain"
  ],
  'Menopause': [
    "Dress in layers for hot flashes",
    "Practice stress-reduction techniques",
    "Ensure adequate calcium intake",
    "Stay sexually active with lubrication if needed",
    "Discuss hormone therapy options with doctor"
  ],
  'Erectile Dysfunction': [
    "Quit smoking",
    "Limit alcohol",
    "Exercise regularly",
    "Manage stress",
    "See a urologist for treatment options"
  ],
  'Prostate Problems': [
    "Limit fluids before bedtime",
    "Reduce caffeine and alcohol",
    "Practice pelvic floor exercises",
    "Get regular screenings after age 50",
    "See a urologist for persistent symptoms"
  ],
  'Breast Health': [
    "Perform monthly self-exams",
    "Get regular mammograms as recommended",
    "Maintain healthy weight",
    "Limit alcohol",
    "Breastfeed if possible"
  ],
  'Obesity': [
    "Set realistic weight loss goals",
    "Eat balanced meals in proper portions",
    "Increase physical activity gradually",
    "Get adequate sleep",
    "Seek support from healthcare professionals"
  ],
  'Eating Disorders': [
    "Seek professional help early",
    "Follow treatment plan",
    "Establish regular eating patterns",
    "Address underlying emotional issues",
    "Join support groups"
  ],
  'Autism': [
    "Follow structured routines",
    "Use clear, simple communication",
    "Create a sensory-friendly environment",
    "Seek early intervention services",
    "Join support networks"
  ],
  'ADHD': [
    "Use organizational tools",
    "Break tasks into smaller steps",
    "Minimize distractions",
    "Get regular exercise",
    "Follow treatment plan"
  ],
  'Alzheimer s': [
    "Establish daily routines",
    "Use memory aids",
    "Ensure home safety",
    "Stay socially engaged",
    "Plan for future care needs"
  ],
  'Parkinson s': [
    "Do regular physical therapy exercises",
    "Use assistive devices as needed",
    "Modify home for safety",
    "Take medications on schedule",
    "Join support groups"
  ],
  'Multiple Sclerosis': [
    "Manage stress",
    "Stay cool in hot weather",
    "Do recommended exercises",
    "Take medications as prescribed",
    "Adapt activities to energy levels"
  ],
  'Lupus': [
    "Protect skin from sun",
    "Get adequate rest",
    "Manage stress",
    "Take medications consistently",
    "Monitor for symptom flares"
  ],
  'Rheumatoid Arthritis': [
    "Do joint-friendly exercises",
    "Use assistive devices",
    "Apply heat/cold for pain relief",
    "Take medications as directed",
    "Protect joints during daily activities"
  ],
  'Gout': [
    "Stay hydrated",
    "Limit purine-rich foods",
    "Elevate affected joints",
    "Take prescribed medications",
    "Avoid alcohol during flare-ups"
  ]
};

  static const List<String> DEFAULT_ADVICE = [
    "Consult a healthcare professional for proper guidance",
    "Follow your doctor's recommendations",
    "Monitor your symptoms closely",
  ];

  // State variables
  List<dynamic> filteredDoctors = [];
  Map<String, dynamic> user = {};
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;

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

  Future<void> _fetchUserData() async {
    try {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        throw Exception("No token found. Please log in.");
      }

      final response = await DioProvider().getUser(token);
      if (response == null) {
        throw Exception("Failed to fetch user data.");
      }

      setState(() {
        user = json.decode(response);
        _filterDoctors();
        _errorMessage = null;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _fetchUserData();
    setState(() => _isRefreshing = false);
  }

  void _filterDoctors() {
    final doctors = user['doctor'] ?? [];
    setState(() {
      filteredDoctors =
          doctors
              .where((doctor) => doctor['category'] == widget.symptomName)
              .toList();
    });
  }

  Widget _buildAdviceCard(String advice, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(advice, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceSection() {
    final adviceList = SYMPTOM_ADVICE[widget.symptomName] ?? DEFAULT_ADVICE;
    final symptomColor = _getSymptomColor(widget.symptomName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [symptomColor.withOpacity(0.2), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Text(
                "Managing ${widget.symptomName}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: symptomColor,
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
        ...adviceList.asMap().entries.map(
          (entry) => _buildAdviceCard(entry.value, entry.key),
        ),
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
            "Available Specialists",
            style: TextStyle(
              fontSize: 18,
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
    if (_isLoading && !_isRefreshing) {
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
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                onPressed: _handleRefresh,
                label: const Text("Try Again"),
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
                "No ${widget.symptomName} specialists available",
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _handleRefresh,
                child: const Text("Refresh"),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          _buildDoctorHeader(),
          ...filteredDoctors.map(
            (doctor) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DoctorCard(route: 'doctor', doctor: doctor),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSymptomColor(String symptom) {
    final colorMap = {
      'Fever': Colors.red,
      'Dental': Colors.teal,
      'Eye Care': Colors.blue,
      'Stress': Colors.purple,
      'Cardiology': Colors.redAccent,
      'Dermatology': Colors.orange,
      'Respirations': Colors.green,
      'Cholesterol': Colors.amber,
      'Diabetes': Colors.blueGrey,
      'Virus': Colors.deepOrange,
    };
    return colorMap[symptom] ?? Colors.blue;
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
            icon: const Icon(Icons.refresh),
            onPressed: _handleRefresh,
            tooltip: 'Refresh',
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
