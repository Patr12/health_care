import 'package:flutter/material.dart';
import 'package:health/models/authModel.dart';
import 'package:health/screens/home_screen.dart';
import 'package:health/screens/registerPage.dart';
import 'package:health/screens/schedule.dart';
import 'package:health/screens/settings.dart';
import 'package:health/screens/startScreen.dart';
import 'package:health/screens/success.dart';
import 'package:health/screens/symptoms.dart';
import 'package:health/utils/all_health_tips_page.dart';
import 'package:health/utils/clinic_registration_page.dart';
import 'package:health/utils/config.dart';
import 'package:health/utils/disease_prediction_page.dart';
import 'package:health/utils/health_advice_page.dart';
import 'package:health/utils/online_doctor_page.dart';
import 'package:provider/provider.dart';
import 'package:health/screens/doctorDetails.dart';
import 'package:health/screens/loginPage.dart';
import 'package:health/screens/payment.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthModel>(
      create: (context) => AuthModel(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          inputDecorationTheme: const InputDecorationTheme(
            focusColor: Config.primaryColor,
            border: Config.outlinedBorder,
            focusedBorder: Config.focusBorder,
            errorBorder: Config.errorBorder,
            enabledBorder: Config.outlinedBorder,
            floatingLabelStyle: TextStyle(color: Config.primaryColor),
            prefixIconColor: Colors.black38,
          ),
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Config.primaryColor,
            selectedItemColor: Colors.white,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            unselectedItemColor: Colors.grey.shade700,
            elevation: 10,
            type: BottomNavigationBarType.fixed,
          ),
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          'login': (context) => LoginForm(),
          'register': (context) => RegisterPage(),
          'home': (context) => const HomeScreen(),
          // renamed to avoid key conflict
          'symptoms': (context) => Symptoms(symptomName: ''),
          'doctor': (context) => const DoctorDetails(doctor: {}),
          'schedule': (context) => const Schedule(),
          'payment': (context) => const Payment(),
          'success': (context) => const Success(),
          'settings': (context) => Settings(),
          '/disease_prediction': (context) => const DiseasePredictionPage(),
          '/clinic_registration': (context) => ClinicRegistrationPage(),
          '/health_advice': (context) => const HealthAdvicePage(),
          '/online_doctor': (context) => const OnlineDoctorPage(),
          '/all_health_tips': (context) => const AllHealthTipsPage(),
          '/register': (context) => const RegisterPage(),
        },
      ),
    );
  }
}
