import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ChatScreen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  final String? patientId;
  final String? patientName;

  ChatScreen({
    this.doctorId,
    this.doctorName,
    this.patientId,
    this.patientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  String? _currentUserId;

  bool get isDoctor => _currentUserId == widget.doctorId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser?.uid;
  }

  // send message method
  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      String message = _messageController.text.trim();
      String timeStamp = DateTime.now().toIso8601String();

      //determine sender and receiver IDs based on the user's role
      String senderUid;
      String receiverUid;

      if (isDoctor) {
        senderUid = _currentUserId!;
        receiverUid = widget.patientId!;
      } else {
        senderUid = _currentUserId!;
        receiverUid = widget.doctorId!;
      }

      // save message in Firestore Chat collection
      _firestore.collection('Chat').add({
        'message': message,
        'receiver': receiverUid,
        'sender': senderUid,
        'timestamp': timeStamp,
      });

      //update chatList
      _firestore.collection('ChatList').doc(senderUid).set({
        'id': receiverUid,
      });

      _firestore.collection('ChatList').doc(receiverUid).set({
        'id': senderUid,
      });

      //clear the message input
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? chatPartnerName = isDoctor ? widget.patientName : widget.doctorName;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
          ),
          title: Text(
            '$chatPartnerName',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
        ),
        body: Column(
          children: [
            Expanded(
                child: StreamBuilder(
                    stream: _firestore.collection('Chat').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No message yet.'));
                      }
                      List<Map<String, dynamic>> messagesList = [];

                      for (var doc in snapshot.data!.docs) {
                        var value = doc.data() as Map<String, dynamic>;
                        if ((value['sender'] == _currentUserId &&
                                value['receiver'] == widget.doctorId) ||
                            (value['sender'] == widget.doctorId &&
                                value['receiver'] == _currentUserId) ||
                            (value['sender'] == _currentUserId &&
                                value['receiver'] == widget.patientId) ||
                            (value['sender'] == widget.patientId &&
                                value['receiver'] == _currentUserId)) {
                          messagesList.add({
                            'message': value['message'],
                            'sender': value['sender'],
                            'timestamp': value['timestamp'],
                          });
                        }
                      }

                      messagesList.sort(
                          (a, b) => a['timestamp'].compareTo(b['timestamp']));

                      return ListView.builder(
                          itemCount: messagesList.length,
                          itemBuilder: (context, index) {
                            bool isMe =
                                messagesList[index]['sender'] == _currentUserId;
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? const Color.fromARGB(255, 45, 148, 58)
                                      : const Color(0xFF19244D),
                                  borderRadius: isMe
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.zero)
                                      : const BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.zero,
                                          bottomRight: Radius.circular(10)),
                                ),
                                child: Text(
                                  messagesList[index]['message'],
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          });
                    })),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  //*===========================================================
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(15.0),
                      height: 60,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                boxShadow: const [
                                  BoxShadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 5,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1, // Start with one line
                                  maxLines:
                                      null, // Allow the field to expand as needed
                                  controller: _messageController,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter Your Text",
                                    contentPadding: const EdgeInsets.all(18),
                                    hintStyle: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Container(
                            padding: const EdgeInsets.all(15.0),
                            decoration: const BoxDecoration(
                                color: Colors.green, shape: BoxShape.circle),
                            child: InkWell(
                              onTap: _sendMessage,
                              child: const Icon(
                                Iconsax.arrow_square_up,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  //*===========================================================
                  // Expanded(
                  //   child: SizedBox(
                  //     height: 50,
                  //     child: TextField(
                  //       keyboardType: TextInputType.multiline,
                  //       style: GoogleFonts.nunito(
                  //         fontSize: 15,
                  //         fontWeight: FontWeight.w500,
                  //         color: Colors.black,
                  //       ),
                  //       controller: _messageController,
                  //       maxLines: 4,
                  //       decoration: InputDecoration(
                  //         filled: true,
                  //         fillColor: Color(0xffF0EFFF),
                  //         hintText: 'Enter your message..',
                  //         focusedBorder: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //           borderSide: BorderSide(
                  //               color: Color(0xFF19244D), width: 2.0),
                  //         ),
                  //         // border
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(8),
                  //           borderSide:
                  //               BorderSide(color: Colors.red, width: 3.0),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // IconButton(
                  //     onPressed: _sendMessage,
                  //     icon: Icon(Iconsax.arrow_square_up,
                  //         size: 40, color: Color.fromARGB(255, 45, 148, 58)))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iconsax/iconsax.dart';

// class ChatScreen extends StatefulWidget {
//   final String? doctorId;
//   final String? doctorName;
//   final String? patientId;
//   final String? patientName;

//   ChatScreen({
//     this.doctorId,
//     this.doctorName,
//     this.patientId,
//     this.patientName,
//   });

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _messageController = TextEditingController();
//   String? _currentUserId;

//   bool get isDoctor => _currentUserId == widget.doctorId;

//   @override
//   void initState() {
//     super.initState();
//     _currentUserId = _auth.currentUser?.uid;
//   }

//   // send message method
//   void _sendMessage() {
//     if (_messageController.text.trim().isNotEmpty) {
//       String message = _messageController.text.trim();
//       String timeStamp = DateTime.now().toIso8601String();

//       //determine sender and receiver IDs based on the user's role
//       String senderUid;
//       String receiverUid;

//       if (isDoctor) {
//         senderUid = _currentUserId!;
//         receiverUid = widget.patientId!;
//       } else {
//         senderUid = _currentUserId!;
//         receiverUid = widget.doctorId!;
//       }

//       // save message in Firestore Chat collection
//       _firestore.collection('Chat').add({
//         'message': message,
//         'receiver': receiverUid,
//         'sender': senderUid,
//         'timestamp': timeStamp,
//       });

//       //update chatList
//       _firestore.collection('ChatList').doc(senderUid).set({
//         'id': receiverUid,
//       });

//       _firestore.collection('ChatList').doc(receiverUid).set({
//         'id': senderUid,
//       });

//       //clear the message input
//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String? chatPartnerName = isDoctor ? widget.patientName : widget.doctorName;

//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           leading: GestureDetector(
//             onTap: () => Navigator.pop(context),
//             child: const Icon(
//               Icons.arrow_back_ios_new_rounded,
//               size: 20,
//             ),
//           ),
//           title: Text(
//             '$chatPartnerName',
//             style: GoogleFonts.poppins(fontSize: 18),
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//                 child: StreamBuilder(
//                     stream: _firestore.collection('Chat').snapshots(),
//                     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return Center(child: Text('No message yet.'));
//                       }
//                       List<Map<String, dynamic>> messagesList = [];

//                       for (var doc in snapshot.data!.docs) {
//                         var value = doc.data() as Map<String, dynamic>;
//                         if ((value['sender'] == _currentUserId &&
//                                 value['receiver'] == widget.doctorId) ||
//                             (value['sender'] == widget.doctorId &&
//                                 value['receiver'] == _currentUserId) ||
//                             (value['sender'] == _currentUserId &&
//                                 value['receiver'] == widget.patientId) ||
//                             (value['sender'] == widget.patientId &&
//                                 value['receiver'] == _currentUserId)) {
//                           messagesList.add({
//                             'message': value['message'],
//                             'sender': value['sender'],
//                             'timestamp': value['timestamp'],
//                           });
//                         }
//                       }

//                       messagesList.sort(
//                           (a, b) => a['timestamp'].compareTo(b['timestamp']));

//                       return ListView.builder(
//                           itemCount: messagesList.length,
//                           itemBuilder: (context, index) {
//                             bool isMe =
//                                 messagesList[index]['sender'] == _currentUserId;
//                             return Align(
//                               alignment: isMe
//                                   ? Alignment.centerRight
//                                   : Alignment.centerLeft,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     vertical: 10, horizontal: 16),
//                                 margin: EdgeInsets.symmetric(
//                                     vertical: 3, horizontal: 8),
//                                 decoration: BoxDecoration(
//                                   color: isMe
//                                       ? Color.fromARGB(255, 45, 148, 58)
//                                       : Color(0xFF19244D),
//                                   borderRadius: isMe
//                                       ? BorderRadius.only(
//                                           topLeft: Radius.circular(10),
//                                           topRight: Radius.circular(10),
//                                           bottomLeft: Radius.circular(10),
//                                           bottomRight: Radius.zero)
//                                       : BorderRadius.only(
//                                           topLeft: Radius.circular(10),
//                                           topRight: Radius.circular(10),
//                                           bottomLeft: Radius.zero,
//                                           bottomRight: Radius.circular(10)),
//                                 ),
//                                 child: Text(
//                                   messagesList[index]['message'],
//                                   style: GoogleFonts.nunito(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           });
//                     })),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: SizedBox(
//                       height: 50,
//                       child: TextField(
//                         keyboardType: TextInputType.multiline,
//                         style: GoogleFonts.nunito(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w500,
//                           color: Colors.black,
//                         ),
//                         controller: _messageController,
//                         maxLines: 4,
//                         decoration: InputDecoration(
//                           filled: true,
//                           fillColor: Color(0xffF0EFFF),
//                           hintText: 'Enter your message..',
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide: BorderSide(
//                                 color: Color(0xFF19244D), width: 2.0),
//                           ),
//                           // border
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                             borderSide:
//                                 BorderSide(color: Colors.red, width: 3.0),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                       onPressed: _sendMessage,
//                       icon: Icon(Iconsax.arrow_square_up,
//                           size: 40, color: Color.fromARGB(255, 45, 148, 58)))
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
