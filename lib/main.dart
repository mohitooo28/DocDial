import 'package:docdial/auth/service/booking_manager.dart';
import 'package:docdial/screens/global.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:docdial/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Global.initializeUser();
  await Future.delayed(const Duration(seconds: 2));
  await BookingManager().backgroundTask();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF40B44F),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: const Color(0xFF40B44F).withOpacity(.5),
          cursorColor: const Color(0xFF40B44F).withOpacity(.6),
          selectionHandleColor: const Color(0xFF40B44F).withOpacity(1),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
