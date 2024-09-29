import 'package:bottom_bar/bottom_bar.dart';
import 'package:docdial/doctor/doctor_appointment_page.dart';
import 'package:docdial/screens/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:docdial/doctor/doctor_chatlist_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'doctor_profile.dart';
import 'doctor_home_page.dart';

class DoctorNavigationPage extends StatefulWidget {
  const DoctorNavigationPage({super.key});

  @override
  State<DoctorNavigationPage> createState() => _DoctorNavigationPageState();
}

class _DoctorNavigationPageState extends State<DoctorNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Global.initializeUser();
  }

  final List<Widget> _children = [
    const DoctorHomePage(),
    const DoctorAppointmentPage(),
    const DoctorChatlistPage(),
    const DoctorProfile(),
  ];

  void _onItmTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWilPop() async {
    return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit the app?'),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.green),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      SystemNavigator.pop();
                    },
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.green),
                    )),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWilPop,
      child: Scaffold(
        body: _children.elementAt(_selectedIndex),
        bottomNavigationBar: BottomBar(
          backgroundColor: Colors.grey.shade200,
          items: <BottomBarItem>[
            BottomBarItem(
              icon: const Icon(Iconsax.home),
              title: Text(
                'Home',
                style: GoogleFonts.nunitoSans(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              activeColor: Colors.green,
            ),
            BottomBarItem(
              icon: const Icon(Iconsax.calendar_tick),
              title: Text(
                'Appointments',
                style: GoogleFonts.nunitoSans(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              activeColor: Colors.green,
            ),
            BottomBarItem(
              icon: const Icon(Iconsax.message),
              title: Text(
                'Chats',
                style: GoogleFonts.nunitoSans(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              activeColor: Colors.green,
            ),
            BottomBarItem(
              icon: const Icon(Iconsax.user),
              title: Text(
                'Profile',
                style: GoogleFonts.nunitoSans(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
              activeColor: Colors.green,
            ),
          ],
          onTap: _onItmTapped,
          selectedIndex: _selectedIndex,
        ),
      ),
    );
  }
}
