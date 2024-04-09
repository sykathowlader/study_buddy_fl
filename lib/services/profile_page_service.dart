import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:study_buddy_fl/search/user_model.dart';

class ProfilePageServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<List<UserModel>> fetchUserConnections(String userId) async {
    List<UserModel> connections = [];

    try {
      // Fetch the connection IDs for the current user
      DocumentSnapshot connectionDoc =
          await _firestore.collection('connections').doc(userId).get();

      if (connectionDoc.exists) {
        List<dynamic> connectionIds = connectionDoc['connectionsId'];

        // Fetch each connected user's details
        for (var id in connectionIds) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(id).get();

          if (userDoc.exists) {
            connections.add(UserModel.fromFirestore(
                userDoc.data() as Map<String, dynamic>));
          }
        }
      }
    } catch (e) {
      print("Error fetching user connections: $e");
    }

    return connections;
  }
}
