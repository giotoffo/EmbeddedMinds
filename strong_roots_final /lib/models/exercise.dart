import 'package:intl/intl.dart';

/// Exercise class to represent a workout session
class Exercise {
  final String activityName;      
  final double? distance;         
  final String? distanceUnit;     
  final int? duration;            
  final int? calories;            
  final double? speed;            
  final DateTime time;            

  Exercise({
    required this.activityName,
    this.distance,
    this.distanceUnit,
    this.duration,
    this.calories,
    this.speed,
    required this.time,
  });

  /// Constructor to create an Exercise object from JSON data.
  /// Takes a date string and a JSON map with activity details.
  Exercise.fromJson(String date, Map<String, dynamic> json)
      : activityName = json["activityName"] ?? "",
        distance = json["distance"]?.toDouble(),
        distanceUnit = json["distanceUnit"],
        duration = (json['duration'] is int)
            ? json['duration']
            : (json['duration'] is double)
                ? (json['duration'] as double).round()
                : null,
        calories = (json['calories'] is int)
            ? json['calories']
            : (json['calories'] is double)
                ? (json['calories'] as double).round()
                : null,
        speed = json["speed"]?.toDouble(),
        time = DateFormat('yyyy-MM-dd HH:mm:ss').parse('$date ${json["time"]}');

  @override
  String toString() {
    return 'Exercise('
        'activityName: $activityName, '
        'distance: $distance $distanceUnit, '
        'duration: ${duration != null ? Duration(milliseconds: duration!).inMinutes : 'N/A'} min, '
        'speed: $speed km/h, '
        'time: $time'
        ')';
  }
}
