import 'package:docdial/patient/widget/loadingbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:docdial/screens/chat_screen.dart';
import '../doctor/model/doctor.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Doctor> _chatList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatList();
  }

  Future<void> _fetchChatList() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        // Fetch all chat documents and filter by `id` field
        QuerySnapshot chatListSnapshot = await _firestore
            .collection('ChatList')
            .where('id', isEqualTo: userId) // Adjusting query to match 'id'
            .get();

        List<Doctor> tempChatList = [];

        if (chatListSnapshot.docs.isNotEmpty) {
          for (var doc in chatListSnapshot.docs) {
            // Extract the doctor ID from the document
            String doctorId = doc.id;

            // Fetch the doctor's details from Firestore
            DocumentSnapshot doctorSnapshot =
                await _firestore.collection('Doctors').doc(doctorId).get();

            if (doctorSnapshot.exists) {
              Doctor doctor = Doctor.fromMap(
                  doctorSnapshot.data() as Map<String, dynamic>, doctorId);
              tempChatList.add(doctor);
            }
          }
        }

        // Debugging to check what data is fetched
        print("ChatList fetched: ${tempChatList.length} chats found.");

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
        title: Padding(
          padding: const EdgeInsets.only(left: 18, top: 20),
          child: Text(
            'Chats',
            style: GoogleFonts.montserratAlternates(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 24,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const CustomCircularLoading()
          : _chatList.isEmpty
              ? Center(
                  child: Text(
                  'No chats available',
                  style: GoogleFonts.montserratAlternates(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ))
              : Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListView.builder(
                      itemCount: _chatList.length,
                      itemBuilder: (context, index) {
                        Doctor doctor = _chatList[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                      doctorId: doctor.uid,
                                      doctorName:
                                          '${doctor.firstName} ${doctor.lastName}',
                                      patientId: _auth.currentUser!.uid,
                                    )));
                          },
                          child: Container(
                              height: 48,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 30),
                              decoration: const BoxDecoration(
                                color: Color(0xffF0EFFF),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 20.0),
                                    child: Text(
                                      'Dr. ${doctor.firstName} ${doctor.lastName}',
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
