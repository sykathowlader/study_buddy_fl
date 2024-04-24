import 'package:flutter/material.dart';

enum StudyLevel { undergraduate, postgraduate }

// StudyLevelSelector is a StatefulWidget that allows users to select their study level.

class StudyLevelSelector extends StatefulWidget {
  final Function(StudyLevel?) onSelectionChanged;

  const StudyLevelSelector({super.key, required this.onSelectionChanged});

  @override
  State<StudyLevelSelector> createState() => _StudyLevelSelectorState();
}

class _StudyLevelSelectorState extends State<StudyLevelSelector> {
  StudyLevel? _selectedStudyLevel;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Select your study level:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        // Radio button for the Undergraduate option.
        RadioListTile<StudyLevel>(
          title: const Text('Undergraduate'),
          value: StudyLevel.undergraduate,
          groupValue: _selectedStudyLevel,
          // Update state and notify parent widget on change.
          onChanged: (StudyLevel? value) {
            setState(() {
              _selectedStudyLevel = value;
            });
            widget.onSelectionChanged(value);
          },
        ),
        // Radio button for the Postgraduate option.
        RadioListTile<StudyLevel>(
          title: const Text('Postgraduate'),
          value: StudyLevel.postgraduate,
          groupValue: _selectedStudyLevel,
          onChanged: (StudyLevel? value) {
            setState(() {
              _selectedStudyLevel = value;
            });
            widget.onSelectionChanged(value);
          },
        ),
      ],
    );
  }
}
