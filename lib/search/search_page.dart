import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:study_buddy_fl/search/result_page.dart';
import 'package:study_buddy_fl/search/user_model.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  Future<List<UserModel>> searchUsers(
      String fullName, String university, String course) async {
    // Create a query against the collection.
    Query query = FirebaseFirestore.instance.collection('users');

    // Generate search keywords from the input fields
    List<String> searchKeywords =
        _generateSearchKeywords(fullName, university, course);

    if (searchKeywords.isNotEmpty) {
      // This is a simplified example. In practice, you might need to handle this differently,
      // as Firestore does not support querying for multiple arrayContains in a single query.
      query = query.where('searchKeywords', arrayContainsAny: searchKeywords);
    }

    // Execute the query
    QuerySnapshot snapshot = await query.get();

    // Map the documents to UserModel
    return snapshot.docs
        .map((doc) =>
            UserModel.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
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

  void _search() async {
    // Check if all the fields are empty
    if (_fullNameController.text.isEmpty &&
        _universityController.text.isEmpty &&
        _courseController.text.isEmpty) {
      // Display a message to the user to enter search criteria
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Search Criteria Required"),
            content: Text("Please enter at least one search criteria."),
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
      // Proceed with the search if there's at least one non-empty field
      List<UserModel> users = await searchUsers(
        _fullNameController.text,
        _universityController.text,
        _courseController.text,
      );

      // Navigate to your results page
      if (users.isEmpty) {
        // If no users found, show a message or handle as needed
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("No Results Found"),
              content: Text("No users found matching the search criteria."),
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
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ResultsPage(users: users)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Find Study Buddies",
                style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 20),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _universityController,
              decoration: InputDecoration(
                labelText: 'University',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _courseController,
              decoration: InputDecoration(
                labelText: 'Course',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                onPressed: _search,
                child: Text('Search', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _courseController.dispose();
    super.dispose();
  }
}
