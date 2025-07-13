import 'package:intl/intl.dart';

/// HR class represents a heart rate data point
class HR {
  final DateTime timestamp; // Exact time of the heart rate measurement
  final int value;          // Heart rate value (in BPM)

  HR({
    required this.timestamp,
    required this.value,
  });

  /// Constructor to create an HR object from JSON.
  /// Expects a date string and a map containing 'time' and 'value'.
  HR.fromJson(String date, Map<String, dynamic> json)
      : timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["time"]}'),
        value = json["value"];
}

