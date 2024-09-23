import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.emailController,
    required this.emailFocusNode,
    required this.nextFocusNode,
  });

  final TextEditingController emailController;
  final FocusNode emailFocusNode;
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
              controller: emailController,
              focusNode: emailFocusNode,
              cursorColor: const Color(0xFF40B44F),
              validator: (value) {
                bool isEmailValid =
                    RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$')
                        .hasMatch(value!);
                if (value.isEmpty) {
                  return "Please Enter Your Email ID";
                } else if (!isEmailValid) {
                  return "Please Enter Valid Email ID";
                }
                return null;
              },
              onFieldSubmitted: (value) {
                emailFocusNode.unfocus();
                FocusScope.of(context).requestFocus(nextFocusNode);
              },
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
                  Iconsax.sms4,
                  color: Color(0xFF043A50),
                  size: 23,
                ),
                hintText: 'Email',
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
