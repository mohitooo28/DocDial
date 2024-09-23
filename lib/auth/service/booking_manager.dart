import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> backgroundTask() async {
    print(
        "+++++++++++++++++++++++++++++++++Background Task Start+++++++++++++++++++++++++++++++++");
    try {
      final now = DateTime.now();
      final todayString = DateFormat('d').format(now);

      // Fetch all doctors
      final doctorsSnapshot = await _firestore.collection('Doctors').get();
      print("Doctors fetched: ${doctorsSnapshot.docs.length}");

      for (var doctorDoc in doctorsSnapshot.docs) {
        final doctorId = doctorDoc.id;
        print("Processing doctor: $doctorId");

        // Update time slots for today
        _updateTimeSlots(doctorId, todayString, now);

        // Delete yesterday's date and add a new date
        await _cleanupOldDatesAndAddNew(doctorId, todayString);
      }
    } catch (e) {
      print("Error in backgroundTask: $e");
    }
  }

  //!---------------------------------------------------------------------------
  Future<void> _updateTimeSlots(
      String doctorId, String todayString, DateTime now) async {
    print("---------------Update Time Slots Function---------------");

    // Fetch today's date document
    DocumentSnapshot todayDoc = await _firestore
        .collection('Bookings')
        .doc(doctorId)
        .collection('dates')
        .doc(todayString)
        .get();

    if (todayDoc.exists) {
      final timeSlots = todayDoc.data() as Map<String, dynamic>;
      print("Time slots for $todayString: $timeSlots");

      bool isClosingTimeReached = false;

      // Filter out non-time fields like openingTime and closingTime
      Map<String, dynamic> timeSlotsOnly = Map.from(timeSlots)
        ..remove('openingTime')
        ..remove('closingTime');

      // Sort time slots by time (in chronological order)
      var sortedTimeSlots = timeSlotsOnly.entries.toList()
        ..sort((a, b) {
          DateTime timeA = _parseBookingTime(a.key);
          DateTime timeB = _parseBookingTime(b.key);
          return timeA.compareTo(timeB);
        });

      // Check each time slot in order
      for (var timeEntry in sortedTimeSlots) {
        String time = timeEntry.key;
        String status = timeEntry.value;

        print("Checking time slot: $time, status: $status");

        // If status is already "Completed", skip the slot
        if (status == 'Completed') {
          print("$time is already marked as 'Completed'. Skipping...");
          continue;
        }

        // Parse the booking date and time from strings
        DateTime bookingDateTime = _parseBookingDateTime(todayString, time);
        print("Parsed booking time: $bookingDateTime");

        // If the current slot time has passed
        if (bookingDateTime.isBefore(now)) {
          if (status != 'Completed') {
            print("Time slot $time has passed, updating to 'Completed'");
            await todayDoc.reference.update({time: 'Completed'});
          }
        } else {
          print("Time slot $time is still in the future. Breaking early.");
          break; // Future time slot, stop processing further slots.
        }

        // If closing time is reached, stop the loop
        if (time == timeSlots['closingTime']) {
          isClosingTimeReached = true;
          print(
              "Closing time reached at $time. No further slots will be checked.");
          break;
        }
      }

      // If we reached closing time, no need to run the function again for today.
      if (isClosingTimeReached) {
        print("All time slots processed for today.");
      }
    } else {
      print("No document found for today: $todayString");
    }
  }

// Helper function to parse time slot (hh:mm a) to DateTime without the date
  DateTime _parseBookingTime(String time) {
    DateFormat timeFormat = DateFormat('hh:mm a');
    return timeFormat.parse(time);
  }

  DateTime _parseBookingDateTime(String day, String time) {
    print("parseBookingDateTime--------");
    DateTime now = DateTime.now();

    // Parse time with the proper format
    DateFormat timeFormat = DateFormat('hh:mm a');
    DateTime parsedTime = timeFormat.parse(time);

    // Use the current date's day/month/year, with the parsed time
    int parsedDay = int.parse(day);
    String fullDateString = '$parsedDay/${now.month}/${now.year}';

    // Combine day and time
    DateFormat dateFormat = DateFormat('d/M/yyyy');
    DateTime fullDate = dateFormat.parse(fullDateString);

    // Combine date and time to create a full DateTime object
    DateTime combinedDateTime = DateTime(
      fullDate.year,
      fullDate.month,
      fullDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    print("Parsed booking time: $combinedDateTime");
    return combinedDateTime;
  }

  //!---------------------------------------------------------------------------

  Future<void> _cleanupOldDatesAndAddNew(
      String doctorId, String todayString) async {
    print("---------------Clean Old Dates Function---------------");

    // Convert todayString to integer and get yesterday's and the day after tomorrow's date
    int todayInt = int.parse(todayString);
    int yesterdayInt = todayInt - 1;
    int newDateInt = todayInt + 2; // Two days ahead

    // Check if yesterday's document exists
    String yesterdayString = yesterdayInt.toString();
    DocumentSnapshot yesterdayDoc = await _firestore
        .collection('Bookings')
        .doc(doctorId)
        .collection('dates')
        .doc(yesterdayString)
        .get();

    if (yesterdayDoc.exists) {
      print("Deleting yesterday's doc: $yesterdayString");
      // Delete yesterday's document
      await yesterdayDoc.reference.delete();
    } else {
      print("No document found for yesterday: $yesterdayString");
    }

    // Check if the document for two days ahead already exists
    String newDateString = newDateInt.toString();
    DocumentSnapshot newDateDoc = await _firestore
        .collection('Bookings')
        .doc(doctorId)
        .collection('dates')
        .doc(newDateString)
        .get();

    if (!newDateDoc.exists) {
      // Fetch today's document to retrieve opening and closing times
      DocumentSnapshot todayDoc = await _firestore
          .collection('Bookings')
          .doc(doctorId)
          .collection('dates')
          .doc(todayString)
          .get();

      if (todayDoc.exists) {
        String openingTime = todayDoc['openingTime'];
        String closingTime = todayDoc['closingTime'];
        print("Creating new date doc for day after tomorrow: $newDateString");
        await _createNewDate(doctorId, newDateString, openingTime, closingTime);
      } else {
        print("No document found for today: $todayString");
      }
    } else {
      print("Document for $newDateString already exists, skipping creation.");
    }
  }

  Future<void> _createNewDate(String doctorId, String newDateString,
      String openingTime, String closingTime) async {
    print("---------------Create New Date Function---------------");
    try {
      CollectionReference bookingsRef =
          _firestore.collection('Bookings').doc(doctorId).collection('dates');

      // Parse opening and closing times
      DateFormat format = DateFormat('hh:mm a');
      DateTime startTime = format.parse(openingTime);
      DateTime endTime = format.parse(closingTime);

      Map<String, String> timeSlotsMap = {};
      DateTime currentTime = startTime;

      print(
          "Creating time slots for $newDateString from $openingTime to $closingTime");

      while (currentTime.isBefore(endTime) ||
          currentTime.isAtSameMomentAs(endTime)) {
        String timeSlot = DateFormat('hh:mm a').format(currentTime);
        print("Adding time slot: $timeSlot");
        timeSlotsMap[timeSlot] = 'Empty'; // Initialize time slots as empty
        currentTime =
            currentTime.add(const Duration(minutes: 30)); // 30-minute intervals
      }

      await bookingsRef.doc(newDateString).set({
        'openingTime': openingTime,
        'closingTime': closingTime,
        ...timeSlotsMap,
      });

      print("New date $newDateString created successfully");
    } catch (e) {
      print("Error in _createNewDate for doctor: $doctorId, error: $e");
    }
  }
}
