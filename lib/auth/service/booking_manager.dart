import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> backgroundTask() async {
    print("Background Task Start");
    try {
      final DateTime today = DateTime.now();
      final doctorsSnapshot = await _firestore.collection('Doctors').get();

      // Process each doctor's booking records
      await Future.wait(doctorsSnapshot.docs.map((doctorDoc) async {
        final doctorId = doctorDoc.id;
        await _manageDoctorBookings(doctorId, today, doctorDoc);
      }));
    } catch (e) {
      print("Error in backgroundTask: $e");
    }
  }

  Future<void> _manageDoctorBookings(
      String doctorId, DateTime today, DocumentSnapshot doctorDoc) async {
    final CollectionReference dateCollection =
        _firestore.collection('Bookings').doc(doctorId).collection('dates');

    // Fetch all existing date documents for this doctor
    final existingDatesSnapshot = await dateCollection.get();

    // Format dates to compare
    final DateFormat dateFormat = DateFormat('d');
    final int todayInt = int.parse(dateFormat.format(today));
    final int tomorrowInt =
        int.parse(dateFormat.format(today.add(Duration(days: 1))));
    final int dayAfterTomorrowInt =
        int.parse(dateFormat.format(today.add(Duration(days: 2))));

    // Separate batch operations for safe handling
    WriteBatch deleteBatch = _firestore.batch();
    WriteBatch createBatch = _firestore.batch();

    // Process each date document
    for (var dateDoc in existingDatesSnapshot.docs) {
      final int dateInt = int.tryParse(dateDoc.id) ?? 0;

      // Delete documents with dates before today
      if (dateInt < todayInt) {
        deleteBatch.delete(dateDoc.reference);
      }
    }

    // Commit deletion of past dates
    await deleteBatch.commit();

    // Get the opening and closing times from the Doctor's profile
    final String openingTime = doctorDoc.get('openingTime');
    final String closingTime = doctorDoc.get('closingTime');

    // Create documents for today, tomorrow, and the day after tomorrow if missing
    await _createDateDocIfMissing(dateCollection, todayInt.toString(),
        createBatch, openingTime, closingTime);
    await _createDateDocIfMissing(dateCollection, tomorrowInt.toString(),
        createBatch, openingTime, closingTime);
    await _createDateDocIfMissing(dateCollection,
        dayAfterTomorrowInt.toString(), createBatch, openingTime, closingTime);

    // Commit creation of missing dates
    await createBatch.commit();
  }

  Future<void> _createDateDocIfMissing(
    CollectionReference dateCollection,
    String dateString,
    WriteBatch batch,
    String openingTime,
    String closingTime,
  ) async {
    final DocumentReference dateDocRef = dateCollection.doc(dateString);

    // Check if the document for this date already exists
    final DocumentSnapshot dateDocSnapshot = await dateDocRef.get();
    if (dateDocSnapshot.exists) return;

    // Create the new document with time slots based on the provided opening and closing times
    batch.set(dateDocRef, _createTimeSlotsMap(openingTime, closingTime));
  }

  Map<String, String> _createTimeSlotsMap(
      String openingTime, String closingTime) {
    final DateFormat timeFormat = DateFormat('hh:mm a');
    final DateTime startTime = timeFormat.parse(openingTime);
    final DateTime endTime = timeFormat.parse(closingTime);

    final Map<String, String> timeSlots = {};
    DateTime currentTime = startTime;

    while (currentTime.isBefore(endTime) ||
        currentTime.isAtSameMomentAs(endTime)) {
      final String timeSlot = timeFormat.format(currentTime);
      timeSlots[timeSlot] = 'Empty';
      currentTime = currentTime.add(Duration(minutes: 30));
    }

    return {
      'openingTime': openingTime,
      'closingTime': closingTime,
      ...timeSlots,
    };
  }
}
