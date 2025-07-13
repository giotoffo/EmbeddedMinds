import '../providers/profile_provider.dart';
import '../providers/dataprovider.dart';

double calculateNutritionScoreFromProviders({
  required ProfileProvider profile,
  required DataProvider data,
}) {
  // 1️⃣ PROFILE DATA
  final String genderStr = profile.gender;
  final bool isPregnant = profile.isPregnant;
  final int age = int.tryParse(profile.age) ?? 30;
  final bool isMale = genderStr.toUpperCase() == 'M';
  final bool isFemale = genderStr.toUpperCase() == 'F';

  // 2️⃣ AGE CATEGORIES
  String ageGroup = 'adult';
  if (age < 18) {
    ageGroup = 'teen';
  } else if (age < 30) {
    ageGroup = 'youngAdult';
  } else if (age < 50) {
    ageGroup = 'adult';
  } else {
    ageGroup = 'senior';
  }

  // 3️⃣ TARGET 
  double calorieTarget = isMale ? 2500 : 2000;
  int stepsTarget = isMale ? 10000 : 8500;
  int maxExerciseMinutes = isMale ? 100 : 90;

  if (isFemale && isPregnant) {
    calorieTarget += age < 30 ? 300 : 250;
  }

  if (ageGroup == 'teen') {
    calorieTarget += 200;
  } else if (ageGroup == 'senior') {
    calorieTarget -= 150;
  }

  // 4️⃣ DATA FROM DATA PROVIDER

  // 🔹 Total caloriues burned today 
  final int calories =
      data.calories_data.isNotEmpty
          ? data.calories_data.map((e) => e.value).reduce((a, b) => a + b)
          : 0;

  // 🔹 Total steps of today
  final int steps =
      data.steps_data.isNotEmpty
          ? data.steps_data.map((e) => e.value).reduce((a, b) => a + b)
          : 0;

  // 🔹 Exercises: sum of total minutes
  final int exerciseMinutes =
      data.exercises.isNotEmpty
          ? data.exercises
              .map((e) => (e.duration ?? 0) ~/ 60000)
              .reduce((a, b) => a + b)
          : 0;

  // 🔹 Medium Heart Rate 
  final double heartRate =
      data.heartRates.isNotEmpty
          ? data.heartRates.map((e) => e.value).reduce((a, b) => a + b) /
              data.heartRates.length
          : 0.0;

  // 5️⃣ CALCOLATION SCORE

  // 🔸 Calories Score
  double calorieRatio = calories / calorieTarget;
  double calorieScore = 1.0;
  if (calorieRatio > 1.0) {
    calorieScore = 1.0 - ((calorieRatio - 1.0) * 0.7);
  }

  // 🔸 Steps Score
  double stepsScore = (steps / stepsTarget).clamp(0.0, 1.0);

  // 🔸 Exercise Score
  double exerciseRatio = (exerciseMinutes / maxExerciseMinutes).clamp(0.0, 1.0);
  double exerciseScore = 1.0 - (exerciseRatio * 0.3);

  // 🔸 Heart rate penalty
  double heartRatePenalty = heartRate > 160 ? 0.1 : 0.0;

  // 🔸 Final score
  double rawScore =
      (calorieScore * 0.5) +
      (stepsScore * 0.2) +
      (exerciseScore * 0.2) -
      heartRatePenalty;

  return (rawScore.clamp(0.0, 1.0) * 100).roundToDouble();
}
