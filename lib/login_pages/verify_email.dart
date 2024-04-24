import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Set up a periodic timer to check for email verification
    timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      // Force a user reload to update email verification status
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      // If the email has been verified, navigate to the main navigation
      if (user != null && user.emailVerified) {
        timer.cancel(); // Stop the timer
        Navigator.of(context).pushReplacementNamed('/main_navigation');
      }
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

// building the UI
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Your Email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  "We've sent you an email verification. Please check your email.",
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 121, 191, 123),
                    ),
                    onPressed: () async {
                      await user?.sendEmailVerification();
                    },
                    child: Text("Resend Email"),
                  ),
                  SizedBox(width: 20), // Spacing between the buttons
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 121, 191, 123),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text("Sign Out"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
