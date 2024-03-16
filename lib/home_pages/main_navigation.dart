// ignore_for_file: prefer_const_constructors

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:study_buddy_fl/home_pages/home_page.dart";
import "package:study_buddy_fl/message/message_page.dart";
import "package:study_buddy_fl/profile/profile_page.dart";
import "package:study_buddy_fl/search/search_page.dart";
import "package:study_buddy_fl/services/auth.dart";
import "package:study_buddy_fl/study/study_page.dart";

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int current_index = 0;
  AuthService _authService = AuthService();

  // list of all screen that are reacheable from the bottomNavigatorBar
  Widget getCurrentPage() {
    String? userId = _authService.getCurrentUserId(); // Get current user ID

    switch (current_index) {
      case 0:
        return HomePage();
      case 1:
        return SearchPage();
      case 2:
        return StudyPage();
      case 3:
        return MessagePage();
      case 4:
        // Pass the userId to ProfilePage
        return ProfilePage(userId: userId ?? '');
      default:
        return HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // using indexstack I am preserving the state of the pages.
      //If I navigate from search page to message page and then again to search page
      // I will see the state of search page as I left before.
      body: getCurrentPage(), // Use dynamic page selection
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
          current_index = index;
        }),
        currentIndex: current_index,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.green[300],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
            backgroundColor: Colors.green[300],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Study Session",
            backgroundColor: Colors.green[300],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Message",
            backgroundColor: Colors.green[300],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profile",
            backgroundColor: Colors.green[300],
          ),
        ],
      ),
    );
  }
}
