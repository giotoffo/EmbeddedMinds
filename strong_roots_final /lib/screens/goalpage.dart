import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dataprovider.dart';
import '../providers/profile_provider.dart';
import '../providers/voucherprovider.dart'; // Aggiungi questo import
import '../utils/healthscore.dart';
import '../utils/quotes.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';

class GoalsPage extends StatefulWidget {
  @override
  _GoalsPageState createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  DateTime selectedMonth = DateTime.now();
  Map<DateTime, double> dailyProgress = {};
  int currentStreak = 0;
  String nextVoucher = "";
  int nextVoucherCountdown = 0;
  int nextVoucherProgress = 0;
  Map<String, double> cachedProgress = {};

  // Variables for loading
  bool isLoading = false;
  bool voucherLoading = false;
  String currentLoadingQuote = "";
  Timer?
  _loadingTimer; // Class Timer to manage loading state is inside dart:async
  Timer? _quoteTimer;

  @override
  void initState() {
    super.initState();
    _generateMockProgressData();
    _calculateStreak();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel(); // Delete the timer if the widget is disposed
    _quoteTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateMockProgressData() async {
    // Start the loading timer
    _loadingTimer = Timer(Duration(milliseconds: 400), () {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          isLoading = true;
          currentLoadingQuote =
              RotatingQuotes.getRandomQuote(); // Get a random quote
        });
      }
    });

    _startQuoteRotation();

    try {
      final voucherProvider = Provider.of<VoucherProvider>(
        context,
        listen: false,
      );
      await voucherProvider.clearVouchers();
      final now = DateTime.now();
      final lastDayOfMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + 1,
        0,
      );

      final profileProvider = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      dailyProgress.clear();

      for (int day = 1; day <= lastDayOfMonth.day; day++) {
        final date = DateTime(selectedMonth.year, selectedMonth.month, day);

        if (date.isAfter(now)) continue;

        // Download data for the date (just once, then use cached values)
        await dataProvider.getDataOfDay(date);

        // Verify if data exists for the date
        final hasData = dataProvider.hasDataFor(date);

        if (!hasData) {
          dailyProgress[date] = 0;
          continue;
        }

        // Calculate the nutrition score for the date
        final score = calculateNutritionScoreFromProviders(
          profile: profileProvider,
          data: dataProvider, // Pass the data provider
        );

        dailyProgress[DateTime(date.year, date.month, date.day)] = score;
      }

      // Wait the dowload of _calculateStreak
      await _calculateStreak();
    } finally {
      _loadingTimer?.cancel(); // Cancel the timer
      _quoteTimer?.cancel(); // Cancel the quote timer

      if (mounted) {
        setState(() {
          isLoading = false;
          voucherLoading = false; // Stop loading voucher state
        });
      }
    }
  }

  // Method to start the quote rotation timer
  void _startQuoteRotation() {
    Timer(Duration(milliseconds: 10400), () {
      if (mounted && isLoading) {
        setState(() {
          currentLoadingQuote = RotatingQuotes.getRandomQuote();
        });

        _quoteTimer = Timer.periodic(Duration(seconds: 10), (timer) {
          if (mounted && isLoading) {
            setState(() {
              currentLoadingQuote = RotatingQuotes.getRandomQuote();
            });
          } else {
            timer
                .cancel(); // Stop the timer if the widget is not mounted or loading is false
          }
        });
      }
    });
  }

  void _changeMonth(int monthDelta) async {
    final voucherProvider = Provider.of<VoucherProvider>(
      context,
      listen: false,
    );
    await voucherProvider.clearVouchers(); // Clear vouchers when changing month
    setState(() {
      selectedMonth = DateTime(
        selectedMonth.year,
        selectedMonth.month + monthDelta,
      );
      // Reset daily progress and streak
      currentStreak = 0;
      nextVoucher = "";
      nextVoucherCountdown = 0;
      nextVoucherProgress = 0;
      voucherLoading = true; // Start loading voucher state
    });
    await _generateMockProgressData();
  }

  void _showVoucherDialog(BuildContext context, String voucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Here is your voucher',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset('immagini/qrcode.png', width: 200, height: 200),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _calculateStreak() async {
    final voucherProvider = Provider.of<VoucherProvider>(
      context,
      listen: false,
    );
    List<String> newEarnedVouchers = [];
    currentStreak = 0;

    final Map<String, int> monthlyHighScoreCount = {};

    for (final entry in dailyProgress.entries) {
      final date = entry.key;
      final progress = entry.value;
      final String monthKey =
          "${date.year}-${date.month.toString().padLeft(2, '0')}";

      if (progress >= 70) {
        monthlyHighScoreCount[monthKey] =
            (monthlyHighScoreCount[monthKey] ?? 0) + 1;
      }
    }

    // Generate vouchers based on monthly high scores
    for (final entry in monthlyHighScoreCount.entries) {
      if (entry.value >= 10) {
        final year = int.parse(entry.key.split('-')[0]);
        final month = int.parse(entry.key.split('-')[1]);

        final voucherDate = DateTime(year, month, 1);
        final voucherName = _generateVoucherName(voucherDate);

        if (!newEarnedVouchers.contains(voucherName)) {
          newEarnedVouchers.add(voucherName);
        }
      }
    }

    int countValidDays = 0;
    DateTime? firstValidDate;

    final sortedDates = dailyProgress.keys.toList()..sort();
    for (final date in sortedDates) {
      final progress = dailyProgress[date] ?? 0;
      if (progress >= 70) {
        countValidDays++;
        firstValidDate ??= date;

        // Add voucher every 10 valid days
        if (countValidDays % 10 == 0) {
          final voucherName = _generateVoucherName(firstValidDate);
          if (!newEarnedVouchers.contains(voucherName)) {
            newEarnedVouchers.add(voucherName);
          }
        }
      }
    }

    // Update vouchers
    await voucherProvider.setVouchers(newEarnedVouchers);

    // Calculate the progress towards the next voucher
    nextVoucherProgress = countValidDays % 10;
    nextVoucherCountdown = 10 - nextVoucherProgress;
    if (nextVoucherCountdown == 10) nextVoucherCountdown = 0;

    nextVoucher = _generateVoucherName(DateTime.now());

    DateTime checkDate = DateTime.now();
    currentStreak = 0;

    while (true) {
      final progress =
          dailyProgress[DateTime(
            checkDate.year,
            checkDate.month,
            checkDate.day,
          )] ??
          0;

      if (progress >= 70) {
        currentStreak++;
        checkDate = checkDate.subtract(Duration(days: 1));
      } else {
        break;
      }
    }
  }

  String _generateVoucherName(DateTime startDate) {
    final vouchers = ["€5 discount voucher in your favorite organic shop"];
    final index = (startDate.day + startDate.month) % vouchers.length;
    return vouchers[index];
  }

  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final startDate = firstDay.subtract(
      Duration(days: (firstDay.weekday - 1) % 7),
    );
    List<DateTime> days = [];
    DateTime currentDate = startDate;
    for (int i = 0; i < 42; i++) {
      days.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }
    return days;
  }

  Color _getProgressColor(double progress) {
    if (progress < 30) return Colors.red;
    if (progress < 70) return Colors.orange;
    return Colors.green;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  // Method for legend items
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final monthYear =
        "${_getMonthName(selectedMonth.month)} ${selectedMonth.year}";

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
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
        ),

        Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true, // ✅ aggiunto
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            toolbarHeight: 70,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            centerTitle: true,
            title: Text(
              'Goals Calendar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 36, 84, 44),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: Stack(
            // To overlay widgets or elements
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

                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Header with month
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => _changeMonth(-1),
                                  icon: Icon(Icons.chevron_left, size: 30),
                                ),
                                Text(
                                  monthYear,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _changeMonth(1),
                                  icon: Icon(Icons.chevron_right, size: 30),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 16),

                          // Weekday labels
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:
                                  [
                                        'Mon',
                                        'Tue',
                                        'Wed',
                                        'Thu',
                                        'Fri',
                                        'Sat',
                                        'Sun',
                                      ]
                                      .map(
                                        (day) => Container(
                                          width: 40,
                                          child: Center(
                                            child: Text(
                                              day,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Calendar
                          Container(
                            height: 300,
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 7,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: days.length,
                              itemBuilder: (context, index) {
                                final date = days[index];
                                final isCurrentMonth =
                                    date.month == selectedMonth.month;
                                final isToday = _isSameDay(
                                  date,
                                  DateTime.now(),
                                );
                                final progress =
                                    dailyProgress[DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                    )] ??
                                    0;

                                return Container(
                                  decoration: BoxDecoration(
                                    color:
                                        isToday
                                            ? Color.fromARGB(
                                              255,
                                              36,
                                              84,
                                              44,
                                            ).withOpacity(0.1)
                                            : Colors.white.withOpacity(
                                              isCurrentMonth ? 0.8 : 0.3,
                                            ),
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        isToday
                                            ? Border.all(
                                              color: Color.fromARGB(
                                                255,
                                                36,
                                                84,
                                                44,
                                              ),
                                              width: 2,
                                            )
                                            : null,
                                  ),
                                  child: Stack(
                                    children: [
                                      if (isCurrentMonth && progress > 0)
                                        Center(
                                          child: SizedBox(
                                            width: 35,
                                            height: 35,
                                            child: CircularProgressIndicator(
                                              value: progress / 100,
                                              strokeWidth: 3,
                                              backgroundColor: Colors.grey[300],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    _getProgressColor(progress),
                                                  ),
                                            ),
                                          ),
                                        ),

                                      if (isCurrentMonth && progress >= 70)
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Colors.amber,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.orange,
                                                width: 1,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.emoji_events,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                      Center(
                                        child: Text(
                                          '${date.day}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                                isToday
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color:
                                                isCurrentMonth
                                                    ? (isToday
                                                        ? Color.fromARGB(
                                                          255,
                                                          36,
                                                          84,
                                                          44,
                                                        )
                                                        : Colors.black87)
                                                    : Colors.grey[400],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 12),

                          // Legend section after the calendar
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Goals Progress',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildLegendItem(Colors.red, '0-30%'),
                                    _buildLegendItem(Colors.orange, '30-70%'),
                                    _buildLegendItem(
                                      Colors.green,
                                      '70-100%  🏆',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Streak & Progress Section
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Voucher countdown
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.card_giftcard,
                                      color: Color(0xFF4CAF50),
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Next Voucher',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 12),

                                if (nextVoucherCountdown > 0)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Color(
                                            0xFF4CAF50,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '$nextVoucherCountdown',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Text(
                                        '🏆 until your next reward',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),

                                SizedBox(height: 12),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress: $nextVoucherProgress/10 days',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${(nextVoucherProgress / 10 * 100).round()}%',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 8),

                                LinearProgressIndicator(
                                  value: nextVoucherProgress / 10,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF4CAF50),
                                  ),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Available vouchers
                          Builder(
                            builder: (context) {
                              if (voucherLoading || isLoading) {
                                return SizedBox.shrink();
                              }

                              final voucherProvider =
                                  Provider.of<VoucherProvider>(context);
                              final earnedVouchers =
                                  voucherProvider.earnedVouchers;

                              if (earnedVouchers.isEmpty) {
                                return SizedBox.shrink();
                              }

                              return Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF2E7D32),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.emoji_events,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Available Vouchers',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    ...earnedVouchers.map(
                                      (voucher) => GestureDetector(
                                        onTap:
                                            () => _showVoucherDialog(
                                              context,
                                              voucher,
                                            ),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 8),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                255,
                                                229,
                                                185,
                                                119,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.local_offer,
                                                color: Colors.orange,
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  voucher,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.orange[800],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  'ACTIVE',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          SizedBox(
                            height: 115,
                          ), // Extra space to avoid overflow
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isLoading)
                _buildLoadingOverlay(), // Show loading overlay if isLoading is true
            ],
          ),
        ),
      ],
    );
  }

  // Widget for loading overlay
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5), // Semi-transparent dark background
      child: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(radius: 14),

              SizedBox(height: 20),

              // Random quotes
              Text(
                '“$currentLoadingQuote”',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 36, 84, 44),
                  height: 1.5,
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Downloading data...",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
