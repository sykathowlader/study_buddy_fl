import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class StorageService {
  final String uid;
  StorageService({required this.uid});

  final FirebaseStorage storage = FirebaseStorage.instance;

  // Method to upload profile image
  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      // Creating a reference to the location I want to upload to in Firebase Storage
      Reference ref = storage.ref('userProfiles/$uid/profilePicture.jpg');

      // Upload the file to Firebase Storage
      await ref.putFile(imageFile);

      // Once the image is uploaded, return the download URL
      return await ref.getDownloadURL();
    } catch (e) {
      print(e);
      return null; // Return null in case of error
    }
  }

  // Method to delete profile image
  Future<void> deleteProfileImage() async {
    try {
      Reference ref = storage.ref('userProfiles/$uid/profilePicture.jpg');
      await ref.delete();
    } catch (e) {
      print("Error deleting profile image: $e");
    }
  }
}
