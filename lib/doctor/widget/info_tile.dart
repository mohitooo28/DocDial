import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoTile extends StatelessWidget {
  final IconData iconData;
  final String info;
  final String output;

  const InfoTile({
    super.key,
    required this.iconData,
    required this.info,
    required this.output,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Icon(iconData, size: 20, color: Colors.green),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info,
              style: GoogleFonts.nunitoSans(
                color: Colors.black.withOpacity(0.6),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              output,
              style: GoogleFonts.nunitoSans(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
