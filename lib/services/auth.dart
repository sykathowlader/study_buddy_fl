import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy_fl/services/user_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up with email and password
  Future<String?> signUp(String email, String password, String fullName,
      String university, String course, String studyLevel) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Assuming the user was created, now I'm their info to Firestore
      // Extract the UID of the newly created user
      String uid = result.user!.uid;

      // Creating an instance of UserDatabase with the user's UID
      UserDatabase userDatabase = UserDatabase(uid: uid);

      // Call the method to update the user data in Firestore
      await userDatabase.updateUserData(
        fullName: fullName,
        email: email,
        university: university,
        course: course,
        studyLevel: studyLevel,
      );

      return null; // No error
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'The email address is already in use by another account.';
      } else {
        return e.message; // Generic error message
      }
    } catch (e) {
      //print(e.toString());
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
}
