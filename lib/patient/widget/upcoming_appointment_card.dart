import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/doctor/model/booking.dart';
import 'package:docdial/doctor/model/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class UpcomingAppointmentCard extends StatefulWidget {
  final Booking booking;

  const UpcomingAppointmentCard({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  _UpcomingAppointmentCardState createState() =>
      _UpcomingAppointmentCardState();
}

class _UpcomingAppointmentCardState extends State<UpcomingAppointmentCard> {
  Map<String, dynamic>? _doctorDetails;

  Color _setIndicatorColor() {
    if (widget.booking.status == "Pending") {
      return Colors.red;
    } else if (widget.booking.status == "Booked") {
      return Colors.green;
    } else {
      return Colors.grey.shade700;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    try {
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(widget
              .booking.receiver) // Fetching using receiver ID (doctor UID)
          .get();

      if (doctorSnapshot.exists) {
        setState(() {
          _doctorDetails = doctorSnapshot.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print("Error fetching doctor details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 100,
            decoration: BoxDecoration(
              color: _setIndicatorColor(),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  // color: Colors.grey.shade100.withOpacity(0.5),
                  color: Colors.white),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (widget.booking.status == "Pending")
                          ? "Requested Appointment Date"
                          : "Appointment Date",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.clock,
                          color: Colors.black,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${formatDate(widget.booking.date)}, ",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          formatTimeRange(widget.booking.time),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                            image: _doctorDetails != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                      _doctorDetails!['profileImageUrl'],
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctorDetails != null
                                    ? "Dr. ${_doctorDetails!['firstName']} ${_doctorDetails!['lastName']}"
                                    : 'Loading...',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _doctorDetails != null
                                    ? _doctorDetails!['category']
                                    : 'Loading...',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
