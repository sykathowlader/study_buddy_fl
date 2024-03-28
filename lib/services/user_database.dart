import "package:cloud_firestore/cloud_firestore.dart";
import "package:study_buddy_fl/search/user_model.dart";
import "package:study_buddy_fl/study/study_session_model.dart";

class UserDatabase {
  final String uid;

  UserDatabase({required this.uid});

  //collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserData({
    required String fullName,
    required String email,
    required String university,
    required String course,
    required String studyLevel,
  }) async {
    Map<String, dynamic> userData = {
      'fullName': fullName,
      'email': email,
      'university': university,
      'course': course,
      'studyLevel': studyLevel,
      'fullNameKeywords': generateSearchKeywords(fullName),
      'universityKeywords': generateSearchKeywords(university),
      'courseKeywords': generateSearchKeywords(course),
    };

    await userCollection.doc(uid).set(userData);
  }

  Future<void> updateUserData({
    required String fullName,
    required String email,
    required String university,
    required String course,
    required String studyLevel,
  }) async {
    Map<String, dynamic> userData = {
      'fullName': fullName,
      'email': email,
      'university': university,
      'course': course,
      'studyLevel': studyLevel,
      'fullNameKeywords': generateSearchKeywords(fullName),
      'universityKeywords': generateSearchKeywords(university),
      'courseKeywords': generateSearchKeywords(course),
    };

    await userCollection.doc(uid).update(userData);
  }

  List<String> generateSearchKeywords(String input) {
    // Remove special characters, convert to lowercase, and split by spaces
    return input
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9\\s]'), '')
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  // Method to update user data
  /*  Future<void> updateUserData(
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
  } */

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

  Future<List<UserModel>> searchUsers(
      String fullName, String university, String course) async {
    Query<Map<String, dynamic>> query = _firestore.collection('users');

    if (fullName.isNotEmpty) {
      query = query
          .where('fullName', isGreaterThanOrEqualTo: fullName)
          .where('fullName', isLessThanOrEqualTo: fullName + '\uf8ff');
    }

    if (university.isNotEmpty) {
      query = query.where('university', isEqualTo: university);
    }

    if (course.isNotEmpty) {
      query = query.where('course', isEqualTo: course);
    }

    QuerySnapshot<Map<String, dynamic>> result = await query.get();
    return result.docs
        .map((doc) => UserModel.fromFirestore(doc.data()))
        .toList();
  }

  Stream<List<String>> getUserInterestsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('userInterests')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final interestsList = List.from(snapshot.data()?['interests'] ?? []);
      return interestsList.cast<String>();
    });
  }
}
