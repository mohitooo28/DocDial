import 'package:docdial/screens/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:docdial/auth/login_page.dart';
import 'package:docdial/doctor/doctor_nav_page.dart';
import 'package:docdial/patient/patient_nav_page.dart';
import 'package:svg_flutter/svg.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    User? user = _auth.currentUser;

    if (user == null) {
      // User not logged in, delay and navigate to login screen
      await Future.delayed(const Duration(seconds: 2));
      _navigateToLogin();
    } else {
      // User is logged in, check if doctor or patient
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(user.uid)
          .get();

      if (doctorSnapshot.exists) {
        // If user is a doctor
        Global.initializeUser();
        await Future.delayed(const Duration(seconds: 2));
        _navigateToDoctorHome();
      } else {
        // Check if user is a patient
        DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
            .collection('Patients')
            .doc(user.uid)
            .get();

        if (patientSnapshot.exists) {
          // If user is a patient
          Global.initializeUser();
          await Future.delayed(const Duration(seconds: 2));
          _navigateToPatientHome();
        } else {
          // No valid user data, navigate to login
          await Future.delayed(const Duration(seconds: 2));
          _navigateToLogin();
        }
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _navigateToDoctorHome() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const DoctorNavigationPage()));
  }

  void _navigateToPatientHome() {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PatientNavigationPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF40B44F), Color(0xFF04421E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Center(
                child: SvgPicture.asset(
                  'assets/logo/logo.svg',
                  color: Colors.white,
                  width: 100,
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
