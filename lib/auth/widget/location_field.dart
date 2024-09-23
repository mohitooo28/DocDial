import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class LocationField extends StatelessWidget {
  final TextEditingController locationController;
  final VoidCallback onTap;
  final String hintText;
  final String? validationMessage;
  final bool isVisible;

  LocationField({
    required this.locationController,
    required this.onTap,
    required this.isVisible,
    this.hintText = 'Tap to get your location',
    this.validationMessage = "Please Get Your Location Here",
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Stack(
          children: [
            Container(
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFFC4C4C4).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            GestureDetector(
              onTap: onTap, // Call your function on tap
              child: AbsorbPointer(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: TextFormField(
                    controller: locationController,
                    cursorColor: const Color(0xFF40B44F),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return validationMessage;
                      }
                      return null;
                    },
                    readOnly: true,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      errorStyle: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF40B44F),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: InputBorder.none,
                      prefixIcon: const Icon(
                        Iconsax.map,
                        color: Color(0xFF043A50),
                        size: 23,
                      ),
                      hintText: hintText,
                      hintStyle: GoogleFonts.montserrat(
                        fontSize: 15,
                        color: const Color(0xFF8391A1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      isDense: true,
                    ),
                    maxLines: 1, // Limits the field to a single line
                    textAlign: TextAlign.start,
                    scrollPhysics:
                        const AlwaysScrollableScrollPhysics(), // Ensures scrolling
                    scrollPadding:
                        EdgeInsets.zero, // Prevents extra padding around scroll
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
