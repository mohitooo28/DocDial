import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class DropdownInput extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final bool isVisible;
  final IconData iconData;
  final FocusNode currFocusNode;
  final FocusNode nextFocusNode;

  const DropdownInput({
    super.key,
    required this.hintText,
    required this.controller,
    required this.options,
    required this.onChanged,
    required this.isVisible,
    required this.iconData,
    required this.currFocusNode,
    required this.nextFocusNode,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DropdownInputState createState() => _DropdownInputState();
}

class _DropdownInputState extends State<DropdownInput> {
  String? selectedOption;

  void _showCustomMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomLeft(Offset.zero),
            ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      items: widget.options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
          )
          .toList(),
    );

    if (selected != null) {
      setState(() {
        selectedOption = selected;
        widget.controller.text = selected;
      });
      widget.onChanged(selected);
    }

    // Move focus to the next node when selection is done
    widget.currFocusNode.unfocus();
    FocusScope.of(context).requestFocus(widget.nextFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.isVisible,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FormField<String>(
          validator: (value) {
            if (selectedOption == null) {
              return "Please Select Your ${widget.hintText}";
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            return Stack(
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
                  child: InkWell(
                    focusNode: widget.currFocusNode,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    enableFeedback: false,
                    onTap: () => _showCustomMenu(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        errorStyle: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF40B44F),
                        ),
                        errorText: state.errorText,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                        prefixIcon: Icon(
                          widget.iconData,
                          color: const Color(0xFF043A50),
                          size: 23,
                        ),
                        hintText: selectedOption ?? widget.hintText,
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedOption ?? widget.hintText,
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: selectedOption == null
                                  ? const Color(0xFF8391A1)
                                  : Colors.black,
                            ),
                          ),
                          const Icon(
                            Iconsax.arrow_bottom,
                            color: Color(0xFF8391A1),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
