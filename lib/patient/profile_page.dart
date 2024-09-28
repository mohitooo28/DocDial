import 'dart:convert';
import 'package:docdial/auth/login_page.dart';
import 'package:docdial/screens/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _quote = "...";
  bool showAboutUs = false; // Flag to control the visibility of the text

  @override
  void initState() {
    super.initState();
    _fetchHealthQuote();
  }

  Future<void> _fetchHealthQuote() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.adviceslip.com/advice'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _quote = data['slip']['advice'] ?? "Stay healthy!";
        });
      } else {
        setState(() {
          _quote = "Could not fetch a health tip, try again later.";
        });
      }
    } catch (e) {
      setState(() {
        _quote = "Error fetching health tip: ${e.toString()}";
      });
    }
  }

  Future<void> openEmailApp() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mohitkhairnar-inft@atharvacoe.ac.in',
    );

    try {
      await launchUrl(emailUri);
    } catch (e) {
      print('Could not launch $emailUri: $e');
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 18, top: 20),
          child: Text(
            'Your Profile',
            style: GoogleFonts.montserratAlternates(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Ensure spacing
              children: [
                Column(
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      backgroundImage: NetworkImage(Global.profileImageUrl!),
                      radius: 60,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Global.username ?? "Name",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _quote,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CustomButtons(
                            onTap: openEmailApp,
                            iconData: Iconsax.sms,
                            description: "Contact Us",
                          ),
                          CustomButtons(
                            onTap: () {
                              setState(() {
                                showAboutUs = true; // Show "Made By Mohit" text
                              });
                            },
                            iconData: Iconsax.people,
                            description: "About Us",
                          ),
                          CustomButtons(
                            onTap: _logout,
                            iconData: Iconsax.logout_1,
                            description: "Logout",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (showAboutUs) // Conditionally show the text
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 20), // Padding from the bottom
                    child: Text(
                      "We are Group No. 12 from the TEIT-2 class (ACE, Malad), a team of four who developed this doctor appointment app as part of our \"Mini Project (Web-Based Business)\" curriculum. Built using Flutter and Firebase, the app streamlines scheduling for doctors and patients, offering an efficient solution for managing appointments. This project reflects our dedication to practical, real-world problem-solving through technology.",
                      style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600),
                      textAlign: TextAlign.justify,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomButtons extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final String description;

  const CustomButtons({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300),
            child: Center(
              child: Icon(
                iconData,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
