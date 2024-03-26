import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudySession {
  String? sessionId;
  String courseId;
  String userId;
  String topic;
  DateTime date;
  TimeOfDay time;
  String city; // Added city field
  String fullLocation; // Added fullLocation field
  String? description; // Added description field
  bool isRecurring;
  int participantNumber;
  List<String> participantIDs;

  StudySession({
    this.sessionId,
    required this.courseId,
    required this.userId,
    required this.topic,
    required this.date,
    required this.time,
    required this.city, // Initialize city
    required this.fullLocation, // Initialize fullLocation
    this.description, // Initialize description
    required this.isRecurring,
    this.participantNumber = 1, // Default value for participantNumber
    List<String>? participantIDs, // Default value for participantIDs
  }) : this.participantIDs =
            participantIDs ?? [userId]; // Initialize participantIDs

  Map<String, dynamic> toMap() {
    // Combine date and time into a single DateTime object for storing
    DateTime fullDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return {
      'sessionId': sessionId, // You may or may not want to store sessionId
      'courseId': courseId,
      'userId': userId,
      'topic': topic,
      'dateTime': Timestamp.fromDate(fullDateTime), // Store as Timestamp
      'city': city, // Store city
      'fullLocation': fullLocation, // Store full location
      'description': description, // Store description
      'isRecurring': isRecurring,
      'participantNumber': participantNumber,
      'participantIDs': participantIDs,
    };
  }

  static StudySession fromFirestore(
      Map<String, dynamic> data, String documentId) {
    return StudySession(
      sessionId: documentId,
      courseId: data['courseId'],
      userId: data['userId'],
      topic: data['topic'],
      date: (data['dateTime'] as Timestamp).toDate(),
      time: TimeOfDay.fromDateTime((data['dateTime'] as Timestamp).toDate()),
      city: data['city'], // Extract city
      fullLocation: data['fullLocation'], // Extract full location
      description: data['description'], // Extract description
      isRecurring:
          data['isRecurring'] ?? false, // Ensure a default value is provided
      participantNumber:
          data['participantNumber'] ?? 1, // Default to 1 if not provided
      participantIDs:
          List<String>.from(data['participantIDs'] ?? []), // Ensure list type
    );
  }
}
