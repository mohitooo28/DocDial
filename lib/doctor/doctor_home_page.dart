// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:docdial/screens/chat_screen.dart';
import 'package:docdial/doctor/widget/appointment_request_card.dart';
import 'package:docdial/doctor/widget/upcoming_appointment_card.dart';
import 'package:docdial/screens/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';
import 'package:svg_flutter/svg_flutter.dart';
import 'model/booking.dart';

class DoctorHomePage extends StatefulWidget {
  const DoctorHomePage({super.key});

  @override
  State<DoctorHomePage> createState() => _DoctorHomePageState();
}

class _DoctorHomePageState extends State<DoctorHomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Booking> _bookings = [];
  bool _isLoading = true;
  // late String doctorId;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    _upcomingAppointments();
    // doctorId = _auth.currentUser?.uid ?? '';
  }

  Future<void> _fetchBookings() async {
    String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Appointments')
          .where('receiver', isEqualTo: currentUserId)
          .get();

      _bookings.clear();
      for (var doc in snapshot.docs) {
        Booking booking = Booking.fromMap(doc.data() as Map<String, dynamic>);
        _bookings.add(booking);

        if (booking.status == 'Booked') {
          final bookingDateTime = _parseDateTime(booking.date, booking.time);
          if (DateTime.now().isAfter(bookingDateTime)) {
            _updateRequestStatus(
                booking.id, "Completed", booking.date, booking.time);
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _parseDateTime(String date, String time) {
    final dateParts = date.split('/');
    final timeParts = time.split(' ');

    int hour = 0;
    int minute = 0;
    bool isPM = false;

    if (timeParts.length == 2) {
      final timeComponents = timeParts[0].split(':');
      hour = int.parse(timeComponents[0]);
      minute = int.parse(timeComponents[1]);
      isPM = timeParts[1].toUpperCase() == 'PM';
      if (hour == 12) {
        hour = isPM ? 12 : 0;
      } else {
        hour = isPM ? hour + 12 : hour;
      }
    } else {
      final timeComponents = timeParts[0].split(':');
      hour = int.parse(timeComponents[0]);
      minute = int.parse(timeComponents[1]);
    }

    return DateTime(
      int.parse(dateParts[2]),
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      hour,
      minute,
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchBookings();
  }

  Future<void> _updateRequestStatus(
      String requestId, String status, String date, String time) async {
    String? currentUserId = _auth.currentUser?.uid;

    if (status == 'Rejected') {
      // Get the date key for the booking
      String dateKey =
          DateFormat('d').format(DateFormat('MM/dd/yyyy').parse(date));

      // Update the booking status to "Empty"
      await FirebaseFirestore.instance
          .collection('Bookings')
          .doc(currentUserId)
          .collection('dates')
          .doc(dateKey)
          .update({
        time: 'Empty',
      });

      // Delete the booking if the status is 'Rejected'
      await FirebaseFirestore.instance
          .collection('Appointments')
          .doc(requestId)
          .delete();
    } else {
      // Update the status for accepted or completed requests
      await FirebaseFirestore.instance
          .collection('Appointments')
          .doc(requestId)
          .update({
        'status': status,
      });

      if (status == 'Booked') {
        // Update the corresponding booking slot's status to "Reserved"
        await _updateBookingSlotStatus(currentUserId!, date, time, 'Booked');
      }
    }

    await _fetchBookings();
  }

  Future<void> _updateBookingSlotStatus(
      String doctorId, String date, String time, String status) async {
    String dateKey = DateFormat('d').format(DateFormat('MM/dd/yyyy')
        .parse(date)); // Convert date to match the Firestore date key format

    await FirebaseFirestore.instance
        .collection('Bookings')
        .doc(doctorId)
        .collection('dates')
        .doc(dateKey)
        .update({
      time: status,
    });
  }

  List<Booking> _pendingBookings() {
    return _bookings.where((booking) => booking.status == 'Pending').toList();
  }

  List<Booking> _upcomingAppointments() {
    DateTime parseDateTime(String date, String time) {
      final dateParts = date.split('/');
      final timeParts = time.split(' ');

      int hour = 0;
      int minute = 0;
      bool isPM = false;

      if (timeParts.length == 2) {
        // Time is in 12-hour format
        final timeComponents = timeParts[0].split(':');
        hour = int.parse(timeComponents[0]);
        minute = int.parse(timeComponents[1]);
        isPM = timeParts[1].toUpperCase() == 'PM';
        if (hour == 12) {
          hour = isPM ? 12 : 0;
        } else {
          hour = isPM ? hour + 12 : hour;
        }
      } else {
        // Time is in 24-hour format
        final timeComponents = timeParts[0].split(':');
        hour = int.parse(timeComponents[0]);
        minute = int.parse(timeComponents[1]);
      }

      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        hour,
        minute,
      );
    }

    final acceptedBookings =
        _bookings.where((booking) => booking.status == 'Booked').toList();

    acceptedBookings.sort((a, b) {
      final aDateTime = parseDateTime(a.date, a.time);
      final bDateTime = parseDateTime(b.date, b.time);
      return aDateTime.compareTo(bDateTime);
    });

    return acceptedBookings;
  }

  @override
  Widget build(BuildContext context) {
    final currentHour = DateTime.now().hour;

    String greeting;
    if (currentHour < 12) {
      greeting = 'Good Morning';
    } else if (currentHour < 18) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? const CustomCircularLoading()
            : SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //! Header -----------------------------------------------
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xFF909090),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                "Dr. ${Global.username}", // Display the doctor's full name here
                                style: GoogleFonts.montserratAlternates(
                                  color: const Color(0xFF067B15),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
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
                                        _pendingBookings().length.toString(),
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

                      //* Swipe Cards ------------------------------------------
                      SizedBox(
                        height: 320,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                              10), // Optional: Add rounded corners
                          child: StackedCardCarousel(
                            type: StackedCardCarouselType.cardsStack,
                            items: _pendingBookings().isNotEmpty
                                ? _pendingBookings()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                    int index = entry.key;
                                    Booking booking = entry.value;

                                    double interpolationFactor =
                                        1 - (index * 0.1);

                                    Color backgroundColor = Color.lerp(
                                      Colors.black,
                                      const Color(0xFF40B44F),
                                      interpolationFactor.clamp(0, 2),
                                    )!;

                                    return AppointmentRequestCard(
                                      date: booking.date,
                                      time: booking.time,
                                      username: booking.name,
                                      profileImageUrl: booking.profilePhoto,
                                      description: booking.description,
                                      bgColor:
                                          backgroundColor, // Pass the background color
                                      onAccept: () {
                                        HapticFeedback.heavyImpact();
                                        _updateRequestStatus(
                                            booking.id,
                                            "Booked",
                                            booking.date,
                                            booking.time);
                                      },
                                      onDecline: () {
                                        HapticFeedback.heavyImpact();
                                        _updateRequestStatus(
                                            booking.id,
                                            "Rejected",
                                            booking.date,
                                            booking.time);
                                      },
                                      msg: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              doctorId: booking.receiver,
                                              patientId: booking.sender,
                                              patientName: booking.name,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList()
                                : [
                                    Center(
                                      child: Column(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/vector/empty.svg",
                                            height: 235,
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "No Appointment Request Yet",
                                            style: GoogleFonts
                                                .montserratAlternates(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                          ),
                        ),
                      ),

                      //! Upcoming Appointments List ---------------------------
                      const SizedBox(height: 30),
                      Text(
                        "Upcoming Appointments",
                        style: GoogleFonts.nunitoSans(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _upcomingAppointments().length,
                          itemBuilder: (context, index) {
                            final booking = _upcomingAppointments()[index];
                            return UpcomingAppointmentCard(
                              date: booking.date,
                              time: booking.time,
                              username: booking.name,
                              profileImageUrl: booking.profilePhoto,
                              onCancel: () {
                                HapticFeedback.heavyImpact();
                                _updateRequestStatus(booking.id, "Accepted",
                                    booking.date, booking.time);
                              },
                              msg: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      doctorId: booking.receiver,
                                      patientId: booking.sender,
                                      patientName: booking.name,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      //!-------------------------------------------------------
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
