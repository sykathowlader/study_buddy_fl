import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:study_buddy_fl/search/result_page.dart";
import "package:study_buddy_fl/search/user_model.dart";

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  void _search() async {
    List<UserModel> users = await searchUsers(
      _fullNameController.text,
      _universityController.text,
      _courseController.text,
    );

    // Navigate to your results page
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ResultsPage(users: users)),
    );
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
                onPressed: () {},
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

  searchUsers(String text, String text2, String text3) {}
}
