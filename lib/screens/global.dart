import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Global {
  static String? username;
  static String? profileImageUrl;

  static Future<void> initializeUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    User? user = _auth.currentUser;

    if (user != null) {

      // Check in the Doctors collection
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('Doctors')
          .doc(user.uid)
          .get();

      if (doctorSnapshot.exists) {
        Map<String, dynamic> doctorData =
            doctorSnapshot.data() as Map<String, dynamic>;
        username =
            '${doctorData['firstName'] ?? ''} ${doctorData['lastName'] ?? ''}'
                .trim();
        profileImageUrl = doctorData['profileImageUrl'] ?? '';
      } else {
        // Check in the Patients collection
        DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
            .collection('Patients')
            .doc(user.uid)
            .get();

        if (patientSnapshot.exists) {
          Map<String, dynamic> patientData =
              patientSnapshot.data() as Map<String, dynamic>;
          username =
              '${patientData['firstName'] ?? ''} ${patientData['lastName'] ?? ''}'
                  .trim();
          profileImageUrl = patientData['profileImageUrl'] ?? '';
        }
      }
    }
  }
}


