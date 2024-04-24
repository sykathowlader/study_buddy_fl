import 'package:flutter/material.dart';
import 'package:study_buddy_fl/home_pages/main_navigation.dart';
import 'package:study_buddy_fl/study/create_session_form.dart';
import 'package:study_buddy_fl/study/option_card.dart';
import 'package:study_buddy_fl/study/search_session.dart';
import 'package:study_buddy_fl/study/upcoming_session.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate the height dynamically based on the screen size
    double cardHeight = MediaQuery.of(context).size.height *
        0.25; // Adjust this value to change the card's height

    return Scaffold(
      appBar: AppBar(
        title: Text("Study Sessions"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              height: cardHeight, // Apply dynamic height
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1, // Takes half of the space
                    child: OptionCard(
                      title: "Join a Session",
                      color: Colors.blue.shade300, // Example color
                      onTap: () {
                        Navigator.pushNamed(context, '/search_sessions');
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1, // Takes half of the space
                    child: OptionCard(
                      title: "Create a Session",
                      color: Colors.green.shade300, // Example color
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: MediaQuery.of(context)
                                  .viewInsets, // Adjusts padding for the keyboard
                              child:
                                  CreateSessionForm(), // Pass the session to be edited
                            );
                          },
                        );
                        // Placeholder for onTap function
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              // Placeholder for the upcoming sessions list
              //color: Color.fromARGB(255, 208, 220, 209),
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: UpcomingSessionsList(
                showJoinButton: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
