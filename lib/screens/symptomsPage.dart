import 'package:flutter/material.dart';
import 'package:health/screens/symptoms.dart';

class SymptomsPage extends StatefulWidget {
  final String? selectedCategory;

  const SymptomsPage({super.key, this.selectedCategory});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  // Constants should be in uppercase (Dart convention)
  static const List<Map<String, dynamic>> SYMPTOM_CATEGORIES = [
    {
      "image": 'assets/symptoms/fever.png',
      "name": "Fever",
      "color": Colors.red,
    },
    {
      "image": 'assets/symptoms/dental.png',
      "name": "Dental",
      "color": Colors.teal,
    },
    {
      "image": 'assets/symptoms/eyecare.png',
      "name": "Eye Care",
      "color": Colors.blue,
    },
    {
      "image": 'assets/symptoms/stress.png',
      "name": "Stress",
      "color": Colors.purple,
    },
    {
      "image": 'assets/symptoms/cardiology.png',
      "name": "Cardiology",
      "color": Colors.redAccent,
    },
    {
      "image": 'assets/symptoms/dermatology.png',
      "name": "Dermatology",
      "color": Colors.orange,
    },
    {
      "image": 'assets/symptoms/respirations.png',
      "name": "Respirations",
      "color": Colors.green,
    },
    {
      "image": 'assets/symptoms/cholesterol.png',
      "name": "Cholesterol",
      "color": Colors.amber,
    },
    {
      "image": 'assets/symptoms/diabetes.png',
      "name": "Diabetes",
      "color": Colors.blueGrey,
    },
    {
      "image": 'assets/symptoms/virus.png',
      "name": "Virus",
      "color": Colors.deepOrange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(title: const Text("Check Symptoms"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: SYMPTOM_CATEGORIES.length,
          itemBuilder: (context, index) {
            final category = SYMPTOM_CATEGORIES[index];
            final isSelected = widget.selectedCategory == category['name'];
            final categoryColor = category['color'] as Color;

            return SymptomCategoryCard(
              category: category,
              isSelected: isSelected,
              categoryColor: categoryColor,
              onTap: () => _navigateToSymptoms(context, category['name']),
            );
          },
        ),
      ),
    );
  }

  void _navigateToSymptoms(BuildContext context, String symptomName) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => Symptoms(symptomName: symptomName),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class SymptomCategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final Color categoryColor;
  final VoidCallback onTap;

  const SymptomCategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            isSelected
                ? BorderSide(color: categoryColor, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  category['image'],
                  width: 48,
                  height: 48,
                  errorBuilder:
                      (_, __, ___) => Icon(
                        Icons.medical_services,
                        size: 40,
                        color: categoryColor,
                      ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category['name'],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? categoryColor : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
