import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/firebase_options.dart';
import 'package:study_buddy_fl/home_pages/main_navigation.dart';
import 'package:study_buddy_fl/login_pages/forgot_pass_screen.dart';
import 'package:study_buddy_fl/login_pages/login.dart';
import 'package:study_buddy_fl/login_pages/signup.dart';
import 'package:study_buddy_fl/profile/profile_page.dart';
import 'package:study_buddy_fl/services/firebase_messaging.dart';
import 'package:study_buddy_fl/study/create_session_form.dart';
import 'package:study_buddy_fl/study/search_session.dart';
import 'package:study_buddy_fl/study/study_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Trying to initialize Firebase with the options for the current platform.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // If the initialization is successful, print a success message.
    print('Firebase connection successful');
  } catch (e) {
    // If an error occurs during Firebase initialization, print an error message.
    print('Firebase connection failed: $e');
  }
  FirebaseApi().initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Checking the authentication state
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return Login(); // If not signed in, show Login
            }
            return MainNavigation(); // If signed in, show Main Navigation
          }
          return Scaffold(
            body: Center(
              child:
                  CircularProgressIndicator(), // Show loading screen while checking auth state
            ),
          );
        },
      ),
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/main_navigation': (context) => MainNavigation(),
        '/search_sessions': (context) => SessionSearchForm(),
        '/reset_password': (context) => ResetPasswordPage(),
      },
    );
  }
}
