import "package:firebase_messaging/firebase_messaging.dart";

class FirebaseApi {
// create an instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

// function to initialize notifications
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    //fetch the FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    //print the token
    print('Token: + $fCMToken');
  }
}
