import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy_fl/services/user_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //these methods were mainly taken and adapted from Youtube Tutorial playlist of Net Ninja called Flutter & Firebase app build
  // Sign up with email and password
  Future<String?> signUp(String email, String password, String fullName,
      String university, String course, String studyLevel) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      User? user = result.user;

      // Send email verification if user is created
      if (user != null) {
        await user.sendEmailVerification();

        // Store user info in Firestore
        String uid = user.uid;
        UserDatabase userDatabase = UserDatabase(uid: uid);
        await userDatabase.createUserData(
          fullName: fullName,
          email: email,
          university: university,
          course: course,
          studyLevel: studyLevel,
        );
        initializeUserInterests(uid);
      }

      return null; // No error
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'The email address is already in use by another account.';
      } else {
        return e.message; // Generic error message
      }
    } catch (e) {
      return 'An error occurred, please try again later.';
    }
  }

  // Sign in with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error);
      return null;
    }
  }

  // Method to get current user UID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<void> initializeUserInterests(String userId) async {
    await FirebaseFirestore.instance
        .collection('userInterests')
        .doc(userId)
        .set({
      'interests': [],
    });
  }

  // Method to send password reset email
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Return null if successful
    } on FirebaseAuthException catch (e) {
      return e.message; // Return error message if an exception occurs
    } catch (e) {
      return 'An error occurred, please try again later.'; // Return a generic error message for any other exceptions
    }
  }
}
