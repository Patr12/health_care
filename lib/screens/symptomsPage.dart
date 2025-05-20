import 'package:flutter/material.dart';
import 'package:health/components/customAppBar.dart';
import 'package:health/screens/symptoms.dart';

import '../utils/config.dart';

class SymptomsPage extends StatefulWidget {
  const SymptomsPage({super.key});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: "Select Your Symptoms",
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
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),        
        child: GestureDetector(
          child: GridView.count(
            crossAxisCount: 2, 
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: <Widget>[
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/fever.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Fever",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/dental.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Dental",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/cardiology.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Cardiology",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/dermatology.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Dermatology",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/cholesterol.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Cholesterol",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/diabetes.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Diabetes",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/respirations.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Respirations",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/eyecare.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Eye Care",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/stress.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Stress",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                child: Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'assets/symptoms/virus.png',
                              width: 80,
                              height: 60,
                            ),
                            Config.spaceSmall,
                            Text(
                              "Virus",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),          
          onTap: () {
            String symptomName = "Fever"; 
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Symptoms(symptomName: symptomName),
              ),
            );
          },
        ),
      ),
    );
  }
}
