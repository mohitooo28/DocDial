import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:docdial/screens/chat_screen.dart';
import 'package:docdial/doctor/model/patient.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorChatlistPage extends StatefulWidget {
  const DoctorChatlistPage({super.key});

  @override
  State<DoctorChatlistPage> createState() => _DoctorChatlistPageState();
}

class _DoctorChatlistPageState extends State<DoctorChatlistPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Patient> _chatList = [];
  bool _isLoading = true;
  late String doctorId;

  @override
  void initState() {
    super.initState();
    doctorId = _auth.currentUser?.uid ?? '';
    _fetchChatList();
  }

  Future<void> _fetchChatList() async {
    if (doctorId.isNotEmpty) {
      try {
        // Fetch chat list where the doctor is involved
        QuerySnapshot chatListSnapshot = await _firestore
            .collection('ChatList')
            .where('id',
                isEqualTo: doctorId) // Check if chat involves the doctor
            .get();

        List<Patient> tempChatList = [];

        if (chatListSnapshot.docs.isNotEmpty) {
          for (var doc in chatListSnapshot.docs) {
            // Extract the patient ID from the chat document
            String patientId = doc.id;

            // Fetch patient details from Firestore
            DocumentSnapshot patientSnapshot =
                await _firestore.collection('Patients').doc(patientId).get();

            if (patientSnapshot.exists) {
              Patient patient = Patient.fromMap(
                  patientSnapshot.data() as Map<String, dynamic>);
              tempChatList.add(patient);
            }
          }
        }

        setState(() {
          _chatList = tempChatList;
          _isLoading = false;
        });
      } catch (error) {
        print("Error fetching chat list: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'Your Chats',
            style: GoogleFonts.poppins(fontSize: 22),
          ),
        ),
      ),
      body: _isLoading
          ? const CustomCircularLoading()
          : _chatList.isEmpty
              ? const Center(child: Text('No chats available'))
              : Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListView.builder(
                      itemCount: _chatList.length,
                      itemBuilder: (context, index) {
                        final patient = _chatList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      doctorId: doctorId,
                                      patientId: patient.uid,
                                      patientName:
                                          '${patient.firstName} ${patient.lastName}',
                                    )));
                          },
                          child: Container(
                              height: 48,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              decoration: const BoxDecoration(
                                color: Color(0xffF0EFFF),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 20.0),
                                    child: Text(
                                      '${patient.firstName} ${patient.lastName}',
                                      style: GoogleFonts.nunitoSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              )),
                        );
                      }),
                ),
    );
  }
}
