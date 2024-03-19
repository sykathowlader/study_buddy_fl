import "package:cloud_firestore/cloud_firestore.dart";
import "package:study_buddy_fl/study/study_session_model.dart";

class UserDatabase {
  final String uid;

  UserDatabase({required this.uid});

  //collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  // Method to update user data
  Future<void> updateUserData(
      {required String fullName,
      required String email,
      required String university,
      required String course,
      required String studyLevel}) async {
    return await userCollection.doc(uid).update({
      'fullName': fullName,
      'email': email,
      'university': university,
      'course': course,
      'studyLevel': studyLevel,
    });
  }

  Future<void> createUserData(
      {required String fullName,
      required String email,
      required String university,
      required String course,
      required String studyLevel}) async {
    return await userCollection.doc(uid).set({
      'fullName': fullName,
      'email': email,
      'university': university,
      'course': course,
      'studyLevel': studyLevel,
    });
  }

// Method to update profile image URL in user document
  Future<void> updateUserProfileImageUrl(String imageUrl) async {
    return await userCollection.doc(uid).update({
      'profileImageUrl': imageUrl,
    });
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Future<void> addStudySession(StudySession session) async {
    await _db.collection('studySessions').add(session.toMap());
  }
}
