import 'package:intl/intl.dart';

class BaseTimeConvertor {
  // Convert UTC date-time to formatted time (HH:mm AM/PM)
  static String formatTime(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) return 'N/A';
    try {
      final dateTime = DateTime.parse(timestamp.toString()).toLocal();
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }
}
