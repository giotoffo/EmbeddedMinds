import 'package:flutter/material.dart';

//MODELS
import '../models/exercise.dart';

//PLUG IN
import 'package:flutter/cupertino.dart';

// Widget to build a small stat box with icon, label, value, and optional unit
Widget buildStatBox({
  required IconData icon,
  required String label,
  required String value,
  String? unit,
  required Color color,
  bool isLoading = false,
}) {
  return Container(
    width: 150,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3), // Light shadow
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center contents vertically
      children: [
        Icon(icon, color: color, size: 30), // Display the icon
        const SizedBox(height: 8), // Spacing
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        isLoading
            ? const SizedBox(
              width: 18,
              height: 18,
              child: CupertinoActivityIndicator(radius: 10),
            )
            : Text(
              unit != null
                  ? '$value $unit'
                  : value, // Show value with unit if provided
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    value == 'No data'
                        ? Colors.grey
                        : Colors.black, // Gray text if no data
              ),
            ),
      ],
    ),
  );
}

// Widget to build a card showing a list of exercises with loading state and tap callback
Widget buildExerciseCard(
  List<Exercise> exercises,
  bool isLoading,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap, // Handle tap on the entire card
    child: Container(
      width: double.infinity, // Full width container
      margin: const EdgeInsets.symmetric(vertical: 3), // Vertical margin
      padding: const EdgeInsets.all(16), // Padding inside container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Light shadow
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align children to start horizontally
        children: [
          Row(
            children: [
              Text(
                '💪  Today\'s Workouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
              Spacer(), // Push next items to the end of the row

              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green[600]!),
                ),
                child: const Center(
                  child: Text(
                    '📈', //📅
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading) // Show loading spinner if loading
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CupertinoActivityIndicator(radius: 15),
              ),
            )
          else if (exercises.isEmpty) // Show message if no workouts
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sentiment_dissatisfied,
                    color: Colors.grey,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No workouts today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else // Show list of exercises
            Column(
              children:
                  exercises.map((exercise) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ), // Spacing between exercises
                      padding: const EdgeInsets.all(
                        16,
                      ), // Padding inside each exercise card
                      decoration: BoxDecoration(
                        color: Colors.grey[50], // Light background
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Rounded corners
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with activity name, time and calories
                          Row(
                            children: [
                              // Activity icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getActivityColor(
                                    exercise.activityName,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getActivityIcon(exercise.activityName),
                                  color: _getActivityColor(
                                    exercise.activityName,
                                  ),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Activity name and time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getActivityDisplayName(
                                        exercise.activityName,
                                      ),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Duration chip if available
                              if (exercise.duration != null)
                                _buildMetricChip(
                                  icon: Icons.timer,
                                  label: 'Duration',
                                  value:
                                      '${Duration(milliseconds: exercise.duration!).inMinutes} min',
                                  color: _getActivityColor(
                                    exercise.activityName,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          // Daily summary section shown only if there are multiple exercises and not loading
          if (!isLoading && exercises.length > 1) ...[
            const Divider(thickness: 1), // Divider line
            const SizedBox(height: 12),
            Text(
              'Daily Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem(
                  label: 'Workouts',
                  value: '${exercises.length}', // Number of workouts
                  color: Colors.green,
                ),
                if (exercises.any((e) => e.duration != null))
                  _buildSummaryItem(
                    label: 'Total Duration',
                    value:
                        '${exercises.where((e) => e.duration != null).fold<int>(0, (sum, e) => sum + Duration(milliseconds: e.duration!).inMinutes)} min',
                    color: Colors.green,
                  ),
              ],
            ),
          ],
        ],
      ),
    ),
  );
}

// Widget to build small chips showing a metric with icon, label, and value
Widget _buildMetricChip({
  required IconData icon,
  required String label,
  required String value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(
        0.1,
      ), // Light background color based on metric color
      borderRadius: BorderRadius.circular(20), // Rounded pill shape
      border: Border.all(
        color: color.withOpacity(0.3),
      ), // Border with partial opacity
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min, // Wrap tightly around content
      children: [
        Icon(icon, size: 16, color: color), // Metric icon
        const SizedBox(width: 6), // Spacing between icon and texts
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// Widget to build summary item with a value and label, vertically aligned
Widget _buildSummaryItem({
  required String label,
  required String value,
  required Color color,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
    ],
  );
}

// Helper method to get activity icon based on activity name (lowercased)
IconData _getActivityIcon(String activityName) {
  switch (activityName.toLowerCase()) {
    case 'corsa':
      return Icons.directions_run;
    case 'bici':
      return Icons.directions_bike;
    case 'camminata':
      return Icons.directions_walk;
    default:
      return Icons.fitness_center; // Default icon for other activities
  }
}

// Helper method to get activity color based on activity name
Color _getActivityColor(String activityName) {
  switch (activityName.toLowerCase()) {
    case 'corsa':
      return Colors.red;
    case 'bici':
      return Colors.blue;
    case 'camminata':
      return Colors.green;
    default:
      return Colors.purple;
  }
}

// Helper method to get a nicer display name for activities
String _getActivityDisplayName(String activityName) {
  switch (activityName.toLowerCase()) {
    case 'corsa':
      return 'Running';
    case 'bici':
      return 'Cycling';
    case 'camminata':
      return 'Walking';
    default:
      // Capitalize first letter by default
      return activityName.substring(0, 1).toUpperCase() +
          activityName.substring(1);
  }
}
