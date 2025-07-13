//PLUG IN
import 'package:intl/intl.dart';

/// Class representing a calorie entry recorded at a specific time.
class Calories {
  final DateTime time;
  final int value;

  Calories({required this.time, required this.value});

  /// Factory constructor from JSON.
  Calories.fromJson(String date, Map<String, dynamic> json)
    : time = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["time"]}'),
      value = double.parse(json["value"]).round();

  @override
  String toString() {
    return 'Calories(time: $time, value: $value)';
  }
}
