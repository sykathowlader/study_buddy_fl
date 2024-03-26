import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/firebase_options.dart';
import 'package:study_buddy_fl/home_pages/main_navigation.dart';
import 'package:study_buddy_fl/login_pages/login.dart';
import 'package:study_buddy_fl/login_pages/signup.dart';
import 'package:study_buddy_fl/profile/profile_page.dart';
import 'package:study_buddy_fl/study/create_session_form.dart';
import 'package:study_buddy_fl/study/search_session.dart';
import 'package:study_buddy_fl/study/study_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Try to initialize Firebase with the options for the current platform.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // If the initialization is successful, print a success message.
    print('Firebase connection successful');
  } catch (e) {
    // If an error occurs during Firebase initialization, print an error message.
    print('Firebase connection failed: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
      routes: {
        '/login': (context) => Login(),
        '/signup': (context) => Signup(),
        '/main_navigation': (context) => MainNavigation(),
        '/search_sessions': (context) => SessionSearchForm(),
      },
    );
  }
}
