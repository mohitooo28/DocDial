import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    Key? key,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.nextFocusNode,
  }) : super(key: key);

  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final FocusNode nextFocusNode;

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late ValueNotifier<bool> _passwordVisibleNotifier;

  @override
  void initState() {
    super.initState();
    _passwordVisibleNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _passwordVisibleNotifier.dispose();
    super.dispose();
  }

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
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: ValueListenableBuilder<bool>(
              valueListenable: _passwordVisibleNotifier,
              builder: (context, passwordVisible, child) {
                return TextFormField(
                  controller: widget.passwordController,
                  focusNode: widget.passwordFocusNode,
                  cursorColor: const Color(0xFF40B44F),
                  obscureText: !passwordVisible,
                  maxLength: 10,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please Enter Password";
                    } else if (widget.passwordController.text.length < 6) {
                      return "Password Length Should be at least 6";
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    widget.passwordFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(widget.nextFocusNode);
                  },
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    errorStyle: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF40B44F),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    prefixIcon: const Icon(
                      Iconsax.password_check4,
                      color: Color(0xFF043A50),
                      size: 23,
                    ),
                    border: InputBorder.none,
                    hintText: 'Password',
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: 15,
                      color: const Color(0xFF8391A1),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _passwordVisibleNotifier.value =
                            !_passwordVisibleNotifier.value;
                      },
                      child: Icon(
                        passwordVisible ? Iconsax.eye_slash4 : Iconsax.eye,
                        color: const Color(0xFF8391A1),
                        size: 23,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14), // Adjust padding
                    isDense: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
