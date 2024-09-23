import 'package:docdial/doctor/model/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class AppointmentRequestCard extends StatelessWidget {
  final Color bgColor;
  final String date;
  final String time;
  final String? username;
  final String profileImageUrl;
  final String description;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback msg;

  // ignore: use_super_parameters
  const AppointmentRequestCard({
    Key? key,
    required this.date,
    required this.time,
    required this.username,
    required this.description,
    required this.onAccept,
    required this.onDecline,
    required this.profileImageUrl,
    required this.bgColor, required this.msg,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              topLeft: Radius.circular(30),
            ),
            color: bgColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 18, 10, 3),
                child: Text(
                  "Appointment Request",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF).withOpacity(0.6),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25, bottom: 15),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.clock,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "${formatDate(date)}, ",
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                    Text(
                      formatTimeRange(time),
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            ),
            color: Color(0xFFEDEFFF),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                      radius: 38,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: msg,
                            child: Text(
                              username ?? "Patient Name",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            description,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 15, 10, 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 3, // 2 parts for ACCEPT button
                        child: GestureDetector(
                          onTap: onAccept,
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                "ACCEPT",
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        flex: 2, // 1 part for DECLINE button
                        child: GestureDetector(
                          onTap: onDecline,
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1D1D1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                "DECLINE",
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
