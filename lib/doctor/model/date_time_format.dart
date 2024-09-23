import 'package:intl/intl.dart';

String formatDate(String dateStr) {
  final now = DateTime.now();
  final formatter = DateFormat('MM/dd/yyyy');
  DateTime dateTime;

  try {
    dateTime = formatter.parse(dateStr);
  } catch (e) {
    return 'Invalid Date';
  }

  if (now.year == dateTime.year &&
      now.month == dateTime.month &&
      now.day == dateTime.day) {
    return 'Today';
  }
  return DateFormat('MMM d').format(dateTime);
}

String formatTimeRange(String startTimeStr) {
  final formatter = DateFormat('h:mm a');
  DateTime startTime;

  try {
    startTime = formatter.parse(startTimeStr);
  } catch (e) {
    return 'Invalid Time';
  }

  final endTime = startTime.add(const Duration(minutes: 30));
  final endTimeStr = formatter.format(endTime);

  return '$startTimeStr - $endTimeStr';
}

DateTime parseDateTime(String date, String time) {
  const defaultDate = '01/01/1970';
  const defaultTime = '00:00';

  final dateFormatter = DateFormat('MM/dd/yyyy');
  final timeFormatter = DateFormat('HH:mm');

  DateTime dateTime;
  try {
    dateTime = dateFormatter.parse(date.isNotEmpty ? date : defaultDate);
  } catch (e) {
    dateTime = dateFormatter.parse(defaultDate);
    print('Date parsing error: $e');
  }

  DateTime timeDateTime;
  try {
    timeDateTime = timeFormatter.parse(time.isNotEmpty ? time : defaultTime);
  } catch (e) {
    timeDateTime = timeFormatter.parse(defaultTime);
    print('Time parsing error: $e');
  }

  // Debug print for verification
  print(
      'Parsed DateTime: ${DateTime(dateTime.year, dateTime.month, dateTime.day, timeDateTime.hour, timeDateTime.minute)}');

  return DateTime(dateTime.year, dateTime.month, dateTime.day,
      timeDateTime.hour, timeDateTime.minute);
}
