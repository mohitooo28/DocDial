// ignore_for_file: library_private_types_in_public_api
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/doctor/model/time_info.dart';
import 'package:docdial/doctor/widget/time_container_vertical.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class DoctorAppointmentPage extends StatefulWidget {
  const DoctorAppointmentPage({super.key});

  @override
  _DoctorAppointmentPageState createState() => _DoctorAppointmentPageState();
}

class _DoctorAppointmentPageState extends State<DoctorAppointmentPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _selectedTime = "";
  List<Map<String, String>> availableTimeSlots = [];

  bool _isButtonEnabled = false;

  void _handleTimeSelected(String time) {
    setState(() {
      _selectedTime = time;
      _isButtonEnabled = time.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTimeSlots();
  }

  void _fetchTimeSlots() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    String doctorId = currentUser.uid;

    DateTime now = DateTime.now();
    String dateKey = DateFormat('d').format(now);

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
          availableTimeSlots.clear();

          List<Map<String, dynamic>> timeSlotsList = [];

          slots.forEach((timeString, status) {
            if (timeString != 'openingTime' && timeString != 'closingTime') {
              DateTime? parsedTime = _parseTimeForSelectedDate(timeString);

              if (parsedTime != null) {
                if (parsedTime.isAfter(now)) {
                  timeSlotsList.add({
                    'time': timeString,
                    'status': status ?? 'Empty',
                    'parsedTime': parsedTime,
                  });
                }
              }
            }
          });

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

  DateTime? _parseTimeForSelectedDate(String timeString) {
    try {
      DateTime timePart = DateFormat('h:mm a').parse(timeString, true);
      DateTime now = DateTime.now();
      return DateTime(
        now.year,
        now.month,
        now.day,
        timePart.hour,
        timePart.minute,
      );
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  Future<void> _bookTimeSlot() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null || _selectedTime.isEmpty) return;
    String doctorId = currentUser.uid;

    DateTime now = DateTime.now();
    String dateKey = DateFormat('d').format(now);

    try {
      await _firestore
          .collection('Bookings')
          .doc(doctorId)
          .collection('dates')
          .doc(dateKey)
          .update({
        _selectedTime: 'Booked',
      });

      QuickAlert.show(
        context: context,
        type: QuickAlertType.success,
        confirmBtnColor: Colors.green,
        text: formatTimeSlot(_selectedTime),
      );

      setState(() {
        _selectedTime = "";
        _isButtonEnabled = false;
      });

      _fetchTimeSlots();
    } catch (e) {
      print("Error updating time slot: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking time slot: $e')),
      );
    }
  }

  Future<void> _bookAllTimeSlotsForToday() async {
    // Get current doctor's UID
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    String doctorId = currentUser.uid;

    // Get today's date in 'd' format (e.g., '29')
    DateTime now = DateTime.now();
    String dateKey = DateFormat('d').format(now);

    try {
      // Fetch the document for today's date
      DocumentSnapshot dateDoc = await _firestore
          .collection('Bookings')
          .doc(doctorId)
          .collection('dates')
          .doc(dateKey)
          .get();

      if (dateDoc.exists) {
        Map<String, dynamic>? slots = dateDoc.data() as Map<String, dynamic>?;

        if (slots != null) {
          // Prepare the map to update all time slots to "Booked"
          Map<String, dynamic> updatedSlots = {};

          // Iterate over all slots and change their status to "Booked"
          slots.forEach((timeString, status) {
            if (timeString != 'openingTime' && timeString != 'closingTime') {
              updatedSlots[timeString] = 'Booked';
            }
          });

          // Update Firestore document with all time slots booked
          await _firestore
              .collection('Bookings')
              .doc(doctorId)
              .collection('dates')
              .doc(dateKey)
              .update(updatedSlots);
        }
      }
    } catch (e) {
      print("Error updating time slots: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking all time slots: $e')),
      );
    }
  }

  String formatTimeSlot(String selectedTime) {
    final timeParts = selectedTime.split(' ');
    final time = timeParts[0].split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);

    int nextHour = hour;
    int nextMinute = minute + 30;

    if (nextMinute >= 60) {
      nextMinute = 0;
      nextHour = (nextHour + 1) % 12;
    }

    final formattedNextTime =
        '${nextHour.toString().padLeft(2, '0')}:${nextMinute.toString().padLeft(2, '0')} ${timeParts[1]}';

    return 'The Time Slot of $selectedTime to $formattedNextTime has been booked successfully for your Offline Appointment!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  children: [
                    Text(
                      "Your Time Slots for Today",
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
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(width: 30),
                          for (var slot in availableTimeSlots)
                            TimeContainerVertical(
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
              const Spacer(), // Push the button to the bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: InkWell(
                  onTap: _isButtonEnabled ? _bookTimeSlot : null,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        color: _isButtonEnabled
                            ? const Color(0xFF40B44F)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        'BOOK FOR OFFLINE',
                        style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: InkWell(
                  onTap: () {
                    QuickAlert.show(
                      context: context,
                      type: QuickAlertType.confirm,
                      text:
                          'Once you click \"YES\", no patients will be able to book online appointments for today. This decision cannot be reverted. Please confirm your action.',
                      confirmBtnText: 'Yes',
                      cancelBtnText: 'No',
                      confirmBtnColor: const Color(0xFF40B44F),
                      onCancelBtnTap: () => Navigator.of(context).pop(),
                      onConfirmBtnTap: () async {
                        Navigator.of(context).pop();
                        await _bookAllTimeSlotsForToday();

                        await Future.delayed(const Duration(seconds: 1));
                        QuickAlert.show(
                          context: context,
                          type: QuickAlertType.success,
                          confirmBtnColor: Colors.green,
                          text:
                              "All time slots have been marked as booked, and no patients can schedule appointments today. Enjoy your leave! This will not affect your statistics in any way.",
                        );

                        _fetchTimeSlots();
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF40B44F), width: 1.5),
                        borderRadius: BorderRadius.circular(8)),
                    child: Center(
                      child: Text(
                        'MARK LEAVE FOR TODAY',
                        style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: const Color(0xFF40B44F),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
