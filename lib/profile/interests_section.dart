import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InterestsSection extends StatefulWidget {
  final List<String> initialInterests;
  final String userId;

  const InterestsSection({
    super.key,
    required this.initialInterests,
    required this.userId,
  });

  @override
  State<InterestsSection> createState() => _InterestSectionState();
}

class _InterestSectionState extends State<InterestsSection> {
  late List<String> interests;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    interests = List.from(widget.initialInterests);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: <Widget>[
            Expanded(child: Divider(thickness: 4)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Interests',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: Divider(thickness: 4)),
          ],
        ),
        SizedBox(height: 10), // Add some spacing
        Wrap(
          spacing: 8.0,
          children: interests
              .map((interest) => Chip(
                    label: Text(interest),
                    backgroundColor:
                        Colors.green[200], // Set chip background color
                    deleteIconColor:
                        Colors.white, // Set delete icon color if needed
                    onDeleted: () => _removeInterest(interest),
                  ))
              .toList(),
        ),
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Add interest',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _addInterest,
            ),
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }

  void _addInterest() {
    final interest = _controller.text.trim();
    if (interest.isNotEmpty && !interests.contains(interest)) {
      setState(() {
        interests.add(interest);
        _controller.clear();
      });
      _updateInterestsInFirestore();
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      interests.remove(interest);
    });
    _updateInterestsInFirestore();
  }

  Future<void> _updateInterestsInFirestore() async {
    await FirebaseFirestore.instance
        .collection('userInterests')
        .doc(widget.userId)
        .update({
      'interests': interests,
    });
  }
}
