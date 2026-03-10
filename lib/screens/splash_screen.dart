import 'package:flutter/material.dart';
import '../utils/constants.dart';


// This screen shows while Firebase is checking if there's a saved session.
// It only appears for about 1-2 seconds on startup.


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: kPrimaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Kigali',
              style: TextStyle(color: kAccentGold, fontSize: 42, fontWeight: FontWeight.bold)),
            Text('Directory',
              style: TextStyle(color: kTextPrimary, fontSize: 26)),
            SizedBox(height: 48),
            CircularProgressIndicator(color: kAccentGold),
          ],
        ),
      ),
    );
  }
}
