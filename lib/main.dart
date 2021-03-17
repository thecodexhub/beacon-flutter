import 'package:beaconflutter/screens/landing_page.dart';
import 'package:beaconflutter/screens/carry_screen.dart';
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
        '/carryScreen': (context) => CarryScreen(),
      },
      home: LandingPage(),
    );
  }
}
