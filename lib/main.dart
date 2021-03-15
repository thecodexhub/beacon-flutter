import 'package:beaconflutter/screens/landing_page.dart';
import 'package:beaconflutter/screens/map_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      routes: {
        '/mapScreen': (context) => MapScreen(),
      },
      home: LandingPage(),
    );
  }
}
