import 'package:flutter/material.dart';

class CustomCircularLoading extends StatelessWidget {
  const CustomCircularLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 30.0,
        height: 30.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF40B44F)),
        ),
      ),
    );
  }
}
