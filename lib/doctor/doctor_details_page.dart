// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/doctor/model/time_info.dart';
import 'package:docdial/doctor/widget/info_tile.dart';
import 'package:docdial/doctor/widget/map_container.dart';
import 'package:docdial/doctor/widget/time_container.dart';
import 'package:docdial/screens/chat_screen.dart';
import 'package:docdial/screens/global.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/doctor.dart';

class DoctorDetailPage extends StatefulWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _descriptionController = TextEditingController();
  final shakeKey = GlobalKey<ShakeWidgetState>();
  DateTime? _selectedDate;
  late String _selectedTime = "";
  double rating = 0.0;
  bool _hasText = false;
  var maxLength = 70;
  var textLength = 0;

  List<Map<String, String>> availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      if (_descriptionController.text.isNotEmpty != _hasText) {
        setState(() {
          _hasText = _descriptionController.text.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }

  void _handleTimeSelected(String time) {
    setState(() {
      _selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //==============================================================
                //! AppBar -----------------------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 30, height: 65),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                    const SizedBox(
                        width: 10), // Add some space between icon and title
                    Expanded(
                      child: Center(
                        child: Text(
                          "Doctor Details",
                          style: GoogleFonts.nunitoSans(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        width: 30), // Add space after title if needed
                  ],
                ),

                //! Doctor Main Detail -----------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 25, 30, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //* Image & Call - Message Button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      widget.doctor.profileImageUrl),
                                  fit: BoxFit.cover,
                                )),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _makePhoneCall(widget.doctor.phoneNumber),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Center(
                                    child: Icon(
                                      Iconsax.call,
                                      color: Colors.white,
                                      size: 23,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  // Add chat functionality
                                  String currentUserId = _auth.currentUser!.uid;
                                  String docName =
                                      '${widget.doctor.firstName.toString()} ${widget.doctor.lastName.toString()}';

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        doctorId: widget.doctor.uid,
                                        doctorName: docName,
                                        patientId: currentUserId,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 115,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        // const SizedBox(width: 8),
                                        const Icon(
                                          Iconsax.message,
                                          color: Colors.white,
                                          size: 23,
                                        ),
                                        // const SizedBox(width: 8),
                                        Text(
                                          "Message",
                                          style: GoogleFonts.nunitoSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        // const SizedBox(width: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //* Name
                          Text(
                            "Dr. ${widget.doctor.firstName} ${widget.doctor.lastName}",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.clip,
                          ),
                          //* Category
                          Text(
                            widget.doctor.category,
                            style: GoogleFonts.nunitoSans(
                              color: Colors.black.withOpacity(0.6),
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                            ),
                          ),
                          //* Gender & Qualification
                          Row(
                            children: [
                              (widget.doctor.gender == "Male")
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
                                widget.doctor.qualification,
                                style: GoogleFonts.nunitoSans(
                                  color: Colors.black.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          //* City
                          const SizedBox(height: 3),
                          InfoTile(
                            iconData: Iconsax.location,
                            info: 'City',
                            output: widget.doctor.city,
                          ),
                          //* Experience
                          const SizedBox(height: 4),
                          InfoTile(
                            iconData: Iconsax.timer,
                            info: 'Experience',
                            output: widget.doctor.yearsOfExperience,
                          ),
                          //* Rating
                          const SizedBox(height: 4),
                          InfoTile(
                            iconData: Iconsax.star,
                            info: 'Rating',
                            output: (widget.doctor.averageRating).toString(),
                          ),
                          //* --------------------------------------------------
                        ],
                      )
                    ],
                  ),
                ),

                //! Location Showcase ------------------------------------------
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Location",
                    style: GoogleFonts.nunitoSans(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: MapContainer(
                    latitude: widget.doctor.latitude,
                    longitude: widget.doctor.longitude,
                  ),
                ),

                //! Dates ------------------------------------------------------
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Schedule",
                    style: GoogleFonts.nunitoSans(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 10, 0, 30),
                  child: EasyDateTimeLine(
                    initialDate: DateTime.now(),

                    onDateChange: (selectedDate) {
                      _selectedDate = selectedDate;
                      _fetchTimeSlots();
                      _selectedTime = "";
                    },
                    activeColor: const Color(0xFF40B44F),

                    // Pass empty headerProps to remove the header
                    headerProps: const EasyHeaderProps(
                      showHeader: false, // Hide the header
                    ),
                    dayProps: const EasyDayProps(
                      activeDayStyle: DayStyle(
                        borderRadius: 32.0,
                        dayNumStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      activeMothStrStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      activeDayStrStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      inactiveDayStyle: DayStyle(
                        borderRadius: 32.0,
                      ),
                    ),
                    disabledDates: [
                      ...List.generate(
                        DateTime.now().difference(DateTime(2020, 1, 1)).inDays,
                        (index) =>
                            DateTime(2020, 1, 1).add(Duration(days: index)),
                      ).where((date) => date.isBefore(DateTime.now())),
                      ...List.generate(
                        365,
                        (index) =>
                            DateTime.now().add(Duration(days: 3 + index)),
                      ),
                      // Disable future dates that fall on the doctor's off day
                      ...List.generate(
                        365,
                        (index) {
                          final date =
                              DateTime.now().add(Duration(days: index));
                          return date.weekday ==
                                  _getWeekdayFromOffDay(widget.doctor.offDay)
                              ? date
                              : null;
                        },
                      ).whereType<DateTime>(),
                    ],
                    timeLineProps: const EasyTimeLineProps(
                      hPadding: 16.0,
                      separatorPadding: 16.0,
                    ),
                  ),
                ),

                //! Time -------------------------------------------------------
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Text(
                        "Choose Time",
                        style: GoogleFonts.nunitoSans(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () => showPopover(
                                context: context,
                                bodyBuilder: (context) => const TimeInfo(),
                                direction: PopoverDirection.left,
                                width: 230,
                                height: 190,
                                arrowWidth: 25,
                                arrowHeight: 12),
                            child: const Icon(
                              Iconsax.info_circle,
                              color: Color(0xFF8391A1),
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Display message if no slots available, otherwise show time slots
                _selectedDate != null && availableTimeSlots.isEmpty
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
                            if (_selectedDate == null)
                              Text(
                                'Please select a date first',
                                style: GoogleFonts.nunitoSans(
                                  color: const Color(0xFF8391A1),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              )
                            else
                              for (var slot in availableTimeSlots)
                                TimeContainer(
                                  time: slot['time'] ?? 'N/A',
                                  status: slot['status'] ?? 'Empty',
                                  isSelected:
                                      _selectedTime == (slot['time'] ?? ''),
                                  onTap: () =>
                                      _handleTimeSelected(slot['time'] ?? ''),
                                ),
                            const SizedBox(width: 15),
                          ],
                        ),
                      ),
                //! Description ------------------------------------------------
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    children: [
                      Text(
                        "Description",
                        style: GoogleFonts.nunitoSans(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (_hasText)
                        GestureDetector(
                          onTap: () {
                            _descriptionController.clear();
                            setState(() {
                              _hasText = false; // Reset the flag after clearing
                            });
                          },
                          child: const Icon(
                            Iconsax.close_circle,
                            color: Color(0xFF8391A1),
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: _descriptionController,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.black),
                        maxLines: 3,
                        maxLength: maxLength,
                        onChanged: (value) {
                          setState(() {
                            textLength = value.length;
                          });
                        },
                        decoration: InputDecoration(
                          errorStyle: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF40B44F),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                width: 1, color: Color(0xFF40B44F)),
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          hintText:
                              "Describe your symptoms or reason for the appointment",
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: const Color(0xFF8391A1),
                          ),
                          counterText: "", // Hide the default counter
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: Colors.grey.shade200,
                        ),
                      ),
                      Positioned(
                        bottom: 10, // Position the suffix at the bottom
                        right:
                            10, // Adjust according to your padding or alignment needs
                        child: Text(
                          '${textLength.toString()}/${maxLength.toString()}',
                          style: GoogleFonts.nunitoSans(
                            color: const Color(0xFF8391A1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //! Book Button ------------------------------------------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                  child: ShakeMe(
                    key: shakeKey,
                    shakeCount: 3,
                    shakeOffset: 3,
                    shakeDuration: const Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        _bookAppointment();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF40B44F), Color(0xFF109421)],
                            begin: FractionalOffset(0.0, 0.0),
                            end: FractionalOffset(1.0, 0.0),
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "BOOK APPOINTMENT",
                            style: GoogleFonts.nunitoSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                //==============================================================
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Redirect to Call Dialer Function
  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not make a call on $phoneNumber this number';
    }
  }

  // Book Appointment Function
  void _bookAppointment() {
    if (_selectedDate != null &&
        _selectedTime.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      String date = DateFormat('MM/dd/yyyy').format(_selectedDate!);
      String day = DateFormat('dd').format(_selectedDate!);
      String time = _selectedTime;
      String description = _descriptionController.text;
      String requestId = _firestore.collection('Appointments').doc().id;
      String currentUserId = _auth.currentUser!.uid;
      String receiverId = widget.doctor.uid;
      String status = 'Pending';

      // Save appointment to Firestore
      _firestore.collection('Appointments').doc(requestId).set({
        'name': Global.username,
        'profilePhoto': Global.profileImageUrl,
        'date': date,
        'time': time,
        'description': description,
        'id': requestId,
        'receiver': receiverId,
        'sender': currentUserId,
        'status': status,
        'review': "None",
      }).then((_) {
        // Update the time slot status to "Booked"
        _firestore
            .collection('Bookings')
            .doc(receiverId)
            .collection('dates')
            .doc(day)
            .update({time: 'Pending'}).then((_) {
          setState(() {
            _selectedDate = null; // Reset selection
            _selectedTime = "";
            _descriptionController.clear();
          });
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            confirmBtnColor: Colors.green,
            text:
                "Your appointment request has been sent! You'll be notified on your home page once the doctor confirms.",
          );
        });
      }).catchError((error) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          confirmBtnColor: Colors.red,
          text: "Failed to book your appointment, Try Again later!!",
        );
      });
    } else {
      shakeKey.currentState?.shake();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Select a date, time, and add a description for your appointment!')));
    }
  }

  // Fetch Time Slots
  void _fetchTimeSlots() async {
    if (_selectedDate == null) return;

    String dateKey = DateFormat('d').format(_selectedDate!);
    String doctorId = widget.doctor.uid;

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
                if (_selectedDate!.day == now.day &&
                    _selectedDate!.month == now.month &&
                    _selectedDate!.year == now.year) {
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
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        timePart.hour,
        timePart.minute,
      );
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  // Get Week Day
  int _getWeekdayFromOffDay(String offDay) {
    switch (offDay) {
      case 'Saturday':
        return DateTime.saturday;
      case 'Sunday':
        return DateTime.sunday;
      case 'Monday':
        return DateTime.monday;
      default:
        return -1; // Invalid day
    }
  }
}
