import 'package:flutter/material.dart';

class HealthAdvicePage extends StatelessWidget {
  final List<Map<String, String>> healthTips = const [
    {
      'title': 'Lishe Bora',
      'tip': 'Kula vyakula vyenye virutubishi kama matunda, mboga na protini.',
      'icon': '🍎',
    },
    {
      'title': 'Mazoezi',
      'tip': 'Fanya mazoezi angalau dakika 30 kila siku kwa afya njema.',
      'icon': '🏃',
    },
    {
      'title': 'Usingizi',
      'tip': 'Lala saa 7-9 kila usiku kwa afya ya akili na mwili.',
      'icon': '😴',
    },
    {
      'title': 'Majani ya Mafuta',
      'tip': 'Epuka vyakula vyenye mafuta mengi na sukari nyingi.',
      'icon': '🚫',
    },
    {
      'title': 'Kunywa Maji',
      'tip': 'Kunywa lita 2 za maji kwa siku kwa utunzaji mzuri wa mwili.',
      'icon': '💧',
    },
    {
      'title': 'Dawa Zinazofaa',
      'tip': 'Chukua dawa zako kwa wakati na kwa maagizo ya daktari.',
      'icon': '💊',
    },
  ];

  const HealthAdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ushauri wa Afya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        backgroundColor: Colors.teal.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: healthTips.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final tip = healthTips[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Colors.teal.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        tip['icon']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontFamily: 'Noto Color Emoji',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tip['tip']!,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add share functionality
          _shareHealthTips(context);
        },
        backgroundColor: Colors.teal.shade700,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }

  void _shareHealthTips(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Shiriki Ushauri'),
            content: const Text('Unataka kushiriki ushauri huu?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ghairi'),
              ),
              TextButton(
                onPressed: () {
                  // Implement share logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ushauri umeeshirikiwa!')),
                  );
                },
                child: const Text('Shiriki'),
              ),
            ],
          ),
    );
  }
}
