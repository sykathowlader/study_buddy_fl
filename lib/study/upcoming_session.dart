import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy_fl/services/study_session_service.dart';
import 'package:study_buddy_fl/study/create_session_form.dart';
import 'study_session_model.dart'; // Correct the import path according to your project structure

class UpcomingSessionsList extends StatelessWidget {
  final Stream<List<StudySession>>? customStream;
  final bool isEditable;
  final bool showJoinButton;
  const UpcomingSessionsList({
    Key? key,
    this.customStream,
    this.isEditable = true,
    this.showJoinButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    Stream<List<StudySession>> stream = customStream ??
        StudySessionDatabase().fetchParticipatingStudySessionsStream(userId!);

    // Check for user authentication
    if (userId == null) {
      return Center(child: Text("Please log in to view upcoming sessions."));
    }

    DateTime now = DateTime.now();
    return StreamBuilder<List<StudySession>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return Center(
              child: Text("No upcoming sessions found. Join or create one."));
        }

        List<StudySession> filteredSessions = snapshot.data!.where((session) {
          DateTime sessionDate = session.date;
          if (!session.isRecurring && sessionDate.isBefore(now)) {
            return false; // Exclude past, non-recurring sessions
          }
          if (session.isRecurring && sessionDate.isBefore(now)) {
            // Logic for recurring sessions to find the next occurrence
            int daysUntilNextSession =
                7 - (now.difference(sessionDate).inDays % 7);
            DateTime nextSessionDate =
                now.add(Duration(days: daysUntilNextSession));
            session.date = DateTime(nextSessionDate.year, nextSessionDate.month,
                nextSessionDate.day, session.time.hour, session.time.minute);
            return true;
          }
          return true; // Include future and recurring sessions
        }).toList();

        // After filtering, check if there are any upcoming sessions
        if (filteredSessions.isEmpty) {
          return Center(
              child: Text("No upcoming sessions found. Join or create one."));
        }

        return ListView.builder(
          itemCount: filteredSessions.length,
          itemBuilder: (context, index) {
            StudySession session = filteredSessions[index];
            bool isCurrentUserSession = session.userId == userId;
            bool isUserParticipating = session.participantIDs.contains(userId);

            return Card(
              color: Color.fromARGB(255, 187, 215, 188),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session title and topic
                    Text("${session.courseId}  --  ${session.topic}",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    // Date, time, and location
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                          "${DateFormat('dd-MM-yyyy').format(session.date)} at ${session.time.format(context)}\nCity: ${session.city}",
                          style: TextStyle(fontSize: 16)),
                    ),

                    // Full location
                    Text("Full Location: ${session.fullLocation}",
                        style: TextStyle(fontSize: 16)),
                    // Description, if available
                    if (session.description != null &&
                        session.description!.trim().isNotEmpty)
                      Text("Description: ${session.description}",
                          style: TextStyle(fontSize: 16)),
                    // Icons and buttons row

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showJoinButton && !isCurrentUserSession)
                          TextButton.icon(
                            icon: isUserParticipating
                                ? Icon(Icons.check, size: 20)
                                : Icon(Icons.add, size: 20),
                            label:
                                Text(isUserParticipating ? 'Joined' : 'Join'),
                            onPressed: () async {
                              if (!isUserParticipating) {
                                // Add current user ID to participantIDs and update participantNumber
                                await FirebaseFirestore.instance
                                    .collection('studySessions')
                                    .doc(session.sessionId)
                                    .update({
                                  'participantIDs':
                                      FieldValue.arrayUnion([userId]),
                                  'participantNumber': FieldValue.increment(1),
                                });
                              } else {
                                // Remove current user ID from participantIDs and decrement participantNumber
                                await FirebaseFirestore.instance
                                    .collection('studySessions')
                                    .doc(session.sessionId)
                                    .update({
                                  'participantIDs':
                                      FieldValue.arrayRemove([userId]),
                                  'participantNumber': FieldValue.increment(-1),
                                });
                              }
                              // You may also want to show a snackbar or refresh the list to reflect changes
                            },
                          ),
                        // Recurring session icon
                        if (session.isRecurring) Icon(Icons.repeat, size: 20),

                        // Participant info
                        GestureDetector(
                          onTap: () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 20),
                              Icon(Icons.person, size: 20), // Participant icon
                              SizedBox(
                                  width: 4), // Spacing between icon and text
                              Text('${session.participantNumber}',
                                  style: TextStyle(
                                      fontSize: 16)), // Number of participants
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Edit button
                        if (isCurrentUserSession && isEditable)
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled:
                                    true, // Set to true if your form is lengthy
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: MediaQuery.of(context)
                                        .viewInsets, // Adjusts padding for the keyboard
                                    child: CreateSessionForm(
                                        session:
                                            session), // Pass the session to be edited
                                  );
                                },
                              ).then((value) {
                                // Optionally, refresh the list of sessions if the edit was successful
                              });
                            },
                          ),
                        // Delete button
                        if (isCurrentUserSession && isEditable)
                          IconButton(
                              icon: Icon(Icons.delete, size: 20),
                              onPressed: () {
                                if (session.sessionId != null) {
                                  _confirmDeletion(context, session.sessionId!);
                                } else {
                                  // Handle the null case - e.g., show an error, or log it.
                                  // For instance, showing a SnackBar with an error message.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text("Error: Session ID is null.")),
                                  );
                                }
                              }),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeletion(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Do you want to delete this session?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // Dismiss the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Assuming deleteStudySession is implemented and takes the session ID
                await StudySessionDatabase().deleteStudySession(sessionId);
                Navigator.of(context)
                    .pop(); // Dismiss the dialog after deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
