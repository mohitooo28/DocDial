// ignore_for_file: library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/doctor/widget/time_container.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DoctorAppointmentPage extends StatefulWidget {
  const DoctorAppointmentPage({super.key});

  @override
  _DoctorAppointmentPageState createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DateTime _selectedDate = DateTime.now();

  late String _selectedTime = "";
  late String uid;

  List<Map<String, String>> availableTimeSlots = [];
  void _handleTimeSelected(String time) {
    setState(() {
      _selectedTime = time;
    });
  }

  Future<DocumentSnapshot> fetchDoctorDetails() async {
    // Get current user's UID
    User? user = _auth.currentUser;
    if (user != null) {
      uid = _firestore.collection('Doctors').doc(user.uid).get().toString();
      return await _firestore.collection('Doctors').doc(user.uid).get();
    } else {
      throw Exception("No user logged in");
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
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              availableTimeSlots.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "All Appointments are Completed for Today",
                        style: GoogleFonts.nunitoSans(
                          color: const Color(0xFF8391A1),
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 30),
                          for (var slot in availableTimeSlots)
                            TimeContainer(
                              time: slot['time'] ?? 'N/A',
                              status: slot['status'] ?? 'Empty',
                              isSelected: _selectedTime == (slot['time'] ?? ''),
                              onTap: () =>
                                  _handleTimeSelected(slot['time'] ?? ''),
                            ),
                          const SizedBox(width: 15),
                        ],
                      ),
                    ),
            ],
          ),

          // Display message if no slots available, otherwise show time slots
        ),
      ),
    );
  }

  void _fetchTimeSlots() async {
    String dateKey = DateFormat('d').format(_selectedDate);
    String doctorId = uid;

    try {
      DocumentSnapshot dateDoc = await _firestore
          .collection('Bookings')
          .doc(doctorId)
          .collection('dates')
          .doc(dateKey)
          .get();

      if (dateDoc.exists) {
        Map<String, dynamic>? slots = dateDoc.data() as Map<String, dynamic>?;

        if (slots != null) {
          // Clear previous slots
          availableTimeSlots.clear();

          // Get current date and time
          DateTime now = DateTime.now();

          List<Map<String, dynamic>> timeSlotsList = [];

          // Iterate over all the time slots
          slots.forEach((timeString, status) {
            if (timeString != 'openingTime' && timeString != 'closingTime') {
              // Parse time with selected date to get full DateTime object
              DateTime? parsedTime = _parseTimeForSelectedDate(timeString);

              if (parsedTime != null) {
                if (_selectedDate.day == now.day &&
                    _selectedDate.month == now.month &&
                    _selectedDate.year == now.year) {
                  // Only show future times for today
                  if (parsedTime.isAfter(now)) {
                    timeSlotsList.add({
                      'time': timeString,
                      'status': status ?? 'Empty',
                      'parsedTime': parsedTime,
                    });
                  }
                } else {
                  // Add all time slots for future dates
                  timeSlotsList.add({
                    'time': timeString,
                    'status': status ?? 'Empty',
                    'parsedTime': parsedTime,
                  });
                }
              }
            }
          });

          // Sort by time
          timeSlotsList
              .sort((a, b) => a['parsedTime'].compareTo(b['parsedTime']));

          availableTimeSlots.addAll(timeSlotsList.map((e) => {
                'time': e['time'],
                'status': e['status'],
              }));

          setState(() {});
        }
      }
    } catch (e) {
      print("Error fetching time slots: $e");
    }
  }

// Helper function to parse time for the selected date
  DateTime? _parseTimeForSelectedDate(String timeString) {
    try {
      // Parse only the time part from the time string
      DateTime timePart = DateFormat('h:mm a').parse(timeString, true);

      // Combine it with the selected date
      return DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        timePart.hour,
        timePart.minute,
      );
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }
}
