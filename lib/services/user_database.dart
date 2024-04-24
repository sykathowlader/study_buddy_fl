import "package:cloud_firestore/cloud_firestore.dart";
import "package:study_buddy_fl/search/user_model.dart";
import "package:study_buddy_fl/study/study_session_model.dart";

// methods to add, update users were mainly taken and adapted from Youtube Tutorial playlist of Net Ninja called Flutter & Firebase app build
class UserDatabase {
  final String uid;

  UserDatabase({required this.uid});

  //collection reference
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// adding a user to Firebase
  Future<void> createUserData({
    required String fullName,
    required String email,
    required String university,
    required String course,
    required String studyLevel,
  }) async {
    // Generate combined search keywords from fullName, university, and course
    List<String> searchKeywords =
        _generateSearchKeywords(fullName, university, course);

    Map<String, dynamic> userData = {
      'userId': uid,
      'fullName': fullName,
      'email': email,
      'university': university,
      'course': course,
      'studyLevel': studyLevel,
      'searchKeywords': searchKeywords, // Use combined search keywords
    };

    await userCollection.doc(uid).set(userData);
  }

// updating user details to firebse
  Future<void> updateUserData({
    required String fullName,
    required String email,
    required String university,
    required String course,
    required String studyLevel,
  }) async {
    // Generate combined search keywords from fullName, university, and course
    List<String> searchKeywords =
        _generateSearchKeywords(fullName, university, course);

    Map<String, dynamic> userData = {
      'fullName': fullName,
      'email': email,
      'university': university,
      'course': course,
      'studyLevel': studyLevel,
      'searchKeywords': searchKeywords, // Use combined search keywords
    };

    await userCollection.doc(uid).update(userData);
  }

  List<String> _generateSearchKeywords(
      String fullName, String university, String course) {
    Set<String> keywords = {};
    // Break down each field into words and add them to the keywords set
    keywords.addAll(fullName.toLowerCase().split(' '));
    keywords.addAll(university.toLowerCase().split(' '));
    keywords.addAll(course.toLowerCase().split(' '));

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

// method to get the stream of user interests.
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
