//import to convert variable's type
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

//import class
import '../models/heart_rate.dart';
import '../models/steps.dart';
import '../models/exercise.dart';
import '../models/calories.dart';

//import to use tokens and SP
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Impact {
  static String baseurl = 'https://impact.dei.unipd.it/bwthw/';
  static String pingEndPoint = 'gate/v1/ping/';
  static String tokenEndPoint = 'gate/v1/token/';
  static String refreshEndPoint = 'gate/v1/refresh/';

  static String impactUsername = 'Jpefaq6m58';

  //....REFRESH TOKEN....
  Future<int> refreshTokens() async {
    //asyncronous method
    final url = Impact.baseurl + Impact.refreshEndPoint;
    final sp = await SharedPreferences.getInstance();
    final refresh = sp.getString('refresh');
    if (refresh != null) {
      final body = {'refresh': refresh};

      //Get the response
      final response = await http.post(Uri.parse(url), body: body);

      //DEBUG
      print('Calling url: $url');
      print('Refresh token status: ${response.statusCode}');

      //If response is OK, save the new tokens in SharedPreferences
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final sp = await SharedPreferences.getInstance();
        await sp.setString('access', decodedResponse['access']);
        await sp.setString('refresh', decodedResponse['refresh']);
      }
      //Just return the status code
      return response.statusCode;
    }
    return 401;
  }

  //....GET TOKEN....
  static Future<int> getTokens(String username, String password) async {
    final url = Impact.baseurl + Impact.tokenEndPoint;
    final body = {'username': username, 'password': password};

    //Get the response
    final response = await http.post(Uri.parse(url), body: body);

    //DEBUG
    print('Calling: $url');
    print('Calling: ${response.statusCode}');

    //If response is OK (=200), store the tokens in SharedPreferences
    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);
      final sp = await SharedPreferences.getInstance();
      await sp.setString('access', decodedResponse['access']);
      await sp.setString('refresh', decodedResponse['refresh']);
    }
    return response.statusCode;
  } //getAndStoreTokens

  //...CHECK TOKEN...
  Future<String?> getValidAccessToken() async {
    final sp = await SharedPreferences.getInstance();
    var access = sp.getString('access');

    if (access != null && JwtDecoder.isExpired(access)) {
      await refreshTokens();
      access = sp.getString('access');
    }
    return access;
  }

  //____GET AND WORK WITH DATA_____
  Future<List<HR>> getHRData(DateTime date) async {
    List<HR> result = [];

    final access = await getValidAccessToken();

    if (access == null) {
      // Se non hai un token valido, esci con lista vuota o errore
      return result;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url =
        Impact.baseurl +
        'data/v1/heart_rate/patients/' +
        Impact.impactUsername +
        '/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //DEBUG
    print('Date: $impactUsername');
    print('Calling url x HR data: $url');

    final response = await http.get(Uri.parse(url), headers: headers);
    print('HR data status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      // DEBUG: stampa tutto per capire se ci sono dati
      print("Decoded response: $decodedResponse");

      //DEBUG
      /*       print(decodedResponse['data']['date']);
      print(decodedResponse['data']['data'][0]);
      print(decodedResponse['data']['data'][0].runtimeType); */

      //get data
      for (var i = 0; i < decodedResponse['data']['data'].length; i++) {
        result.add(
          HR.fromJson(
            decodedResponse['data']['date'],
            decodedResponse['data']['data'][i],
          ),
        );
      } //for
    }
    return result;
  } //_getHRData

  //.... MANAGE STEP DATA ....
  Future<List<Steps>> getStepsData(DateTime date) async {
    List<Steps> result = [];

    final access = await getValidAccessToken();

    if (access == null) {
      // Se non hai un token valido, esci con lista vuota o errore
      return result;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url =
        Impact.baseurl +
        'data/v1/steps/patients/' +
        Impact.impactUsername +
        '/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //DEBUG
    print('Calling url x Steps data: $url');

    final response = await http.get(Uri.parse(url), headers: headers);
    print('Steps data status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      // DEBUG: stampa tutto per capire se ci sono dati
      print("Decoded response: $decodedResponse");

      // Se 'data' è una lista vuota, esci
      if (decodedResponse['data'] is List && decodedResponse['data'].isEmpty) {
        print("No step data available for date $formattedDate");
        return result;
      }

      // Altrimenti, supponiamo che 'data' sia un oggetto con 'date' e 'data'
      final dataMap = decodedResponse['data'];
      final dateString = dataMap['date'];
      final dataList = dataMap['data'];

      if (dataList == null || dataList.isEmpty) {
        print("No step data available for date $dateString");
        return result;
      }

      for (var i = 0; i < dataList.length; i++) {
        final item = dataList[i];
        try {
          result.add(Steps.fromJson(dateString, item));
        } catch (e) {
          print('Error $i: $e');
        }
      }
    }
    return result;
  } //_get_STEP_Data

  //.... MANAGE CALORIES DATA ....
  Future<List<Calories>> getCaloriesData(DateTime date) async {
    List<Calories> result = [];

    final access = await getValidAccessToken();

    if (access == null) {
      // Se non hai un token valido, esci con lista vuota o errore
      return result;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url =
        Impact.baseurl +
        'data/v1/calories/patients/' +
        Impact.impactUsername +
        '/day/$formattedDate/';
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    //DEBUG
    print('Calling url x Calories data: $url');

    final response = await http.get(Uri.parse(url), headers: headers);
    print('Calories data status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decodedResponse = jsonDecode(response.body);

      for (var i = 0; i < decodedResponse['data']['data'].length; i++) {
        final item = decodedResponse['data']['data'][i];

        try {
          result.add(Calories.fromJson(decodedResponse['data']['date'], item));
        } catch (e) {
          print('Error step $i: $e');
        }
      }

      //get data
      for (var i = 0; i < decodedResponse['data']['date'].length; i++) {
        result.add(
          Calories.fromJson(
            decodedResponse['data']['date'],
            decodedResponse['data']['data'][i],
          ),
        );
      } //for
    }
    return result;
  } //_get_CALORIES_Data

  //.... MANAGE EXERCISE DATA ....
  Future<List<Exercise>> getExerciseData(DateTime date) async {
    // Initialize empty result list
    List<Exercise> result = [];

    // Get valid access token
    final access = await getValidAccessToken();

    // If no valid token available, return empty list
    if (access == null) {
      return result;
    }

    // Format date to yyyy-MM-dd string
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Build the API endpoint URL for exercise data
    final url =
        Impact.baseurl +
        'data/v1/exercise/patients/' +
        Impact.impactUsername +
        '/day/$formattedDate/';

    // Set authorization header with Bearer token
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    // DEBUG: Print the URL being called
    print('Calling url for Exercise data: $url');

    // Make HTTP GET request to fetch exercise data
    final response = await http.get(Uri.parse(url), headers: headers);

    // DEBUG: Print response status code
    print('Exercise data status: ${response.statusCode}');

    // If request is successful (status code 200)
    if (response.statusCode == 200) {
      // Decode JSON response
      final decodedResponse = jsonDecode(response.body);

      // DEBUG: Print entire response to understand data structure
      print("Decoded response: $decodedResponse");
      print('Decoded response structure: $decodedResponse');
      print('Type of data: ${decodedResponse['data'].runtimeType}');

      // Check the actual structure of the response
      if (decodedResponse is Map<String, dynamic>) {
        // If the response is a Map, check for 'data' field
        if (decodedResponse.containsKey('data')) {
          var data = decodedResponse['data'];
          print('Data field type: ${data.runtimeType}');
          print('Data content: $data');

          // Check if data is a Map with expected structure
          if (data is Map<String, dynamic>) {
            // Expected structure: {'date': '2024-01-01', 'data': [...]}
            if (data.containsKey('date') && data.containsKey('data')) {
              String dataDate = data['date'];
              var exerciseList = data['data'];

              if (exerciseList is List) {
                print(
                  'Found ${exerciseList.length} exercise entries for date: $dataDate',
                );

                // Loop through each exercise entry
                for (var i = 0; i < exerciseList.length; i++) {
                  final item = exerciseList[i];
                  print('Exercise element $i: $item');

                  try {
                    // Create Exercise object from JSON data and add to result list
                    result.add(Exercise.fromJson(dataDate, item));
                  } catch (e) {
                    // Handle parsing errors gracefully
                    print('Error parsing exercise $i: $e');
                  }
                }
              } else {
                print(
                  'Exercise data is not a list: ${exerciseList.runtimeType}',
                );
              }
            } else {
              print('Data does not contain expected date/data structure');
              print('Available keys: ${data.keys.toList()}');
            }
          } else if (data is List) {
            // Alternative structure: data might be directly a list
            print('Data is directly a list with ${data.length} items');

            for (var i = 0; i < data.length; i++) {
              final item = data[i];
              print('Exercise element $i: $item');

              try {
                // Use the formatted date since we don't have it from response
                result.add(Exercise.fromJson(formattedDate, item));
              } catch (e) {
                print('Error parsing exercise $i: $e');
              }
            }
          } else if (data is String) {
            // If data is a string, it might be a special response (like "No data")
            print('Data is a string: $data');
            if (data.toLowerCase().contains('no data') || data.isEmpty) {
              print('No exercise data available for date: $formattedDate');
            } else {
              print('Unexpected string data format: $data');
            }
          } else {
            print('Unexpected data type: ${data.runtimeType}');
          }
        } else {
          print('Response does not contain data field');
          print('Available keys: ${decodedResponse.keys.toList()}');
        }
      } else if (decodedResponse is List) {
        // If the response is directly a list
        print(
          'Response is directly a list with ${decodedResponse.length} items',
        );

        for (var i = 0; i < decodedResponse.length; i++) {
          final item = decodedResponse[i];
          print('Exercise element $i: $item');

          try {
            result.add(Exercise.fromJson(formattedDate, item));
          } catch (e) {
            print('Error parsing exercise $i: $e');
          }
        }
      } else {
        print('Unexpected response structure: ${decodedResponse.runtimeType}');
      }
    } else {
      // DEBUG: Print error if request failed
      print('Failed to fetch exercise data. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    // Return list of Exercise objects (empty if no data or errors)
    return result;
  } // getExerciseData method

  //.... MANAGE WEEKLY EXERCISE DATA ....
  Future<List<Exercise>> getWeeklyExerciseData(DateTime selectedDate) async {
    // Initialize empty result list
    List<Exercise> result = [];

    // Get valid access token
    final access = await getValidAccessToken();

    // If no valid token available, return empty list
    if (access == null) {
      return result;
    }

    // Get current weekday (1 = Monday, 7 = Sunday)
    int weekday = selectedDate.weekday;

    // Start from monday of the current week
    DateTime startDate = selectedDate.subtract(Duration(days: weekday - 1));
    // Finish with today (included)
    DateTime endDate = selectedDate; //startDate.add(Duration(days: 6));

    // Format dates to yyyy-MM-dd string
    String formattedStartDate = DateFormat('yyyy-MM-dd').format(startDate);
    String formattedEndDate = DateFormat('yyyy-MM-dd').format(endDate);

    // If start == end (monday)
    if (formattedStartDate == formattedEndDate) {
      print('Start == End: fallback to single day call');
      return await getExerciseData(
        startDate,
      ); // use the function for single day
    }

    // If start != end: Build the API endpoint URL for exercise data with date range
    final url =
        Impact.baseurl +
        'data/v1/exercise/patients/' +
        Impact.impactUsername +
        '/daterange/start_date/$formattedStartDate/end_date/$formattedEndDate/';

    // Set authorization header with Bearer token
    final headers = {HttpHeaders.authorizationHeader: 'Bearer $access'};

    // DEBUG: Print the dates and URL being called
    print(
      'Weekly Exercise Data - Start Date: $formattedStartDate, End Date: $formattedEndDate',
    );
    print('Calling url for Weekly Exercise data: $url');

    // Make HTTP GET request to fetch exercise data
    final response = await http.get(Uri.parse(url), headers: headers);

    // DEBUG: Print response status code
    print('Weekly Exercise data status: ${response.statusCode}');

    // If request is successful (status code 200)
    if (response.statusCode == 200) {
      // Decode JSON response
      final decodedResponse = jsonDecode(response.body);

      // DEBUG: Print entire response to understand data structure
      print("Weekly Exercise decoded response: $decodedResponse");

      // Check if data exists and has the expected structure
      if (decodedResponse['data'].isNotEmpty) {
        //capisci se null o isNotEmpty

        // The response structure for date range queries is typically a list of daily objects
        // Each daily object should have 'date' and 'data' fields

        if (decodedResponse['data'] is List) {
          // If data is a list of daily data objects
          for (var dayData in decodedResponse['data']) {
            if (dayData is Map<String, dynamic> &&
                dayData['date'] != null &&
                dayData['data'] != null) {
              String dayDate = dayData['date'];
              List<dynamic> dayExercises = dayData['data'];

              print(
                'Processing day: $dayDate with ${dayExercises.length} exercises',
              );

              // Process each exercise for this day
              for (var i = 0; i < dayExercises.length; i++) {
                final exerciseItem = dayExercises[i];
                print('Weekly Exercise element $i for $dayDate: $exerciseItem');

                try {
                  // Create Exercise object using the day's date
                  result.add(Exercise.fromJson(dayDate, exerciseItem));
                } catch (e) {
                  print('Error parsing weekly exercise $i for $dayDate: $e');
                }
              }
            }
          }
        } else if (decodedResponse['data'] is Map) {
          // If data has a single nested structure (fallback case)
          Map<String, dynamic> dataMap = decodedResponse['data'];

          if (dataMap['date'] != null && dataMap['data'] != null) {
            String singleDate = dataMap['date'];
            List<dynamic> exercises = dataMap['data'];

            for (var i = 0; i < exercises.length; i++) {
              final item = exercises[i];
              print('Weekly Exercise element $i: $item');

              try {
                result.add(Exercise.fromJson(singleDate, item));
              } catch (e) {
                print('Error parsing weekly exercise $i: $e');
              }
            }
          }
        }
      } else {
        print(
          'No weekly exercise data found for period: $formattedStartDate to $formattedEndDate',
        );
      }
    } else {
      print(
        'Failed to fetch weekly exercise data. Status: ${response.statusCode}',
      );
      print('Response body: ${response.body}');
    }

    // Return list of Exercise objects (empty if no data or errors)
    return result;
  } // getWeeklyExerciseData method

  // Helper method to get readable week info for debugging/UI
  Map<String, dynamic> getCurrentWeekInfo() {
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday;

    DateTime startDate = now.subtract(Duration(days: currentWeekday - 1));
    DateTime endDate = now;

    return {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'weekType': 'Current week (up to today)',
      'hideDataForNow': false,
    };
  }
} //Impact
