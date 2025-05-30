import 'package:flutter/material.dart';
import 'package:health/widget/emergence_call_widget.dart';

class ClinicPage extends StatefulWidget {
  const ClinicPage({super.key});

  @override
  State<ClinicPage> createState() => _ClinicPageState();
}

class _ClinicPageState extends State<ClinicPage> {
  final List<Map<String, String>> healthTips = const [
    {
      'title': 'Kunywa Maji ya Kutosha',
      'tip':
          'Kunywa angalau glasi 8 za maji kila siku kusaidia mmeng\'enyo wa chakula na kuondoa sumu mwilini.',
      'icon': '💧',
    },
    {
      'title': 'Fanya Mazoezi Mara kwa Mara',
      'tip':
          'Fanya angalau dakika 30 za mazoezi kila siku ili kudumisha afya ya moyo na mwili.',
      'icon': '🏃',
    },
    {
      'title': 'Lala Saa 7-9 Kila Usiku',
      'tip': 'Usingizi wa kutosha huimarisha kinga ya mwili na afya ya akili.',
      'icon': '😴',
    },
    {
      'title': 'Kula Matunda na Mboga za Majani',
      'tip':
          'Matunda na mboga huongeza virutubisho muhimu na kusaidia kinga ya mwili.',
      'icon': '🍏',
    },
    {
      'title': 'Punguza Matumizi ya Sukari',
      'tip':
          'Kula sukari kidogo ili kupunguza hatari ya kisukari na unene kupita kiasi.',
      'icon': '🍭',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Afya Bora',
                style: TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Image.asset(
                'assets/home_banner.png',
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            ],
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Karibu kwenye Afya Bora! App',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pata ushauri wa afya, utabiri wa magonjwa, na huduma za kliniki kwa urahisi.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Navigate to registration page
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text(
                            'Anza Sasa',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Quick Services Section
                Text(
                  'Huduma za Haraka',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.2,
                  children: [
                    _serviceCard(
                      context,
                      'Utabiri wa Magonjwa',
                      Icons.healing,
                      Colors.blue.shade100,
                      Colors.blue,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/disease_prediction',
                          ),
                    ),
                    _serviceCard(
                      context,
                      'Kujiandikisha Kliniki',
                      Icons.local_hospital,
                      Colors.green.shade100,
                      Colors.green,
                      onTap:
                          () => Navigator.pushNamed(
                            context,
                            '/clinic_registration',
                          ),
                    ),
                    _serviceCard(
                      context,
                      'Ushauri wa Afya',
                      Icons.health_and_safety,
                      Colors.orange.shade100,
                      Colors.orange,
                      onTap:
                          () => Navigator.pushNamed(context, '/health_advice'),
                    ),
                    _serviceCard(
                      context,
                      'Daktari Mtandaoni',
                      Icons.video_call,
                      Colors.purple.shade100,
                      Colors.purple,
                      onTap:
                          () => Navigator.pushNamed(context, '/online_doctor'),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Health Tips Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vidokezo vya Afya',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/all_health_tips');
                      },
                      child: const Text('Ona Zote'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...healthTips.map((tip) => _healthTipCard(tip)),
                const SizedBox(height: 30),

                // Emergency Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Text(
                            'Dharura ya Afya',
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Kwa dharura yoyote ya afya, wasiliana na daktari mara moja au piga simu ya dharura.',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.phone),
                          label: const Text('Piga Simu ya Dharura'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade700,
                            side: BorderSide(color: Colors.red.shade700),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EmergencyCallWidget(),
                              ),
                            );
                            // Implement emergency call functionality
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor, {
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: iconColor),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _healthTipCard(Map<String, String> tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                tip['icon'] ?? '💡',
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tip['tip'] ?? 'No Tip',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
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
