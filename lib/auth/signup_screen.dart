// ignore_for_file: avoid_print

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docdial/auth/widget/time_field.dart';
import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:docdial/screens/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:docdial/auth/login_page.dart';
import 'package:docdial/auth/service/location_service.dart';
import 'package:docdial/auth/widget/common_field.dart';
import 'package:docdial/auth/widget/dropinput_field.dart';
import 'package:docdial/auth/widget/email_field.dart';
import 'package:docdial/auth/widget/location_field.dart';
import 'package:docdial/auth/widget/password_field.dart';
import 'package:docdial/auth/widget/phone_field.dart';

import '../doctor/doctor_nav_page.dart';
import '../patient/patient_nav_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _qualificationController =
      TextEditingController();
  final TextEditingController _yoeController = TextEditingController();
  final TextEditingController _offDayController = TextEditingController();
  final TextEditingController _openingTime = TextEditingController();
  final TextEditingController _closingTime = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final LocationService _locationService = LocationService();

  FocusNode f1 = FocusNode();
  FocusNode f2 = FocusNode();
  FocusNode f3 = FocusNode();
  FocusNode f4 = FocusNode();
  FocusNode f5 = FocusNode();
  FocusNode f6 = FocusNode();
  FocusNode f7 = FocusNode();
  FocusNode f8 = FocusNode();
  FocusNode f9 = FocusNode();
  FocusNode f10 = FocusNode();
  FocusNode f11 = FocusNode();
  FocusNode f12 = FocusNode();
  FocusNode f13 = FocusNode();
  FocusNode f14 = FocusNode();

  int type = 0;
  String userType = 'Patient';
  String profileImageUrl = '';
  String userLocation = '';
  double latitude = 0.0;
  double longitude = 0.0;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  bool _isPhotoUploaded = false;

  final Location _location = Location();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const CustomCircularLoading()
          : SafeArea(
              child: GestureDetector(
                onTap: FocusScope.of(context).unfocus,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //*-----------------------------------------------------
                        const SizedBox(height: 15),
                        Text(
                          'Register',
                          style: GoogleFonts.museoModerno(
                              color: const Color(0xFF19244D),
                              fontSize: 28,
                              fontWeight: FontWeight.w600),
                        ),
                        //*-----------------------------------------------------
                        const SizedBox(height: 5),
                        Text(
                          'Welcome to DocDial',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                        //*-----------------------------------------------------
                        Text(
                          'Hope so you are doing all well & good :D',
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w400),
                        ),

                        //! Profile Image --------------------------------------
                        const SizedBox(height: 30),
                        Center(
                          child: GestureDetector(
                            onTap:
                                _pickImage, // Trigger image picker when tapped
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  100), // Make it a circle
                              child: _imageFile != null
                                  ? Image.file(
                                      File(_imageFile!.path),
                                      width: 100, // Adjust size as needed
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: const Color(0xFFC4C4C4).withOpacity(
                                          0.2), // Background color for the placeholder
                                      width: 100, // Adjust size as needed
                                      height: 100,
                                      child: Center(
                                        child: Icon(
                                          Iconsax.image,
                                          color: Colors.grey.shade600,
                                          size: 20, // Adjust size as needed
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        //! Patient ? Doctor -----------------------------------
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.5,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    type = 0;
                                    userType = 'Patient';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: type == 0
                                      ? const Color(0xFF40B44F)
                                      : const Color(0xFFC4C4C4)
                                          .withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Patient",
                                  style: GoogleFonts.montserrat(
                                    color: type == 0
                                        ? Colors.white
                                        : const Color(0xFF8391A1),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  'OR',
                                  style: TextStyle(color: Color(0xFF8391A1)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2.5,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    type = 1;
                                    userType = 'Doctor';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: type == 1
                                      ? const Color(0xFF40B44F)
                                      : const Color(0xFFC4C4C4)
                                          .withOpacity(0.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Doctor",
                                  style: GoogleFonts.montserrat(
                                    color: type == 1
                                        ? Colors.white
                                        : const Color(0xFF8391A1),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        //! Form -----------------------------------------------
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              //*-----------------------------------------------
                              CommonTextField(
                                textController: _firstNameController,
                                currFocusNode: f1,
                                nextFocusNode: f2,
                                iconData: Iconsax.user_add,
                                hintText: 'First Name',
                                isVisible: true,
                              ),
                              //*-----------------------------------------------
                              CommonTextField(
                                textController: _lastNameController,
                                currFocusNode: f2,
                                nextFocusNode: f3,
                                iconData: Iconsax.user_remove,
                                hintText: 'Last Name',
                                isVisible: true,
                              ),
                              //*-----------------------------------------------
                              DropdownInput(
                                hintText: "Gender",
                                controller: _genderController,
                                options: const [
                                  'Male',
                                  'Female',
                                  'Others',
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _genderController.text = val ?? '';
                                  });
                                },
                                iconData: Iconsax.profile_2user,
                                currFocusNode: f3,
                                nextFocusNode: (type == 0) ? f9 : f4,
                                isVisible: true,
                              ),
                              //*-----------------------------------------------
                              CommonTextField(
                                textController: _qualificationController,
                                currFocusNode: f4,
                                nextFocusNode: f5,
                                iconData: Iconsax.book,
                                hintText: 'Qualification',
                                isVisible: (type == 1) ? true : false,
                              ),
                              //*-----------------------------------------------
                              CommonTextField(
                                textController: _yoeController,
                                currFocusNode: f5,
                                nextFocusNode: f6,
                                iconData: Iconsax.timer,
                                hintText: 'Years of Experience',
                                isVisible: (type == 1) ? true : false,
                              ),
                              //*-----------------------------------------------
                              DropdownInput(
                                hintText: "Off Day",
                                controller: _offDayController,
                                options: const [
                                  'Saturday',
                                  'Sunday',
                                  'Monday',
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _offDayController.text = val ?? '';
                                  });
                                },
                                iconData: Iconsax.home,
                                currFocusNode: f6,
                                nextFocusNode: f7,
                                isVisible: (type == 1) ? true : false,
                              ),
                              //*-----------------------------------------------
                              TimeField(
                                textController: _openingTime,
                                currFocusNode: f7,
                                nextFocusNode: f8,
                                isVisible: (type == 1) ? true : false,
                                openTime: true,
                                hintText: "Opening Time",
                              ),
                              //*-----------------------------------------------
                              TimeField(
                                textController: _closingTime,
                                currFocusNode: f8,
                                nextFocusNode: f9,
                                isVisible: (type == 1) ? true : false,
                                openTime: false,
                                hintText: "Closing Time",
                              ),
                              //*-----------------------------------------------
                              PhoneTextField(
                                phoneController: _phoneController,
                                currFocusNode: f9,
                                nextFocusNode: f10,
                              ),
                              //*-----------------------------------------------
                              DropdownInput(
                                hintText: "City",
                                controller: _cityController,
                                options: const [
                                  'Borivali',
                                  'Kandiwali',
                                  'Malad',
                                  'Goregaon'
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _cityController.text = val ?? '';
                                  });
                                },
                                iconData: Iconsax.location,
                                currFocusNode: f10,
                                nextFocusNode: (type == 0) ? f12 : f11,
                                isVisible: true,
                              ),
                              //*-----------------------------------------------
                              DropdownInput(
                                hintText: "Category",
                                controller: _categoryController,
                                options: const [
                                  'General',
                                  'Dentist',
                                  'Pediatrician',
                                  'Cardiologist',
                                  'Dermatologist',
                                  'Neurologist',
                                  'Gastroenterologist',
                                  'Otolaryngologist',
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _categoryController.text = val ?? '';
                                  });
                                },
                                iconData: Iconsax.element_4,
                                currFocusNode: f11,
                                nextFocusNode: f12,
                                isVisible: (type == 1) ? true : false,
                              ),
                              //*-----------------------------------------------
                              EmailTextField(
                                  emailController: _emailController,
                                  emailFocusNode: f12,
                                  nextFocusNode: f13),
                              //*-----------------------------------------------
                              PasswordTextField(
                                  passwordController: _passwordController,
                                  passwordFocusNode: f13,
                                  nextFocusNode: f14),
                              //*-----------------------------------------------
                              LocationField(
                                locationController: _locationController,
                                onTap: _getLocation,
                                isVisible: (type == 1) ? true : false,
                              )
                              //*-----------------------------------------------
                            ],
                          ),
                        ),
                        //!-----------------------------------------------------
                        const SizedBox(height: 60),
                        GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            _register();
                          },
                          child: Container(
                            width: screenSize,
                            height: 50,
                            decoration: BoxDecoration(
                                color: const Color(0xFF40B44F),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                'REGISTER',
                                style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        //*-------------------------------------------------------------
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                          },
                          child: Container(
                            width: screenSize,
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF40B44F), width: 1.5),
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                'LOGIN',
                                style: GoogleFonts.montserrat(
                                    fontSize: 15,
                                    color: const Color(0xFF40B44F),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
        _isPhotoUploaded = true; // Set this to true when an image is selected
      });
    }
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _getLocation() async {
    final locationData = await _location.getLocation();
    String locationName = await _locationService.getLocationName();
    setState(() {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
      userLocation = locationName;
      _locationController.text = locationName;
      // _locationController.text =
      //     "Location: ($locationName, $latitude, $longitude)";
      print("Location: ($locationName, $latitude, $longitude)");
    });
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _isPhotoUploaded) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Register the user with Firebase Authentication
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        User? user = userCredential.user;

        if (user != null) {
          // Determine user type path (Doctor or Patient)
          String userTypePath = userType == 'Doctor' ? 'Doctors' : 'Patients';
          Map<String, dynamic> userData = {
            'uid': user.uid,
            'email': _emailController.text,
            'phoneNumber': _phoneController.text,
            'firstName': _firstNameController.text,
            'lastName': _lastNameController.text,
            'gender': _genderController.text,
            'city': _cityController.text,
            'profileImageUrl': profileImageUrl,
          };

          if (userType == 'Doctor') {
            userData.addAll({
              'qualification': _qualificationController.text,
              'category': _categoryController.text,
              'yearsOfExperience': _yoeController.text,
              'userLocation': userLocation,
              'latitude': latitude,
              'longitude': longitude,
              'offDay': _offDayController.text,
              'openingTime': _openingTime.text,
              'closingTime': _closingTime
                  .text, // Note: Make sure this matches your Firestore field name
              'totalReviews': 0,
              'averageRating': 0.0,
              'numberOfReviews': 0,
            });
          }

          // Store user data in Firestore
          await FirebaseFirestore.instance
              .collection(userTypePath)
              .doc(user.uid)
              .set(userData);

          // Upload profile image if available
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('$userTypePath/${user.uid}/profile.jpg');
          UploadTask uploadTask =
              storageReference.putFile(File(_imageFile!.path));
          TaskSnapshot taskSnapshot = await uploadTask;

          String downloadUrl = await taskSnapshot.ref.getDownloadURL();
          await FirebaseFirestore.instance
              .collection(userTypePath)
              .doc(user.uid)
              .update({'profileImageUrl': downloadUrl});

          // If the user is a doctor, create the booking structure
          if (userType == 'Doctor') {
            await createBookingStructure(user.uid);
          }

          // Initialize user and navigate to respective dashboard
          await Global.initializeUser();

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => userType == 'Doctor'
                  ? const DoctorNavigationPage()
                  : const PatientNavigationPage(),
            ),
          );
        }
      } catch (e) {
        _showErrorDialog(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Handle the case where the photo is not uploaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload your photo and fill out the form.')),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Error', style: TextStyle(color: Color(0xFF40B44F))),
          content: Text(_getFormattedMessage(message)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('OK', style: TextStyle(color: Color(0xFF40B44F))),
            ),
          ],
        );
      },
    );
  }

  String _getFormattedMessage(String message) {
    return message.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  Future<void> createBookingStructure(String doctorId) async {
    final DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
        .collection('Doctors')
        .doc(doctorId)
        .get();

    if (doctorDoc.exists) {
      String openingTime = doctorDoc['openingTime']; // e.g., "10:00 AM"
      String closingTime = doctorDoc['closingTime']; // e.g., "12:00 PM"

      // Parse the opening and closing times
      DateFormat format = DateFormat('hh:mm a');
      DateTime startTime = format.parse(openingTime);
      DateTime endTime = format.parse(closingTime);

      // Create a reference to the Bookings collection
      CollectionReference bookingsRef =
          FirebaseFirestore.instance.collection('Bookings');

      // Create a document for the doctor using their UID
      DocumentReference doctorBookingDoc = bookingsRef.doc(doctorId);

      // Loop for 3 days: today, tomorrow, and the day after tomorrow
      for (int i = 0; i < 3; i++) {
        DateTime currentDate = DateTime.now().add(Duration(days: i));
        String dateKey = DateFormat('d')
            .format(currentDate); // Use just the day (e.g., "22")

        // Create a new document for the date
        DocumentReference dateDoc =
            doctorBookingDoc.collection('dates').doc(dateKey);

        // Create time slots in half-hour intervals
        Map<String, String> timeSlotsMap = {};
        DateTime currentTime = startTime;

        while (currentTime.isBefore(endTime) ||
            currentTime.isAtSameMomentAs(endTime)) {
          String timeSlot = DateFormat('hh:mm a').format(currentTime);
          timeSlotsMap[timeSlot] =
              'Empty'; // Initialize status for each time slot
          currentTime =
              currentTime.add(Duration(minutes: 30)); // Increment by 30 minutes
        }

        // Store opening and closing times along with time slots
        await dateDoc.set({
          'openingTime': openingTime,
          'closingTime': closingTime,
          ...timeSlotsMap,
        });

        print(
            "Booking structure created successfully for doctor: $doctorId on date: $dateKey");
      }
    } else {
      print("Doctor not found.");
    }
  }
}
