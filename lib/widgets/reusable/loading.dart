import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Set background color to white
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Use minimum space
          children: <Widget>[
            Image.asset(
              'assets/sb_logo.png', // Path to your logo asset
              height: 120, // Set a height for the logo
            ),
            SizedBox(height: 30), // Space between logo and loading bar
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey), // Set the color of the loading bar
            ),
          ],
        ),
      ),
    );
  }
}
