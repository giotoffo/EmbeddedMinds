import 'package:flutter/material.dart';
import 'datascreen.dart';
import 'map.dart';
import 'goalpage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  String? gender;
  String? name;

  //Load the gender and name when the widget is initialized
  @override
  void initState() {
    super.initState();
  }

  //TO CHANGE PAGE WHEN A BOTTON IS PRESSED
  int page = 0;

  Widget getPage(int page) {
    switch (page) {
      case 1:
        return GoalsPage(); // widget dei goals
      case 2:
        return DataScreen(); // widget della homepage
      case 3:
        return MapScreen(); // widget della mappa
      default:
        return DataScreen(); // pagina iniziale
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack( // SafeArea widget to avoid system UI overlaps
        children: [
          Positioned.fill(child: getPage(page)),

          // BOTTOM NAVIGATION BAR
          Positioned(
            left: 24.0,
            right: 24.0,
            bottom: 30,

            // Widget ClipRRect used to make rounded corners
            child: ClipRRect(
              borderRadius: BorderRadius.circular(90),

              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 36, 84, 44),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the icons
                  children: [
                    // To go to GoalScreen
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.emoji_events, size: 30, color:Color.fromARGB(255, 250, 239, 221)),
                        onPressed: () {
                          setState(() {
                            page = 1;
                          });
                        },
                      ),
                    ),

                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.home, size: 30, color: Color.fromARGB(255, 250, 239, 221),),
                        onPressed: () {
                          setState(() {
                            page = 2;
                          });
                        },
                      ),
                    ),

                    // To go to MapScreen
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.map, size: 30, color: Color.fromARGB(255, 250, 239, 221),),
                        onPressed: () {
                          setState(() {
                            page = 3;
                          });
                        },
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
  }
}
