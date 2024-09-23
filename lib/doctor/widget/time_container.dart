import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeContainer extends StatelessWidget {
  final String time;
  final String status;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeContainer({
    Key? key,
    required this.time,
    required this.status,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  Color _getBackgroundColor() {
    if (status == "Booked") {
      return Colors.grey[800]!;
    } else if (status == "Completed") {
      return Colors.grey;
    } else if (status == "Pending") {
      return Colors.amber;
    } else if (isSelected) {
      return Colors.green;
    } else {
      return Colors.grey[200]!;
    }
  }

  Color _getTextColor() {
    if (status == "Booked" || status == "Completed") {
      return Colors.white;
    } else if (status == "Pending") {
      return Colors.white;
    } else if (isSelected) {
      return Colors.white;
    } else {
      return Colors.grey.shade600;
    }
  }

  bool _isClickable() {
    return status == "Empty";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: _isClickable() ? onTap : null, // Disable tap if not clickable
        child: Container(
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            child: Center(
              child: Text(
                time,
                style: GoogleFonts.nunitoSans(
                  color: _getTextColor(),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
