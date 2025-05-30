import 'package:flutter/material.dart';

class AllHealthTipsPage extends StatelessWidget {
  final List<Map<String, String>> allTips = const [
    {
      'category': 'Lishe',
      'icon': '🍎',
      'tips': '''
1. Kula matunda na mboga kila siku
2. Punguza mafuta na sukari
3. Kunywa maji ya kutosha
4. Kula vyakula vyenye fiber
5. Chagua protini bora kama samaki, kuku na mbegu
6. Epuka vyakula vilivyochakaa sana
7. Weka kikomo kwa chumvi
''',
    },
    {
      'category': 'Mazoezi',
      'icon': '🏃',
      'tips': '''
1. Fanya mazoezi angalau dakika 30 kila siku
2. Tembea kwa kasi kama huna muda wa mazoezi
3. Fanya mazoezi ya nguvu mara 2-3 kwa wiki
4. Epuka kukaa kwa muda mrefu bila kusimama
5. Jaribu yoga au kunyoosha mwili
6. Fanya mazoezi ya kupumua kwa undani
7. Pata mwenzio wa kufanya mazoezi pamoja
''',
    },
    {
      'category': 'Usingizi',
      'icon': '😴',
      'tips': '''
1. Lala saa 7-9 kila usiku
2. Weka ratiba ya usingizi
3. Epuka kutumia vifaa vya elektroniki kabla ya kulala
4. Hakikisha chumba chako cha kulala kina giza na kimya
5. Tumia kitanda na mto wa kulala wenye kuvumilia
6. Punguza kinywaji chenye kafeini mchana
7. Fanya mazoezi ya kufurahisha usingizi
''',
    },
    {
      'category': 'Afya ya Akili',
      'icon': '🧠',
      'tips': '''
1. Fanya mazoezi ya kufikirika kila siku
2. Pumzika na kujifurahisha
3. Kuwa na mazungumzo mazuri na watu
4. Jifunze kitu kipya kila siku
5. Andika shukrani au malengo yako
6. Omba au fanya mazoezi ya roho
7. Tafuta msaada unapohitaji
''',
    },
  ];

  const AllHealthTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vidokezo vya Afya Bora',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: allTips.length,
          itemBuilder: (context, index) {
            final category = allTips[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Add navigation to detailed view if needed
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            category['icon']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category['category']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.teal.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...category['tips']!
                          .split('\n')
                          .where((tip) => tip.trim().isNotEmpty)
                          .map(
                            (tip) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4.0),
                                    child: Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tip.trim(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add functionality for sharing or saving tips
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.share, color: Colors.white),
      ),
    );
  }
}
