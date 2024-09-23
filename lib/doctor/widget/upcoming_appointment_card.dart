import 'package:docdial/doctor/model/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  final String date;
  final String time;
  final String? username;
  final String profileImageUrl;
  final VoidCallback onCancel;
  final VoidCallback msg;

  // ignore: use_super_parameters
  const UpcomingAppointmentCard({
    Key? key,
    required this.date,
    required this.time,
    required this.username,
    required this.profileImageUrl, required this.onCancel, required this.msg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color(0xFFEDEFFF),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 10),
            CircleAvatar(
              backgroundImage: NetworkImage(profileImageUrl),
              radius: 20,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: msg,
                  child: Text(
                    username!,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Text(
                  "${formatDate(date)} | ${formatTimeRange(time)}, ",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.6),
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: onCancel,
              child: const Icon(
                Iconsax.close_circle,
                color: Color(0xFF8391A1),
                size: 22,
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }
}
