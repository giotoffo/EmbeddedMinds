import 'package:flutter/material.dart';

//MODELS
import 'heart_rate.dart';

//PLUG IN
import 'package:intl/intl.dart';
import 'package:graphic/graphic.dart';
import 'package:flutter/cupertino.dart';

class LineChartHr extends StatelessWidget {
  const LineChartHr({Key? key, required this.hrData, required this.loading})
    : super(key: key);

  final List<HR> hrData;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    // Determine the content to display inside the container
    Widget content;
    // If loading, show a progress indicator
    if (loading) {
      content = CupertinoActivityIndicator(radius: 15);
    }
    // If no data is available, show a message
    else if (hrData.isEmpty && !loading) {
      content = const Text(
        'No heart rate data available',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      );
    } else if (hrData.isEmpty) {
      content = const Text(
        'No heart rate data available',
        style: TextStyle(fontSize: 14, color: Colors.grey),
      );
    }
    // Otherwise, show the chart
    else {
      final chartData =
          hrData.map((e) => {'time': e.timestamp, 'hr': e.value}).toList();

      final DateTime firstTimestamp = chartData.first['time'] as DateTime;
      final DateTime startDay = DateTime(
        firstTimestamp.year,
        firstTimestamp.month,
        firstTimestamp.day,
      );
      final DateTime endDay = startDay.add(const Duration(days: 1));

      // Create the chart with the data
      content = Chart(
        data: chartData,
        variables: {
          'time': Variable<Map<String, dynamic>, DateTime>(
            accessor: (map) => map['time'] as DateTime,
            scale: TimeScale(
              min: startDay,
              max: endDay,
              formatter: (time) => DateFormat.Hm().format(time),
            ),
          ),
          'hr': Variable<Map<String, dynamic>, num>(
            accessor: (map) => map['hr'] as num,
            scale: LinearScale(min: 40, max: 180),
          ),
        },
        marks: <Mark<Shape>>[
          LineMark(
            position: Varset('time') * Varset('hr'),
            shape: ShapeEncode(value: BasicLineShape(smooth: false)),
            size: SizeEncode(value: 0.5),
            color: ColorEncode(value: const Color(0xFF326F5E)),
          ),
        ],
        axes: [Defaults.horizontalAxis, Defaults.verticalAxis],
        selections: {
          'tap': PointSelection(dim: Dim.x), // Enable tap selection on X axis
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Heart Rate',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Expanded(child: Center(child: content)),
        ],
      ),
    );
  }
}
