// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/doctor/model/booking.dart';
import 'package:docdial/doctor/model/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class CompletedAppointmentCard extends StatefulWidget {
  final Booking booking;

  const CompletedAppointmentCard({
    Key? key,
    required this.booking,
  }) : super(key: key);

  @override
  _CompletedAppointmentCardState createState() =>
      _CompletedAppointmentCardState();
}

class _CompletedAppointmentCardState extends State<CompletedAppointmentCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _doctorDetails;

  double rating = 0.0;

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
              color: Colors.grey.shade700,
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
                      "Appointment Date",
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
                    //*---------------------------------------------------------
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (BuildContext ctx,
                                    StateSetter stateSetter) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const SizedBox(height: 35),
                                        Text(
                                          "Leave a Review",
                                          style: GoogleFonts.nunitoSans(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Leave a rating for Dr. ${_doctorDetails!['firstName']} ${_doctorDetails!['lastName']} to share your experience from the appointment you just completed. Your feedback helps us improve and assists others in choosing the right doctor!",
                                          style: GoogleFonts.nunitoSans(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        const SizedBox(height: 15),
                                        RatingStars(
                                          axis: Axis.horizontal,
                                          value: rating,
                                          onValueChanged: (v) {
                                            stateSetter(() {
                                              rating = v;
                                            });
                                          },
                                          starCount: 5,
                                          starSize: 22,
                                          maxValue: 5,
                                          starSpacing: 2,
                                          maxValueVisibility: false,
                                          valueLabelVisibility: false,
                                          animationDuration: const Duration(
                                              milliseconds: 1000),
                                          valueLabelPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 1, horizontal: 8),
                                          valueLabelMargin:
                                              const EdgeInsets.only(right: 8),
                                          starOffColor: const Color(0xffe7e8ea),
                                          starColor: Colors.amber,
                                          angle: 0,
                                        ),
                                        const SizedBox(height: 40),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () async {
                                              DocumentReference doctorRef =
                                                  _firestore
                                                      .collection('Doctors')
                                                      .doc(widget
                                                          .booking.receiver);
                                              final snapshot =
                                                  await doctorRef.get();

                                              if (snapshot.exists) {
                                                final doctorData =
                                                    snapshot.data()
                                                        as Map<String, dynamic>;
                                                double currentAverageRating =
                                                    double.parse(doctorData[
                                                            'averageRating']
                                                        .toString());
                                                int currentTotalReviews =
                                                    int.parse(doctorData[
                                                            'totalReviews']
                                                        .toString());

                                                double newAverageRating =
                                                    ((currentAverageRating *
                                                                currentTotalReviews) +
                                                            rating) /
                                                        (currentTotalReviews +
                                                            1);
                                                int newTotalReviews =
                                                    currentTotalReviews + 1;

                                                await doctorRef.update({
                                                  'averageRating':
                                                      newAverageRating
                                                          .toStringAsFixed(1),
                                                  'totalReviews':
                                                      newTotalReviews
                                                          .toString(),
                                                });

                                                // Update local state for doctor details
                                                setState(() {
                                                  _doctorDetails![
                                                          'averageRating'] =
                                                      newAverageRating;
                                                  _doctorDetails![
                                                          'totalReviews'] =
                                                      newTotalReviews;
                                                });

                                                // Update the appointment document to set review to "Given"
                                                DocumentReference
                                                    appointmentRef = _firestore
                                                        .collection(
                                                            'Appointments')
                                                        .doc(widget.booking.id);
                                                await appointmentRef.update({
                                                  'review': "Given",
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Rating updated successfully!")),
                                                );

                                                Navigator.pop(context);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          "Doctor's data not found.")),
                                                );
                                              }
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: 45,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "REVIEW",
                                                  style: GoogleFonts.nunitoSans(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 60),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        child: Visibility(
                          visible:
                              (widget.booking.review == "None") ? true : false,
                          child: Text(
                            "Leave a Review",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    //*---------------------------------------------------------
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
