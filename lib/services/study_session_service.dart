import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/search/user_model.dart';
import 'package:study_buddy_fl/study/study_session_model.dart';

class StudySessionDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addStudySession(StudySession session) async {
    Map<String, dynamic> sessionData = session.toMap();
    // Generate all combinations
    sessionData['combinations'] = _generateSearchKeywords(
      session.courseId,
      session.topic,
      session.city,
    );
    DocumentReference ref = await FirebaseFirestore.instance
        .collection('studySessions')
        .add(sessionData);
    // Update the document with its ID if necessary
    await ref.update({'sessionId': ref.id});
  }

  Future<void> updateStudySession(
      String sessionId, StudySession session) async {
    Map<String, dynamic> sessionData = session.toMap();
    // Generate all combinations for updated session
    sessionData['combinations'] = _generateSearchKeywords(
      session.courseId,
      session.topic,
      session.city,
    );
    await FirebaseFirestore.instance
        .collection('studySessions')
        .doc(sessionId)
        .update(sessionData);
  }

  List<String> _generateSearchKeywords(
      String course, String topic, String city) {
    Set<String> keywords = {};
    // Break down each field into words and add them to the keywords set
    keywords.addAll(course.toLowerCase().split(' '));
    keywords.addAll(topic.toLowerCase().split(' '));
    keywords.addAll(city.toLowerCase().split(' '));

    // Generate all possible combinations of keywords to enhance searchability
    List<String> combinations = [];
    for (String keyword1 in keywords) {
      for (String keyword2 in keywords) {
        if (keyword1 != keyword2) {
          combinations.add('$keyword1 $keyword2');
        }
      }
      combinations.add(keyword1); // Also add the individual keyword
    }

    return combinations
        .toSet()
        .toList(); // Convert to list and remove duplicates
  }

  // New method to fetch study sessions created by a specific user
  Future<List<StudySession>> fetchUserStudySessions(String userId) async {
    QuerySnapshot querySnapshot = await _db
        .collection('studySessions')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return StudySession(
        courseId: data['courseId'],
        userId: data['userId'],
        topic: data['topic'],
        date: (data['dateTime'] as Timestamp).toDate(),
        time: TimeOfDay.fromDateTime((data['dateTime'] as Timestamp).toDate()),
        city: data['city'],
        isRecurring: data['isRecurring'],
        fullLocation: data['fullLocation'],
      );
    }).toList();
  }

  Stream<List<StudySession>> fetchUserStudySessionsStream(String userId) {
    return _db
        .collection('studySessions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudySession.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  Stream<List<StudySession>> fetchParticipatingStudySessionsStream(
      String userId) {
    return _db
        .collection('studySessions')
        .where('participantIDs', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StudySession.fromFirestore(
                doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

//  Stream<List<StudySession>> fetchParticipatingStudySessionsStream(String userId) {
//   return FirebaseFirestore.instance
//       .collection('studySessions')
//       .where('participantIDs', arrayContains: userId)
//       .snapshots()
//       .map((QuerySnapshot snapshot) {
//         List<StudySession> sessions = [];
//         for (var doc in snapshot.docs) {
//           var data = doc.data() as Map<String, dynamic>?;
//           if (data != null) { // Ensure data is not null
//             sessions.add(StudySession.fromFirestore(data, doc.id));
//           }
//         }
//         return sessions;
//       });
// }

  // method to delete a study session
  Future<void> deleteStudySession(String sessionId) async {
    await _db.collection('studySessions').doc(sessionId).delete();
  }

// method to retrieve participants from a session
  Future<List<UserModel>> fetchSessionParticipants(String sessionId) async {
    List<UserModel> participants = [];

    // First, get the session document to retrieve participantIds
    DocumentSnapshot sessionDoc = await FirebaseFirestore.instance
        .collection('studySessions')
        .doc(sessionId)
        .get();

    if (sessionDoc.exists) {
      List<String> participantIds =
          List<String>.from(sessionDoc['participantIDs']);

      // Then, fetch details for each participant
      for (String id in participantIds) {
        var userDoc =
            await FirebaseFirestore.instance.collection('users').doc(id).get();
        if (userDoc.exists) {
          UserModel user = UserModel.fromFirestore(userDoc.data()!);
          participants.add(user);
        }
      }
    }
    return participants;
  }
}
