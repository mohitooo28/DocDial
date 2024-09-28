import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButtons extends StatelessWidget {
  final VoidCallback onTap;
  final IconData iconData;
  final String description;

  const CustomButtons({
    super.key,
    required this.onTap,
    required this.iconData,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade300),
            child: Center(
              child: Icon(
                iconData,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            description,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
