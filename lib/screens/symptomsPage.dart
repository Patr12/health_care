import 'package:flutter/material.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/screens/symptoms.dart';
import '../utils/config.dart';

class SymptomsPage extends StatefulWidget {
  final String? selectedCategory; // Make it optional with null safety

  const SymptomsPage({super.key, this.selectedCategory});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  // List of all symptom categories
  final List<Map<String, dynamic>> symptomCategories = [
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
    // Highlight the selected category if one was passed
    String? selected = widget.selectedCategory;

    return Scaffold(
      appBar: CustomAppBar(
        appTitle: selected != null 
            ? "Symptoms for $selected" 
            : "Select Your Symptoms",
        icon: const Icon(Icons.arrow_back_ios),
        actions: [
          IconButton(
            onPressed: () async {},
            icon: const Icon(
              Icons.favorite_border_outlined,
              color: Colors.blue,
            ),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        itemCount: symptomCategories.length,
        itemBuilder: (context, index) {
          final category = symptomCategories[index];
          final isSelected = selected == category['name'];
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Symptoms(symptomName: category['name']),
                ),
              );
            },
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
        },
      ),
    );
  }
}