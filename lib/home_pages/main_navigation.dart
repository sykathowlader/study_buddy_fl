// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:study_buddy_fl/message/message_page.dart";
import "package:study_buddy_fl/profile/profile_page.dart";
import "package:study_buddy_fl/search/search_page.dart";
import "package:study_buddy_fl/services/auth.dart";
import "package:study_buddy_fl/study/search_session.dart";
import "package:study_buddy_fl/study/study_page.dart";

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int current_index = 0;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  void changePage(int index) {
    setState(() {
      current_index = index;
    });
  }

  // Get current user

  // list of all screen that are reacheable from the bottomNavigatorBar

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      //HomePage(),
      StudyPage(),
      SearchPage(),
      MessagePage(),
      ProfilePage(
        userId: _userId,
        isUserProfile: true,
        modifyInterest: true,
      ),
    ];
    return Scaffold(
      // using indexstack I am preserving the state of the pages.
      //If I navigate from search page to message page and then again to search page
      // I will see the state of search page as I left before.
      // The use of IndexStack was suggested from Net Ninja youtube tutorial in the playlist Flutter & Firebase app build
      body: IndexedStack(
        index: current_index,
        children: _pages,
      ), // Use dynamic page selection
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) => setState(() {
          current_index = index;
        }),
        currentIndex: current_index,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Study Session",
            backgroundColor: Colors.green[300],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
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
