import 'package:flutter/material.dart';

//PROVIDERS
import '../providers/dataprovider.dart';
import '../providers/profile_provider.dart';

//SCREENS
import 'profilepage.dart';

import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

//MODELS
import '../models/linechart_hr.dart';
import '../models/widgetCSE.dart';
import '../models/weeklyexercise.dart';

//UTILS
import '../utils/healthscore.dart';

class DataScreen extends StatefulWidget {
  DataScreen({Key? key}) : super(key: key);

  @override
  State<DataScreen> createState() => DataState();
}

class DataState extends State<DataScreen> {
  bool _showWeeklyProgress = false;
  String? name;
  String? gender;

  @override
  void initState() {
    super.initState();
    // Download the profile data when the widget is initialized
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    profile.loadFromPrefs();

    // Download daily data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DataProvider>(
        context,
        listen: false,
      ).getDataOfDay(DateTime.now().subtract(Duration(days: 1)));
    });
  }

  void _hideWeeklyProgressOverlay() {
    setState(() {
      _showWeeklyProgress = false;
    });
  }

  void _showWeeklyProgressOverlay() {
    setState(() {
      _showWeeklyProgress = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 250, 239, 221),
                Color.fromARGB(255, 246, 229, 201),
                Color.fromARGB(255, 254, 221, 169),
              ],
            ),
          ),
          child: Scaffold(
            //BACKGROUND COLOR
            backgroundColor: Colors.transparent,

            //APPBAR
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 36, 84, 44),
              toolbarHeight: 70,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30), // Rounded corners for the bottom
                ),
              ),
              title: Consumer2<ProfileProvider, DataProvider>(
                builder: (context, profile, data, _) {
                  final name = profile.name.isNotEmpty ? profile.name : 'User';
                  final gender = profile.gender;

                  return Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween, // Space between text and image
                    children: [
                      Column(
                        children: [
                          Text(
                            'Hello, $name!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // To make the image iterative
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfilePage(),
                            ),
                          ); // Reload preferences
                        },

                        // To manage the image based on gender
                        child: Image.asset(
                          gender == 'F'
                              ? 'immagini/avatar_F.png'
                              : gender == 'M'
                              ? 'immagini/avatar_M.png'
                              : 'immagini/avatar_null.png', // if gender isn't M or F
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(top: 28, left: 20, right: 20),
                  child: Column(
                    children: [
                      const Text(
                        'Daily Data',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 30,
                        ),
                      ),

                      SizedBox(height: 10),

                      Consumer<DataProvider>(
                        builder: (context, provider, child) {
                          // SingleChildScrollView is used to make the screen scrollable
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 30),
                                      // InkWell widget is used to make the icons clickable
                                      child: InkWell(
                                        onTap: () {
                                          // Function that calls the provider function passing the date before the current date
                                          provider.getDataOfDay(
                                            provider.currentDate.subtract(
                                              const Duration(days: 1),
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.navigate_before,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'EEE, d MMM',
                                      ).format(provider.currentDate),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 30),
                                      child: InkWell(
                                        onTap: () {
                                          // Function that calls the provider function passing the date after the current date
                                          provider.getDataOfDay(
                                            provider.currentDate.add(
                                              const Duration(days: 1),
                                            ),
                                          );
                                        },
                                        child: const Icon(Icons.navigate_next),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20),

                                // Score text
                                Consumer2<ProfileProvider, DataProvider>(
                                  builder: (context, profile, data, _) {
                                    final score =
                                        calculateNutritionScoreFromProviders(
                                          profile: profile,
                                          data: data,
                                        );

                                    final scoreText =
                                        '${score.toStringAsFixed(0)}% Nutrition Health Score';

                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                          255,
                                          182,
                                          238,
                                          197,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '❤️ ',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            scoreText,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        // Show the heart rate chart (empty if loading)
                                        LineChartHr(
                                          hrData: provider.heartRates,
                                          loading: provider.loading,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 30,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildStatBox(
                                        icon: Icons.local_fire_department,
                                        label: 'Calories',
                                        value:
                                            provider.loading
                                                ? ''
                                                : (provider
                                                        .calories_data
                                                        .isEmpty
                                                    ? 'No data'
                                                    : '${provider.calories_data.fold<int>(0, (sum, s) => sum + s.value)}'),
                                        unit:
                                            provider.loading
                                                ? ''
                                                : (provider
                                                        .calories_data
                                                        .isEmpty
                                                    ? ''
                                                    : 'kcal'),
                                        color: Colors.deepOrangeAccent,
                                        isLoading: provider.loading,
                                      ),
                                      const SizedBox(width: 1),
                                      buildStatBox(
                                        icon: Icons.directions_walk,
                                        label: 'Steps',
                                        value:
                                            provider.loading
                                                ? ''
                                                : (provider.steps_data.isEmpty
                                                    ? 'No data'
                                                    : '${provider.steps_data.fold<int>(0, (sum, s) => sum + s.value)}'),
                                        color: Colors.blueAccent,
                                        isLoading: provider.loading,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: buildExerciseCard(
                                    provider.exercises,
                                    provider.loading,
                                    _showWeeklyProgressOverlay, // Show weekly progress overlay
                                  ),
                                ),
                                const SizedBox(height: 60),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // FloatingActionButton to show weekly progress
        if (_showWeeklyProgress)
          WeeklyProgressOverlay(
            onClose: _hideWeeklyProgressOverlay,
            selectedDate:
                Provider.of<DataProvider>(context, listen: false).currentDate,
          ),
      ],
    );
  }
}
