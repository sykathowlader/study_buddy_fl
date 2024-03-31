import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePageServices {
  // Method to fetch the number of connections
  Future<int> fetchConnectionsCount() async {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('connections')
        .doc(currentUserId)
        .get();

    if (docSnapshot.exists && docSnapshot.data() is Map) {
      final Map<String, dynamic> data =
          docSnapshot.data() as Map<String, dynamic>;
      List<dynamic> connectionsId = data['connectionsId'] ?? [];
      return connectionsId.length; // Returns the count of connections
    }
    return 0; // Returns 0 if the document does not exist
  }
}
