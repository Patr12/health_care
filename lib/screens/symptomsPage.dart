import 'package:flutter/material.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/screens/symptoms.dart';
import '../utils/config.dart';

class SymptomsPage extends StatefulWidget {
  final String? selectedCategory; // Nullable for optional selection

  const SymptomsPage({super.key, this.selectedCategory});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  // Moved outside build() to avoid rebuilds
  static const List<Map<String, dynamic>> _symptomCategories = [
    {"image": 'assets/symptoms/fever.png', "name": "Fever"},
    {"image": 'assets/symptoms/dental.png', "name": "Dental"},
    {"image": 'assets/symptoms/eyecare.png', "name": "Eye Care"},
    {"image": 'assets/symptoms/stress.png', "name": "Stress"},
    {"image": 'assets/symptoms/cardiology.png', "name": "Cardiology"},
    {"image": 'assets/symptoms/dermatology.png', "name": "Dermatology"},
    {"image": 'assets/symptoms/respirations.png', "name": "Respirations"},
    {"image": 'assets/symptoms/cholesterol.png', "name": "Cholesterol"},
    {"image": 'assets/symptoms/diabetes.png', "name": "Diabetes"},
    {"image": 'assets/symptoms/virus.png', "name": "Virus"},
  ];

  @override
  Widget build(BuildContext context) {
    final selectedCategory = widget.selectedCategory;

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: selectedCategory != null 
            ? "Symptoms for $selectedCategory" 
            : "Select Your Symptoms",
        icon: const Icon(Icons.arrow_back_ios),
        actions: [
          IconButton(
            onPressed: () async {
              // TODO: Implement favorite action
            },
            icon: const Icon(
              Icons.favorite_border_outlined,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: _symptomCategories.length,
          itemBuilder: (context, index) {
            final category = _symptomCategories[index];
            final isSelected = selectedCategory == category['name'];

            return _SymptomCategoryCard(
              category: category,
              isSelected: isSelected,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Symptoms(symptomName: category['name']),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Extracted as a separate widget for better performance (optional but recommended)
class _SymptomCategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;

  const _SymptomCategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        color: isSelected ? Colors.blue[50] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected
              ? const BorderSide(color: Colors.blue, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              category['image'],
              width: 80,
              height: 60,
              errorBuilder: (_, __, ___) => const Icon(Icons.error), // Handle missing images
            ),
            Config.spaceSmall,
            Text(
              category['name'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}