import 'package:flutter/material.dart';
import 'screens/splashpage.dart';
import 'providers/profile_provider.dart';
import 'providers/dataprovider.dart';
import 'providers/voucherprovider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
      ],
      child: MaterialApp
      (home: SplashPage(),
      ),
    );
  }
}

