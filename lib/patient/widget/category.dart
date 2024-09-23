import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class CategoryButton extends StatelessWidget {
  final Color bgColor;
  final String assetLoc;
  final VoidCallback onTap;

  // ignore: use_super_parameters
  const CategoryButton({
    Key? key,
    required this.bgColor,
    required this.onTap,
    required this.assetLoc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 15),
        child: Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
              color: bgColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
            child: SvgPicture.asset(
              assetLoc,
              color: bgColor,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
