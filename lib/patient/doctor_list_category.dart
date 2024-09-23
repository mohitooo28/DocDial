import 'package:docdial/doctor/doctor_details_page.dart';
import 'package:docdial/patient/widget/doctor_card.dart';
import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:docdial/doctor/model/doctor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svg_flutter/svg.dart';

class DoctorByCategory extends StatefulWidget {
  final String category;

  const DoctorByCategory({super.key, required this.category});

  @override
  State<DoctorByCategory> createState() => DoctorByCategoryState();
}

class DoctorByCategoryState extends State<DoctorByCategory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> _doctors = [];
  bool _isLoading = true;
  bool _hasNoDoctors = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctorsByCategory();
  }

  Future<void> _fetchDoctorsByCategory() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('Doctors')
          .where('category', isEqualTo: widget.category)
          .get();

      List<Doctor> tmpDoctors = snapshot.docs.map((doc) {
        return Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      setState(() {
        _doctors = tmpDoctors;
        _isLoading = false;
        _hasNoDoctors = _doctors.isEmpty; // Update the flag
      });
    } catch (e) {
      // Handle error here (optional)
      print("Error fetching doctors: $e");
      setState(() {
        _isLoading = false;
        _hasNoDoctors = true; // You might want to show an error message instead
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            widget.category,
            style:
                GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: _isLoading
          ? const CustomCircularLoading()
          : _hasNoDoctors
              ? Center(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      SvgPicture.asset(
                        "assets/vector/empty.svg",
                        height: 250,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'No doctors available in this category.',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(flex: 5),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: List.generate(
                          _doctors.length,
                          (index) => DoctorDetailCard(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorDetailPage(
                                    doctor: _doctors[index],
                                  ),
                                ),
                              );
                            },
                            doctor: _doctors[index],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}
