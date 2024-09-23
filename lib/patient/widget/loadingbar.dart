import 'package:flutter/material.dart';

class CustomCircularLoading extends StatelessWidget {
  // ignore: use_super_parameters
  const CustomCircularLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              Color(0xFF40B44F)),
        ),
      ),
    );
  }
}
