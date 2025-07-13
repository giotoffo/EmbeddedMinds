import 'package:flutter/material.dart';

//MODELS
import '../models/heart_rate.dart';
import '../models/steps.dart';
import '../models/calories.dart';
import '../models/exercise.dart';

//UTILS
import '../utils/impact.dart';

class DataProvider extends ChangeNotifier {
  final Impact impact = Impact();

  DateTime currentDate = DateTime.now().subtract(
    Duration(days: 1),
  ); // Default: yesterday
  List<HR> heartRates = [];
  List<Steps> steps_data = [];
  List<Calories> calories_data = [];
  List<Exercise> exercises = [];

  String name = "User";
  String surname = "";

  bool _loading = false;
  bool get loading => _loading;

  // Cache for day
  final Map<String, List<HR>> _cachedHR = {};
  final Map<String, List<Steps>> _cachedSteps = {};
  final Map<String, List<Calories>> _cachedCalories = {};
  final Map<String, List<Exercise>> _cachedExercises = {};

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _loadingStart() {
    _loading = true;
    notifyListeners();
  }

  void _loadingEnd() {
    _loading = false;
    notifyListeners();
  }

  Future<void> getDataOfDay(DateTime date) async {
    final key = _dateKey(date);
    _loadingStart();
    currentDate = date;

    if (!_cachedHR.containsKey(key)) {
      _cachedHR[key] = await impact.getHRData(date);
      _cachedSteps[key] = await impact.getStepsData(date);
      _cachedCalories[key] = await impact.getCaloriesData(date);
      _cachedExercises[key] = await impact.getExerciseData(date);

      print('✅ Data downloaded for $key');
    } else {
      print('♻️ Data in cache for $key');
    }

    // Update the current data with cached values
    heartRates = _cachedHR[key]!;
    steps_data = _cachedSteps[key]!;
    calories_data = _cachedCalories[key]!;
    exercises = _cachedExercises[key]!;

    _loadingEnd();
  }

  bool hasDataFor(DateTime date) {
    final key = _dateKey(date);
    return _cachedHR.containsKey(key) &&
        _cachedSteps.containsKey(key) &&
        _cachedCalories.containsKey(key) &&
        _cachedExercises.containsKey(key) &&
        _cachedHR[key]!.isNotEmpty;
  }

  // Getter to retrieve data for the current date
  List<HR> getHR(DateTime date) => _cachedHR[_dateKey(date)] ?? [];
  List<Steps> getSteps(DateTime date) => _cachedSteps[_dateKey(date)] ?? [];
  List<Calories> getCalories(DateTime date) =>
      _cachedCalories[_dateKey(date)] ?? [];
  List<Exercise> getExercises(DateTime date) =>
      _cachedExercises[_dateKey(date)] ?? [];

  void addDay() {
    currentDate = currentDate.add(Duration(days: 1));
    notifyListeners();
  }

  void subtractDay() {
    currentDate = currentDate.subtract(Duration(days: 1));
    notifyListeners();
  }

  void setUserName(String name, String surname) {
    this.name = name;
    this.surname = surname;
    notifyListeners();
  }
}
