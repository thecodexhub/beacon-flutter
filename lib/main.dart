import 'package:beaconflutter/screens/landing_page.dart';
import 'package:beaconflutter/screens/carry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'beacon-flutter',
      debugShowCheckedModeBanner: false,
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
