import 'package:flutter/material.dart';
import 'package:study_buddy_fl/study/option_card.dart';

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
          SizedBox(
            height: cardHeight, // Apply dynamic height
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2, // Takes 2/3 of the space
                  child: OptionCard(
                    title: "Join a Session",
                    color: Colors.blue.shade300, // Example color
                    onTap: () {
                      // Placeholder for onTap function
                    },
                  ),
                ),
                Expanded(
                  flex: 1, // Takes 1/3 of the space
                  child: OptionCard(
                    title: "Create a Session",
                    color: Colors.green.shade300, // Example color
                    onTap: () {
                      // Placeholder for onTap function
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              // Placeholder for the upcoming sessions list
              color: Colors.green,
              alignment: Alignment.center,
              padding: EdgeInsets.all(16),
              child: Text(
                "Upcoming Study Sessions will be listed here",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
