import 'package:intl/intl.dart';

/// Class that represents a step count entry
class Steps {
  final DateTime time; // Timestamp of the step measurement
  final int value;     // Number of steps

  // Constructor to initialize time and value
  Steps({required this.time, required this.value});

  /// Factory constructor to create a Steps object from JSON data.
  /// Takes a date string and a map containing 'time' and 'value'.
  Steps.fromJson(String date, Map<String, dynamic> json)
    : time = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["time"]}'),
      value = int.parse(json["value"]); // Parse step count as integer

  @override
  String toString() {
    // Returns a readable string representation of the object
    return 'Steps(time: $time, value: $value)';
  } // toString
} 
