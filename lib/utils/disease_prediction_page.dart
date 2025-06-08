import 'package:flutter/material.dart';
import 'package:health/screens/symptomsPage.dart';

class DiseasePredictionPage extends StatelessWidget {
  const DiseasePredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Common symptoms data
    final commonSymptoms = [
      {'name': 'Homa na Mafua', 'icon': Icons.thermostat, 'color': Colors.red},
      {'name': 'Kuumwa kichwa', 'icon': Icons.sick, 'color': Colors.orange},
      {
        'name': 'Kichefuchefu',
        'icon': Icons.coronavirus,
        'color': Colors.green,
      },
      {
        'name': 'Kuharisha',
        'icon': Icons.medical_services,
        'color': Colors.blue,
      },
      {'name': 'Kifaduro', 'icon': Icons.air, 'color': Colors.purple},
      {'name': 'Maumivu ya tumbo', 'icon': Icons.healing, 'color': Colors.teal},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utabiri wa Magonjwa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to prediction history
            },
            tooltip: 'Historia ya Utabiri',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.medical_information,
                      size: 50,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pata utabiri wa magonjwa kulingana na dalili zako',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Start prediction button
            ElevatedButton.icon(
              icon: const Icon(Icons.search, size: 24),
              label: const Text(
                'ANZA UCHUNGUZI',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SymptomsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Common symptoms section
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Dalili za Kawaida:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Chagua moja kwa moja kwa kugusia au anza uchunguzi wa kina',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 15),

            // Symptoms grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemCount: commonSymptoms.length,
              itemBuilder: (context, index) {
                final symptom = commonSymptoms[index];
                return SymptomChip(
                  name: symptom['name'] as String,
                  icon: symptom['icon'] as IconData,
                  color: symptom['color'] as Color,
                  onTap: () {
                    // Navigate directly to prediction for this symptom
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Mfumo huu haubadili ushauri wa daktari',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

// Custom symptom chip widget
class SymptomChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const SymptomChip({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
