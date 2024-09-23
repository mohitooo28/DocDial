import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class PhoneTextField extends StatelessWidget {
  const PhoneTextField({
    super.key,
    required this.phoneController,
    required this.currFocusNode,
    required this.nextFocusNode,
  });

  final TextEditingController phoneController;
  final FocusNode currFocusNode;
  final FocusNode nextFocusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Container(
              height: 55,
              decoration: BoxDecoration(
                  color: const Color(0xFFC4C4C4).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8))),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: TextFormField(
              controller: phoneController,
              focusNode: currFocusNode,
              cursorColor: const Color(0xFF40B44F),
              maxLength: 10,
              keyboardType: TextInputType.number,
              validator: (value) {
                bool isEmailValid = RegExp(r'^[6-9]\d{9}$').hasMatch(value!);
                if (value.isEmpty) {
                  return "Please Enter Your Phone Number";
                } else if (!isEmailValid) {
                  return "Please Enter Valid Phone Number";
                }
                return null;
              },
              onFieldSubmitted: (value) {
                currFocusNode.unfocus();
                FocusScope.of(context).requestFocus(nextFocusNode);
              },
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                counter: const Offstage(),
                errorStyle: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF40B44F),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: InputBorder.none,
                prefixIcon: const Icon(
                  Iconsax.call,
                  color: Color(0xFF043A50),
                  size: 23,
                ),
                hintText: 'Phone Number',
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
    );
  }
}
