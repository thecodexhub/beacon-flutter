import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beacon Flutter'),
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/mapScreen');
              },
              child: Text('Carry the Beacon'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {},
              child: Text('Follow the Beacon'),
            ),
          ],
        ),
      ),
    );
  }
}
