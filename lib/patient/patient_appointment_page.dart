// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/doctor/model/booking.dart';
import 'package:docdial/patient/widget/completed_appointment_card.dart';
import 'package:docdial/patient/widget/upcoming_appointment_card.dart';
import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svg_flutter/svg.dart';

class PatientAppointmentPage extends StatefulWidget {
  const PatientAppointmentPage({super.key});

  @override
  _PatientAppointmentPageState createState() => _PatientAppointmentPageState();
}

class _PatientAppointmentPageState extends State<PatientAppointmentPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Booking> _upcomingBookings = [];
  List<Booking> _completedBookings = [];
  bool _isLoading = true;
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    _fetchBookings();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    print("+++++++++++++Fetch Booking Function+++++++++++");
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      try {
        // Print current user ID for debugging
        print("Current user ID: $currentUserId");

        QuerySnapshot snapshot = await _firestore
            .collection('Appointments')
            .where('sender', isEqualTo: currentUserId)
            .get();

        // Log the raw data from Firestore to ensure it's being fetched
        print("Raw Firestore data: ${snapshot.docs.map((doc) => doc.data())}");

        List<Booking> tempBookings = snapshot.docs.map((doc) {
          return Booking.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        // Log the list of bookings fetched
        print("Temp bookings: $tempBookings");

        // Filter and sort bookings for Upcoming and Completed
        List<Booking> upcoming = tempBookings
            .where((booking) =>
                booking.status == 'Pending' || booking.status == 'Booked')
            .toList()
          ..sort((a, b) {
            try {
              DateTime dateA = DateTime.parse('${a.date} ${a.time}');
              DateTime dateB = DateTime.parse('${b.date} ${b.time}');
              return dateA.compareTo(dateB); // Closest to farthest
            } catch (e) {
              print("Error parsing date or time: $e");
              return 0;
            }
          });

        List<Booking> completed = tempBookings
            .where((booking) => booking.status == 'Completed')
            .toList()
          ..sort((a, b) {
            try {
              DateTime dateA = DateTime.parse('${a.date} ${a.time}');
              DateTime dateB = DateTime.parse('${b.date} ${b.time}');
              return dateA.compareTo(dateB); // Oldest to newest
            } catch (e) {
              print("Error parsing date or time: $e");
              return 0;
            }
          });

        setState(() {
          _upcomingBookings = upcoming;
          _completedBookings = completed;
          _isLoading = false;
        });

        // Log results after sorting
        print("Upcoming bookings: $_upcomingBookings");
        print("Completed bookings: $_completedBookings");
      } catch (e) {
        print("Error fetching bookings: $e");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print("User ID is null");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 18, top: 20),
          child: Text(
            'Appointments',
            style: GoogleFonts.montserratAlternates(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const CustomCircularLoading()
          : SafeArea(
              child: _buildTabView(),
            ),
    );
  }

  // Widget for TabView
  Widget _buildTabView() {
    return _upcomingBookings.isEmpty && _completedBookings.isEmpty
        ? Center(
            child: Column(
              children: [
                const SizedBox(height: 120),
                SvgPicture.asset(
                  "assets/vector/nothing.svg",
                  height: 250,
                ),
                const SizedBox(height: 30),
                Text(
                  'No Bookings Yet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              children: [
                _buildTabBar(),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      UpcomingAppointments(bookings: _upcomingBookings),
                      CompletedAppointments(bookings: _completedBookings),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  // TabBar widget
  Widget _buildTabBar() {
    return Container(
      width: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9).withOpacity(0.6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(3),
            child: TabBar(
              dividerColor: Colors.transparent,
              unselectedLabelStyle: GoogleFonts.nunitoSans(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
              labelStyle: GoogleFonts.nunitoSans(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              controller: tabController,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingAppointments extends StatelessWidget {
  final List<Booking> bookings;

  const UpcomingAppointments({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return bookings.isEmpty
        ? Center(
            child: Text(
              'No Upcoming Appointments',
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return UpcomingAppointmentCard(booking: booking);
              },
            ),
          );
  }
}

class CompletedAppointments extends StatelessWidget {
  final List<Booking> bookings;

  const CompletedAppointments({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    return bookings.isEmpty
        ? Center(
            child: Text(
              'No Completed Appointments',
              style: GoogleFonts.nunitoSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return CompletedAppointmentCard(booking: booking);
              },
            ),
          );
  }
}
