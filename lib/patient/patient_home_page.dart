import 'package:docdial/doctor/doctor_details_page.dart';
import 'package:docdial/patient/doctor_list_category.dart';
import 'package:docdial/patient/model/doc_categories.dart';
import 'package:docdial/patient/search_page.dart';
import 'package:docdial/patient/widget/category.dart';
import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:docdial/patient/widget/my_appointment_card.dart';
import 'package:docdial/patient/widget/top_doctor.dart';
import 'package:docdial/screens/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docdial/doctor/model/doctor.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _docSearch = TextEditingController();

  List<Doctor> _doctors = [];
  bool _isLoading = true;
  Map<String, dynamic>? _latestAppointment;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    _fetchLatestAppointment();
  }

  Future<void> _fetchDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Doctors').get();
      List<Doctor> tmpDoctors = snapshot.docs.map((doc) {
        return Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Sort doctors by averageRating in descending order
      tmpDoctors.sort((a, b) => b.averageRating.compareTo(a.averageRating));

      // Keep only the top 5 doctors
      tmpDoctors = tmpDoctors.take(5).toList();

      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error here
      print("Error fetching doctors: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLatestAppointment() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('Appointments')
            .where('sender', isEqualTo: currentUserId)
            .get();

        List<Map<String, dynamic>> tempBookings = [];
        for (var doc in snapshot.docs) {
          final booking = doc.data() as Map<String, dynamic>;
          if (booking['status'] == 'Booked') {
            tempBookings.add(booking);
          }
        }

        // Find the closest upcoming booking
        if (tempBookings.isNotEmpty) {
          tempBookings.sort((a, b) {
            DateTime aDateTime = _parseDateTime(a['date'], a['time']);
            DateTime bDateTime = _parseDateTime(b['date'], b['time']);
            return aDateTime.compareTo(bDateTime);
          });

          final now = DateTime.now();
          final upcomingBookings = tempBookings.where((booking) {
            final dateTime = _parseDateTime(booking['date'], booking['time']);
            return dateTime.isAfter(now);
          }).toList();

          if (upcomingBookings.isNotEmpty) {
            final appointment = upcomingBookings.first;

            // Now fetch the doctor details using the 'receiver' UID from the appointment
            DocumentSnapshot doctorSnapshot = await _firestore
                .collection('Doctors')
                .doc(appointment['receiver'])
                .get();

            if (doctorSnapshot.exists) {
              final doctorData = doctorSnapshot.data() as Map<String, dynamic>;
              setState(() {
                _latestAppointment = {
                  'date': appointment['date'],
                  'time': appointment['time'],
                  'doctorName':
                      "${doctorData['firstName']} ${doctorData['lastName']}",
                  'doctorProfilePic': doctorData['profileImageUrl'],
                  'doctorCategory': doctorData['category'],
                  'doctorRating': doctorData['averageRating'],
                };
              });
            }
          }
        }
      } catch (e) {
        // Handle error here
        print("Error fetching appointments: $e");
      }
    }
  }

  DateTime _parseDateTime(String date, String time) {
    final dateParts = date.split('/');
    final timeParts = time.split(' ');
    final timeSplit = timeParts[0].split(':');
    final amPm = timeParts[1].toUpperCase();

    final month = int.parse(dateParts[0]);
    final day = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);
    final hour = int.parse(timeSplit[0]);
    final minute = int.parse(timeSplit[1]);

    final adjustedHour = amPm == 'PM' && hour != 12
        ? hour + 12
        : amPm == 'AM' && hour == 12
            ? 0
            : hour;

    return DateTime(year, month, day, adjustedHour, minute);
  }

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;

    String greeting;
    if (currentHour < 12) {
      greeting = 'Good Morning';
    } else if (currentHour < 18) {
      greeting = 'Good Afternoon';
    } else if (currentHour < 22) {
      greeting = 'Good Evening';
    } else {
      greeting = 'Good Night';
    }

    return Scaffold(
      body: _isLoading
          ? const CustomCircularLoading()
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //! Header -----------------------------------------------
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting,
                                  style: GoogleFonts.nunitoSans(
                                    color: const Color(0xFF909090),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${Global.username}", // Display the user's full name here
                                  style: GoogleFonts.montserratAlternates(
                                    color: const Color(0xFF067B15),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Stack(
                              children: [
                                const Icon(
                                  Iconsax.notification,
                                  size: 32,
                                  color: Color(0xFF909090),
                                ),
                                Positioned(
                                  right: 1,
                                  child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFF19244D)),
                                      child: Center(
                                        child: Text(
                                          (_latestAppointment == null)
                                              ? '0'
                                              : '1',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),

                      // * Search Bar ------------------------------------------
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: const Offset(1, 3),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.search,
                            controller: _docSearch,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    left: 20, top: 15, bottom: 15),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[200],
                                hintText: 'Search doctor',
                                hintStyle: GoogleFonts.lato(
                                  color: Colors.black26,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF8391A1),
                                )),
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                            onFieldSubmitted: (String value) {
                              if (value.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SearchResultPage(searchQuery: value),
                                  ),
                                );
                                _docSearch.clear();
                              }
                            },
                          ),
                        ),
                      ),

                      // ! Doctor by Categories --------------------------------
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            const SizedBox(width: 30),
                            Row(
                              children: categories.map((category) {
                                return CategoryButton(
                                  bgColor: category['bgColor'],
                                  assetLoc: category['assetLoc'],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DoctorByCategory(
                                          category: category['category'],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // * Your Appointment ------------------------------------
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 45),
                        child: Text(
                          "My Appointment",
                          style: GoogleFonts.nunitoSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _latestAppointment == null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: Text(
                                  'No appointments? That’s always a good thing!',
                                  style: GoogleFonts.nunitoSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500)),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 30),
                              child: MyAppointmentCard(
                                docProfilePic:
                                    _latestAppointment!['doctorProfilePic'],
                                docName: _latestAppointment!['doctorName'],
                                docCategory:
                                    _latestAppointment!['doctorCategory'],
                                rating: _latestAppointment!['doctorRating']
                                    .toString(),
                                date: _latestAppointment!['date'],
                                time: _latestAppointment!['time'],
                                onTap: () {},
                              ),
                            ),

                      // ! Top Rated Doctor ------------------------------------
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 45),
                        child: Text(
                          "Top Rated Doctors",
                          style: GoogleFonts.nunitoSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            const SizedBox(width: 30),
                            Row(
                              children: List.generate(
                                _doctors.length,
                                (index) => TopDoctorCard(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DoctorDetailPage(
                                            doctor: _doctors[index]),
                                      ),
                                    );
                                  },
                                  doctor: _doctors[index],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //* Message =-------------------------------------------
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 60, 30, 30),
                        child: Text(
                          "Your Health, \nDeserves Attention",
                          style: GoogleFonts.doHyeon(
                            color: Colors.grey.withOpacity(0.3),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.3,
                            fontSize: 32,
                          ),
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
