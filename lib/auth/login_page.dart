import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:docdial/screens/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docdial/auth/signup_screen.dart';
import 'package:docdial/auth/widget/email_field.dart';
import 'package:docdial/auth/widget/password_field.dart';
import 'package:docdial/doctor/doctor_nav_page.dart';
import 'package:docdial/patient/patient_nav_page.dart';
import 'package:svg_flutter/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _passwordController = TextEditingController();

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();

  bool _isLoading = false;
  bool _isNavigation = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: _isLoading
          ? const CustomCircularLoading()
          : SafeArea(
              child: GestureDetector(
                onTap: FocusScope.of(context).unfocus,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 55),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //*-------------------------------------------------------------
                        GestureDetector(
                          onLongPress: () {
                            HapticFeedback.heavyImpact();
                          },
                          child: SvgPicture.asset(
                            'assets/logo/logo.svg',
                            height: 100,
                          ),
                        ),
                        //*-------------------------------------------------------------
                        const SizedBox(height: 15),
                        Text(
                          'Login',
                          style: GoogleFonts.museoModerno(
                              color: const Color(0xFF19244D),
                              fontSize: 28,
                              fontWeight: FontWeight.w600),
                        ),
                        //*-------------------------------------------------------------
                        const SizedBox(height: 5),
                        Text(
                          'Welcome Back to DocDial :)',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        //*-------------------------------------------------------------
                        Text(
                          'Log in to book your appointments',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),
                        //!-----------------------------------------------------
                        const SizedBox(height: 28),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //*-----------------------------------------------
                              EmailTextField(
                                  emailController: _emailController,
                                  emailFocusNode: f1,
                                  nextFocusNode: f2),
                              //*-----------------------------------------------
                              PasswordTextField(
                                  passwordController: _passwordController,
                                  passwordFocusNode: f2,
                                  nextFocusNode: f3),
                              //*-----------------------------------------------
                            ],
                          ),
                        ),
                        //*-----------------------------------------------------
                        const SizedBox(height: 60),
                        InkWell(
                          focusNode: f3,
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            if (_formKey.currentState!.validate()) {
                              // showLoaderDialog(context);
                              _login();
                            }
                          },
                          child: Container(
                            width: screenSize,
                            height: 50,
                            decoration: BoxDecoration(
                                color: const Color(0xFF40B44F),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                'LOGIN',
                                style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        //*-------------------------------------------------------------
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                // builder: (context) => const RegisterPage()));
                                builder: (context) => const RegisterPage()));
                          },
                          child: Container(
                            width: screenSize,
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF40B44F), width: 1.5),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                'CREATE ACCOUNT',
                                style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    color: const Color(0xFF40B44F),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        User? user = userCredential.user;

        if (user != null) {
          // Check if user is a doctor
          DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
              .collection('Doctors')
              .doc(user.uid)
              .get();

          if (doctorSnapshot.exists) {
            _navigateToDoctorHome();
          } else {
            // Check if user is a patient
            DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
                .collection('Patients')
                .doc(user.uid)
                .get();
            if (patientSnapshot.exists) {
              await Global.initializeUser();
              _navigateToPatientHome();
            } else {
              _showErrorDialog('User not found');
            }
          }
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Error', style: TextStyle(color: Color(0xFF40B44F))),
          content: Text(_getFormattedMessage(message)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFF40B44F))),
            ),
          ],
        );
      },
    );
  }

  String _getFormattedMessage(String message) {
    return message.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  void _navigateToDoctorHome() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const DoctorNavigationPage()));
    }
  }

  void _navigateToPatientHome() {
    if (!_isNavigation) {
      _isNavigation = true;
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const PatientNavigationPage()));
    }
  }
}
