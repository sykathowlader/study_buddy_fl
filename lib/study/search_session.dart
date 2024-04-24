import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/study/study_session_model.dart';
import 'package:study_buddy_fl/study/upcoming_session.dart';

// search page to join a session
class SessionSearchForm extends StatefulWidget {
  @override
  _SessionSearchFormState createState() => _SessionSearchFormState();
}

class _SessionSearchFormState extends State<SessionSearchForm> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  void _searchSessions() {
    if (_topicController.text.isEmpty &&
        _courseController.text.isEmpty &&
        _locationController.text.isEmpty) {
      // If all fields are empty, show a dialog/alert to inform the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Search Criteria Needed"),
            content:
                Text("Please enter a search criteria to find study sessions."),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    } else {
      // If there's at least one non-empty field, proceed with the search
      var searchResultsStream = performSearch();

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("Search Results")),
          body: UpcomingSessionsList(
            customStream: searchResultsStream,
            isEditable: false,
          ),
        ),
      ));
    }
  }

  Stream<List<StudySession>> performSearch() {
    Query query = FirebaseFirestore.instance.collection('studySessions');

    // Generate search keywords from the input fields
    List<String> searchKeywords = _generateSearchKeywords(
      _topicController.text,
      _courseController.text,
      _locationController.text,
    );

    if (searchKeywords.isNotEmpty) {
      // Adjust the query to use the 'searchKeywords' field for searching
      query = query.where('combinations', arrayContainsAny: searchKeywords);
    }

    // Execute the query and map the snapshots to StudySession objects
    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StudySession.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
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
