import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package
import 'package:docdial/auth/login_page.dart';
import 'package:docdial/patient/widget/profile_page_buttons.dart';
import 'package:docdial/screens/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> fetchDoctorDetails() async {
    // Get current user's UID
    User? user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection('Doctors').doc(user.uid).get();
    } else {
      throw Exception("No user logged in");
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

  double toDouble(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      return value.toDouble();
    } else {
      return 0.0;
    }
  }

  double totalCondition(double totalReviews) {
    if (totalReviews < 10) {
      return 10.0;
    } else if (totalReviews < 50) {
      return 50.0;
    } else {
      return 100.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 18, top: 20),
          child: Text(
            'Doctor Profile',
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
            child: FutureBuilder<DocumentSnapshot>(
              future: fetchDoctorDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('Doctor details not found');
                }

                var doctorData = snapshot.data!.data() as Map<String, dynamic>;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(Global.profileImageUrl!),
                          radius: 60,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Dr. ${doctorData['firstName'] ?? ''}${doctorData['lastName'] ?? ''}"
                              .trim(),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          doctorData['category'] ?? "Category",
                          style: GoogleFonts.nunitoSans(
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Iconsax.record,
                              size: 6,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 5),
                            (doctorData['gender'] == "Male")
                                ? const Icon(
                                    Iconsax.man,
                                    size: 15,
                                    color: Colors.blueAccent,
                                  )
                                : const Icon(
                                    Iconsax.woman,
                                    size: 15,
                                    color: Colors.pink,
                                  ),
                            const SizedBox(width: 5),
                            const Icon(
                              Iconsax.record,
                              size: 6,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              doctorData['qualification'] ?? "Qualification",
                              style: GoogleFonts.nunitoSans(
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Iconsax.record,
                              size: 6,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              doctorData['city'] ?? "Qualification",
                              style: GoogleFonts.nunitoSans(
                                color: Colors.black.withOpacity(0.6),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Iconsax.record,
                              size: 6,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        //!-----------------------------------------------------
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              //*-----------------------------------------------
                              Column(
                                children: [
                                  Container(
                                    width: 165,
                                    height: 165,
                                    padding: EdgeInsets.zero,
                                    child: SfRadialGauge(axes: <RadialAxis>[
                                      // Create a primary radial axis
                                      RadialAxis(
                                        minimum: 0,
                                        maximum: totalCondition(
                                          double.tryParse(
                                                  doctorData['totalReviews']
                                                      .toString()) ??
                                              0.0,
                                        ),
                                        showLabels: false,
                                        showTicks: false,
                                        startAngle: 270,
                                        endAngle: 270,
                                        radiusFactor: 0.7,
                                        axisLineStyle: const AxisLineStyle(
                                          thickness: 0.2,
                                          color: Color(0xFF9DFFAA),
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            // value: doctorData["averageRating"] ?? 5,
                                            value: toDouble(
                                                doctorData['totalReviews']),
                                            width: 0.07,
                                            pointerOffset: 0.07,
                                            sizeUnit: GaugeSizeUnit.factor,
                                            color: const Color(0xFF109421),
                                          )
                                        ],
                                      ),
                                    ]),
                                  ),
                                  Text(
                                    "Total Appointments",
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.black.withOpacity(0.8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    doctorData['totalReviews'].toString(),
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.black.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              //*-----------------------------------------------
                              Column(
                                children: [
                                  SizedBox(
                                    width: 165,
                                    height: 165,
                                    child: SfRadialGauge(axes: <RadialAxis>[
                                      // Create a primary radial axis
                                      RadialAxis(
                                        minimum: 0,
                                        maximum: 5,
                                        showLabels: false,
                                        showTicks: false,
                                        startAngle: 270,
                                        endAngle: 270,
                                        radiusFactor: 0.7,
                                        axisLineStyle: const AxisLineStyle(
                                          thickness: 0.2,
                                          color: Color(0xFFFFF0A3),
                                          thicknessUnit: GaugeSizeUnit.factor,
                                        ),
                                        pointers: <GaugePointer>[
                                          RangePointer(
                                            value: toDouble(
                                                doctorData['averageRating']),
                                            width: 0.07,
                                            pointerOffset: 0.07,
                                            sizeUnit: GaugeSizeUnit.factor,
                                            color: const Color(0xFFFF9900),
                                          )
                                        ],
                                      ),
                                      RadialAxis(
                                        minimum: 0,
                                        interval: 1,
                                        maximum: 5,
                                        showLabels: false,
                                        showTicks: true,
                                        showAxisLine: false,
                                        tickOffset: -0.05,
                                        offsetUnit: GaugeSizeUnit.factor,
                                        minorTicksPerInterval: 0,
                                        startAngle: 270,
                                        endAngle: 270,
                                        radiusFactor: 0.7,
                                        majorTickStyle: const MajorTickStyle(
                                            length: 0.3,
                                            thickness: 3,
                                            lengthUnit: GaugeSizeUnit.factor,
                                            color: Colors.white),
                                      )
                                    ]),
                                  ),
                                  Text(
                                    "Rating",
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.black.withOpacity(0.8),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    "${doctorData['averageRating'].toString()} / 5.0",
                                    style: GoogleFonts.nunitoSans(
                                      color: Colors.black.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              //*-----------------------------------------------
                            ],
                          ),
                        ),
                        //!-----------------------------------------------------
                        const SizedBox(height: 60),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                  _showAboutUsDialog(context);
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
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void _showAboutUsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("About Us"),
        content: const Text(
          "We are Group No. 12 from the TEIT-2 class (ACE, Malad), a team of four who developed this doctor appointment app as part of our \"Mini Project (Web-Based Business)\" curriculum. Built using Flutter and Firebase, the app streamlines scheduling for doctors and patients, offering an efficient solution for managing appointments. This project reflects our dedication to practical, real-world problem-solving through technology.",
          textAlign: TextAlign.justify,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text(
              "Close",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
