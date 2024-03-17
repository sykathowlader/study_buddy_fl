import 'package:flutter/material.dart';

class EditProfileDialog {
  static void showEditDialog({
    required BuildContext context,
    required TextEditingController fullNameController,
    required TextEditingController emailController,
    required TextEditingController universityController,
    required TextEditingController courseController,
    required String currentStudyLevel,
    required Function(String, String, String, String, String) onSave,
  }) {
    // Initialize form key
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    List<String> _studyLevelOptions = ['undergraduate', 'postgraduate'];
    String? _selectedStudyLevel = currentStudyLevel;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey, // Associate Form with GlobalKey
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        controller: fullNameController,
                        decoration: InputDecoration(labelText: 'Full Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: universityController,
                        decoration: InputDecoration(labelText: 'University'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your University';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: courseController,
                        decoration: InputDecoration(labelText: 'Course'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a course';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedStudyLevel,
                        decoration: InputDecoration(labelText: 'Study Level'),
                        items: _studyLevelOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => _selectedStudyLevel = newValue);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your study level';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Perform form validation
                      onSave(
                        fullNameController.text,
                        emailController.text,
                        universityController.text,
                        courseController.text,
                        _selectedStudyLevel ?? '',
                      );
                      Navigator.of(context)
                          .pop(); // Close the dialog after saving
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
