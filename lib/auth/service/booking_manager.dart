import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> backgroundTask() async {
    print("Background Task Start");
    try {
      final now = DateTime.now();
      DateFormat('d').format(now);

      final doctorsSnapshot = await _firestore.collection('Doctors').get();
      print("Doctors fetched: ${doctorsSnapshot.docs.length}");

      // Run the cleanup and creation in parallel for all doctors
      await Future.wait(doctorsSnapshot.docs.map((doctorDoc) {
        final doctorId = doctorDoc.id;
        return _cleanupOldDatesAndAddNew(doctorId, now);
      }));
    } catch (e) {
      print("Error in backgroundTask: $e");
    }
  }

  Future<void> _cleanupOldDatesAndAddNew(
      String doctorId, DateTime today) async {
    print("Clean Old Dates Function");

    // Use DateTime to handle transitions across months and years
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime newDate = today.add(const Duration(days: 2));

    WriteBatch batch = _firestore.batch();

    // Delete yesterday's document
    String yesterdayString =
        DateFormat('d').format(yesterday); // Handles month transition
    DocumentReference yesterdayDoc = _firestore
        .collection('Bookings')
        .doc(doctorId)
        .collection('dates')
        .doc(yesterdayString);

    batch.delete(yesterdayDoc);

    // Create a new date for the day after tomorrow if it doesn't exist
    String newDateString =
        DateFormat('d').format(newDate); // Handles month transition
    DocumentReference newDateDoc = _firestore
        .collection('Bookings')
        .doc(doctorId)
        .collection('dates')
        .doc(newDateString);

    DocumentSnapshot todayDoc = await _firestore
        .collection('Bookings')
        .doc(doctorId)
        .collection('dates')
        .doc(DateFormat('d').format(today))
        .get();

    if (!todayDoc.exists || todayDoc.data() == null) {
      print("No document found for today.");
      return;
    }

    Map<String, dynamic> todayData = todayDoc.data() as Map<String, dynamic>;
    String openingTime = todayData['openingTime'];
    String closingTime = todayData['closingTime'];

    batch.set(newDateDoc, _createTimeSlotsMap(openingTime, closingTime));

    // Commit the batch operation
    await batch.commit();
  }

  Map<String, String> _createTimeSlotsMap(
      String openingTime, String closingTime) {
    DateFormat format = DateFormat('hh:mm a');
    DateTime startTime = format.parse(openingTime);
    DateTime endTime = format.parse(closingTime);

    Map<String, String> timeSlotsMap = {};
    DateTime currentTime = startTime;

    while (currentTime.isBefore(endTime) ||
        currentTime.isAtSameMomentAs(endTime)) {
      String timeSlot = DateFormat('hh:mm a').format(currentTime);
      timeSlotsMap[timeSlot] = 'Empty';
      currentTime = currentTime.add(const Duration(minutes: 30));
    }

    return {
      'openingTime': openingTime,
      'closingTime': closingTime,
      ...timeSlotsMap,
    };
  }
}
