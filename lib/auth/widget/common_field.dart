import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommonTextField extends StatelessWidget {
  const CommonTextField({
    super.key,
    required this.textController,
    required this.currFocusNode,
    required this.nextFocusNode,
    required this.iconData,
    required this.hintText,
    required this.isVisible,
  });

  final TextEditingController textController;
  final String hintText;
  final FocusNode currFocusNode;
  final FocusNode nextFocusNode;
  final IconData iconData;
  final bool isVisible;

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
                    borderRadius: BorderRadius.circular(8))),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: TextFormField(
                controller: textController,
                focusNode: currFocusNode,
                cursorColor: const Color(0xFF40B44F),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please Enter Your $hintText";
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
                  errorStyle: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF40B44F),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    iconData,
                    color: const Color(0xFF043A50),
                    size: 23,
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
