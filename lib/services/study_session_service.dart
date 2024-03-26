import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/study/study_session_model.dart';

class StudySessionDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addStudySession(StudySession session) async {
    Map<String, dynamic> sessionData = session.toMap();
    // Generate all combinations
    sessionData['combinations'] = _generateCombinationsFromFields(
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
    sessionData['combinations'] = _generateCombinationsFromFields(
      session.courseId,
      session.topic,
      session.city,
    );
    await FirebaseFirestore.instance
        .collection('studySessions')
        .doc(sessionId)
        .update(sessionData);
  }

  List<List<T>> _generateSubsets<T>(List<T> list) {
    List<List<T>> result = [[]];
    for (T element in list) {
      List<List<T>> newSubsets = [];
      for (List<T> subset in result) {
        newSubsets.add(List.from(subset)..add(element));
      }
      result.addAll(newSubsets);
    }
    return result;
  }

  List<String> _generateCombinationsFromFields(
      String course, String topic, String city) {
    List<String> words = [
      ..._sanitizeString(course).split(' '),
      ..._sanitizeString(topic).split(' '),
      ..._sanitizeString(city).split(' '),
    ];
    words = words.toSet().toList(); // Remove duplicates
    List<List<String>> subsets = _generateSubsets(words);
    Set<String> combinations = {};
    for (List<String> subset in subsets) {
      if (subset.isNotEmpty) {
        combinations.add(subset.join(' '));
      }
    }
    return combinations.toList();
  }

  String _sanitizeString(String input) {
    return input.toLowerCase().replaceAll(RegExp('[^A-Za-z0-9 ]'), '').trim();
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

  Future<void> deleteStudySession(String sessionId) async {
    await _db.collection('studySessions').doc(sessionId).delete();
  }
}
