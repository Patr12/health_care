import 'package:flutter/material.dart';

class DiseasePredictionPage extends StatelessWidget {
  const DiseasePredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utabiri wa Magonjwa'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pata utabiri wa magonjwa kulingana na dalili zako',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: const Text('Anza Uchunguzi'),
              onPressed: () {
                // Add disease prediction logic here
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Dalili za Kawaida:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text('Homa na Mafua'),
                  ),
                  ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text('Kuumwa kichwa'),
                  ),
                  ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text('Kichefuchefu'),
                  ),
                  ListTile(
                    leading: Icon(Icons.medical_services),
                    title: Text('Kuharisha'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}