import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/study/study_session_model.dart';
import 'package:study_buddy_fl/study/upcoming_session.dart';

class SessionSearchForm extends StatefulWidget {
  @override
  _SessionSearchFormState createState() => _SessionSearchFormState();
}

class _SessionSearchFormState extends State<SessionSearchForm> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _searchSessions() {
    // Pass controller values to performSearch
    var searchResultsStream = performSearch();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text("Search Results")),
        body: UpcomingSessionsList(customStream: searchResultsStream),
      ),
    ));
  }

  Stream<List<StudySession>> performSearch() {
    Query query = FirebaseFirestore.instance.collection('studySessions');

    List<String> searchTerms = [];
    if (_topicController.text.isNotEmpty) {
      searchTerms.add(_sanitizeAndCombineInputs(_topicController.text));
    }
    if (_courseController.text.isNotEmpty) {
      searchTerms.add(_sanitizeAndCombineInputs(_courseController.text));
    }
    if (_locationController.text.isNotEmpty) {
      searchTerms.add(_sanitizeAndCombineInputs(_locationController.text));
    }

    // Iterate through each search term and apply filters accordingly
    // This example assumes you're okay with fetching all data and then filtering in memory due to Firestore limitations
    // Remember: This approach might not be efficient for large datasets
    return query.snapshots().map((snapshot) {
      var sessions = snapshot.docs
          .map((doc) => StudySession.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (searchTerms.isEmpty) {
        return sessions;
      }

      return sessions.where((session) {
        var combinedSessionTerms = _sanitizeAndCombineInputs(
            '${session.courseId} ${session.topic} ${session.city}');
        // Return sessions where any of the search terms is a match
        return searchTerms.any((term) => combinedSessionTerms.contains(term));
      }).toList();
    });
  }

  String _sanitizeAndCombineInputs(String input) {
    // Remove commas and spaces, and convert to lowercase for broad matching
    return input.toLowerCase().replaceAll(RegExp('[^A-Za-z0-9]'), '');
  }

  /* Stream<List<StudySession>> performSearch() {
    Query query = FirebaseFirestore.instance.collection('studySessions');

    // Transform the input text for searching: lowercase and remove commas and spaces for broad matching.
    String formatSearchText(String text) {
      return text.toLowerCase().replaceAll(',', '').replaceAll(' ', '');
    }

    // Check if topic search text is provided and not empty
    if (_topicController.text.isNotEmpty) {
      String searchTopic = formatSearchText(_topicController.text);
      query = query.where('combinations', arrayContains: searchTopic);
    }

    // Check if course search text is provided and not empty
    if (_courseController.text.isNotEmpty) {
      String searchCourse = formatSearchText(_courseController.text);
      query = query.where('combinations', arrayContains: searchCourse);
    }

    // Check if university (or location in this context) search text is provided and not empty
    if (_locationController.text.isNotEmpty) {
      String searchUniversity = formatSearchText(_locationController.text);
      query = query.where('combinations', arrayContains: searchUniversity);
    }

    // The return statement remains unchanged, mapping the snapshot documents to your StudySession model.
    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => StudySession.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Sessions'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Find Your Study Session",
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 20),
            _buildTextField(_courseController, 'Course', Icons.book),
            SizedBox(height: 16),
            _buildTextField(_topicController, 'Topic', Icons.topic),
            SizedBox(height: 16),
            _buildTextField(_locationController, 'City', Icons.location_on),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: _searchSessions,
                child: Text('Search', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Enter $label',
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _courseController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
