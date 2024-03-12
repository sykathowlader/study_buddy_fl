import 'package:flutter/material.dart';

enum StudyLevel { undergraduate, postgraduate }

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
        RadioListTile<StudyLevel>(
          title: const Text('Undergraduate'),
          value: StudyLevel.undergraduate,
          groupValue: _selectedStudyLevel,
          onChanged: (StudyLevel? value) {
            setState(() {
              _selectedStudyLevel = value;
            });
            widget.onSelectionChanged(value);
          },
        ),
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
