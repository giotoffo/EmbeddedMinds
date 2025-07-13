import 'package:flutter/material.dart';
import 'exercise.dart';
import '../utils/impact.dart';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';

// StatefulWidget for the Weekly Progress Overlay screen
class WeeklyProgressOverlay extends StatefulWidget {
  final VoidCallback onClose; // Callback to close the overlay
  final DateTime selectedDate; // Selected date for filtering weekly data

  const WeeklyProgressOverlay({
    Key? key,
    required this.onClose,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<WeeklyProgressOverlay> createState() => _WeeklyProgressOverlayState();
}

// State class for WeeklyProgressOverlay
class _WeeklyProgressOverlayState extends State<WeeklyProgressOverlay>
    with SingleTickerProviderStateMixin {
  // Animation controller and animations
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // Data and state variables
  List<Exercise> weeklyExercises = [];
  bool isLoading = true;
  Impact impact = Impact(); // Instance of the Impact utility

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Scale animation (for entry transition)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Opacity animation (for fade in)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadWeeklyData(); // Load weekly exercise data
    _animationController.forward(); // Start the entry animation
  }

  @override
  void dispose() {
    _animationController.dispose(); // Dispose animation controller
    super.dispose();
  }

  // Loads the user's exercise data for the selected week
  Future<void> _loadWeeklyData() async {
    try {
      final exercises = await impact.getWeeklyExerciseData(widget.selectedDate);
      setState(() {
        weeklyExercises = exercises;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading weekly data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Calculates aggregated statistics per activity (walk, run, bike)
  Map<String, Map<String, dynamic>> _calculateWorkoutStats() {
    Map<String, Map<String, dynamic>> stats = {
      'walk': {
        'count': 0,
        'totalTime': 0,
        'totalDistance': 0.0,
        'icon': Icons.directions_walk,
        'displayName': 'Walk',
      },
      'run': {
        'count': 0,
        'totalTime': 0,
        'totalDistance': 0.0,
        'icon': Icons.directions_run,
        'displayName': 'Run',
      },
      'bike': {
        'count': 0,
        'totalTime': 0,
        'totalDistance': 0.0,
        'icon': Icons.directions_bike,
        'displayName': 'Bike',
      },
    };

    // Iterate through exercises and aggregate data
    for (Exercise exercise in weeklyExercises) {
      String activityKey = _getActivityKey(exercise.activityName);
      if (stats.containsKey(activityKey)) {
        stats[activityKey]!['count']++;
        if (exercise.duration != null) {
          stats[activityKey]!['totalTime'] +=
              Duration(milliseconds: exercise.duration!).inMinutes;
        }
        if (exercise.distance != null) {
          stats[activityKey]!['totalDistance'] += exercise.distance!;
        }
      }
    }

    return stats;
  }

  // Maps various activity name variants to unified keys
  String _getActivityKey(String activityName) {
    switch (activityName.toLowerCase()) {
      case 'camminata':
        return 'walk';
      case 'corsa':
        return 'run';
      case 'bici':
        return 'bike';
      default:
        return 'walk'; // default fallback
    }
  }

  String _getWeekDateRange(DateTime selectedDate) {
    final startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final endOfWeek = selectedDate; //startOfWeek.add(const Duration(days: 6));

    String formatDate(DateTime date) {
      final day = date.day;
      final month = _monthName(date.month);
      return '$day $month';
    }

    return '${formatDate(startOfWeek)} - ${formatDate(endOfWeek)}';
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  // Assigns a unique color per activity type
  Color _getActivityColor(String activityKey) {
    switch (activityKey) {
      case 'walk':
        return Colors.green;
      case 'run':
        return Colors.red;
      case 'bike':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Reverse animation and trigger onClose callback
  void _closeOverlay() async {
    await _animationController.reverse();
    widget.onClose();
  }

  // UI build method
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              color: Colors.black.withOpacity(0.7 * _opacityAnimation.value),
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 250, 239, 221),
                          Color.fromARGB(255, 249, 228, 195),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'YOUR WEEK',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 36, 84, 44),
                                ),
                              ),
                              IconButton(
                                onPressed: _closeOverlay,
                                icon: Icon(
                                  Icons.close,
                                  color: Color.fromARGB(255, 36, 84, 44),
                                  size: 28,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // Subtitle
                          Text(
                            'Weekly Activity Summary',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            _getWeekDateRange(widget.selectedDate),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[700],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Show loading spinner or actual content
                          if (isLoading)
                            Container(
                              height: 200,
                              child: Center(
                                child: CupertinoActivityIndicator(radius: 12),
                              ),
                            )
                          else
                            _buildProgressContent(),

                          const SizedBox(height: 20),

                          // Summary at bottom
                          if (!isLoading && weeklyExercises.isNotEmpty)
                            _buildTotalSummary(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Builds the content of the progress panel
  Widget _buildProgressContent() {
    if (weeklyExercises.isEmpty) {
      // No data fallback
      return Container(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No workouts this week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Time to get active!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final stats = _calculateWorkoutStats();

    return Column(
      children: [
        // Circular progress indicators for each activity
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              stats.entries.map((entry) {
                final activityKey = entry.key;
                final activityStats = entry.value;
                final count = activityStats['count'] as int;
                final totalTime = activityStats['totalTime'] as int;
                final color = _getActivityColor(activityKey);

                return _buildProgressCircle(
                  icon: activityStats['icon'] as IconData,
                  label: activityStats['displayName'] as String,
                  count: count,
                  totalTime: totalTime,
                  color: color,
                );
              }).toList(),
        ),

        const SizedBox(height: 30),

        // Detailed stats
        _buildDetailedStats(stats),
      ],
    );
  }

  // Builds each circular progress indicator
  Widget _buildProgressCircle({
    required IconData icon,
    required String label,
    required int count,
    required int totalTime,
    required Color color,
  }) {
    // Calculate progress (max 7 workouts per week)
    double progress = count / 7.0;
    if (progress > 1.0) progress = 1.0;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
              ),

              // Progress circle
              CustomPaint(
                size: Size(80, 80),
                painter: CircularProgressPainter(
                  progress: progress,
                  color: color,
                  strokeWidth: 6,
                ),
              ),

              // Icon and workout count
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 24),
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),

        if (totalTime > 0)
          Text(
            '${totalTime}min',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
    );
  }

  // Detailed statistics for each activity
  Widget _buildDetailedStats(Map<String, Map<String, dynamic>> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 36, 84, 44),
            ),
          ),

          const SizedBox(height: 16),

          ...stats.entries.map((entry) {
            final activityStats = entry.value;
            final count = activityStats['count'] as int;
            final totalTime = activityStats['totalTime'] as int;
            final totalDistance = activityStats['totalDistance'] as double;
            final color = _getActivityColor(entry.key);

            if (count == 0) return SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activityStats['icon'] as IconData,
                      color: color,
                      size: 20,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activityStats['displayName'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '$count sessions',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (totalTime > 0) ...[
                              Text(
                                ' • ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '${totalTime}min',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            if (totalDistance > 0) ...[
                              Text(
                                ' • ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '${totalDistance.toStringAsFixed(1)}km',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Summary section showing total workouts, time, and calories
  Widget _buildTotalSummary() {
    final totalWorkouts = weeklyExercises.length;
    final totalTime = weeklyExercises
        .where((e) => e.duration != null)
        .fold<int>(
          0,
          (sum, e) => sum + Duration(milliseconds: e.duration!).inMinutes,
        );
    final totalCalories = weeklyExercises
        .where((e) => e.calories != null)
        .fold<int>(0, (sum, e) => sum + e.calories!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 36, 84, 44).withOpacity(0.1),
            Color.fromARGB(255, 36, 84, 44).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color.fromARGB(255, 36, 84, 44).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem('Workouts', '$totalWorkouts', Icons.fitness_center),
          _buildSummaryItem('Minutes', '$totalTime', Icons.timer),
          if (totalCalories > 0)
            _buildSummaryItem(
              'Calories',
              '$totalCalories',
              Icons.local_fire_department,
            ),
        ],
      ),
    );
  }

  // Helper to build one item in total summary
  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color.fromARGB(255, 36, 84, 44), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 36, 84, 44),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

// Custom painter that draws a circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
