import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.textController,
    required this.currFocusNode,
    required this.nextFocusNode,
    required this.isVisible,
    required this.hintText,
    required this.openTime,
  });

  final TextEditingController textController;
  final String hintText;
  final FocusNode currFocusNode;
  final FocusNode nextFocusNode;
  final bool isVisible;
  final bool openTime;

  // Function to open the time picker and restrict time selection to half-hour intervals
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: (openTime)
          ? const TimeOfDay(hour: 10, minute: 00)
          : const TimeOfDay(hour: 17, minute: 00),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final DateTime now = DateTime.now();

      // Round minutes to the nearest half-hour interval (0 or 30)
      int roundedMinutes = pickedTime.minute;
      if (roundedMinutes < 15) {
        roundedMinutes = 0; // Round down to the full hour
      } else if (roundedMinutes < 45) {
        roundedMinutes = 30; // Round to half-hour
      } else {
        roundedMinutes = 0; // Round up to the next hour
      }

      // Calculate new hour if rounding up from minutes >= 45
      int adjustedHour = pickedTime.hour;
      if (pickedTime.minute >= 45) {
        adjustedHour = (pickedTime.hour + 1) % 24; // Move to next hour
      }

      final DateTime selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        adjustedHour,
        roundedMinutes,
      );

      // Format time as 'h:mm a' (e.g., '9:00 AM')
      final String formattedTime = DateFormat('h:mm a').format(selectedTime);
      textController.text = formattedTime;
    }
  }

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
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: TextFormField(
                controller: textController,
                focusNode: currFocusNode,
                cursorColor: const Color(0xFF40B44F),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Choose Your $hintText";
                  }
                  return null;
                },
                onFieldSubmitted: (value) {
                  currFocusNode.unfocus();
                  FocusScope.of(context).requestFocus(nextFocusNode);
                },
                readOnly: true,
                onTap: () => _selectTime(context), // Open time picker on tap
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
                  prefixIcon: Icon(
                    (openTime) ? Iconsax.timer_start : Iconsax.timer_pause,
                    color: const Color(0xFF043A50),
                    size: 25,
                  ),
                  hintText: hintText,
                  hintStyle: GoogleFonts.montserrat(
                    fontSize: 15,
                    color: const Color(0xFF8391A1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14), // Adjust padding
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
