import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeInfo extends StatelessWidget {
  const TimeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TimeContainerShow(Colors.grey[800]!, Colors.white, "Booked"),
          TimeContainerShow(Colors.amber, Colors.white, "Requested"),
          TimeContainerShow(
              Colors.grey[200]!, Colors.grey.shade600, "Available"),
          TimeContainerShow(Colors.green, Colors.white, "Selected "),
        ],
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Row TimeContainerShow(Color bgColor, Color textColor, String info) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 98,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            child: Center(
              child: Text(
                "12:00 PM",
                style: GoogleFonts.nunitoSans(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          info,
          style: GoogleFonts.nunitoSans(
            color:
                (bgColor == Colors.grey[200]!) ? Colors.grey.shade600 : bgColor,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
