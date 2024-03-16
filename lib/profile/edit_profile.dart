import 'package:flutter/material.dart';

class EditProfileDialog {
  static void showEditDialog({
    required BuildContext context,
    required TextEditingController fullNameController,
    required TextEditingController emailController,
    required TextEditingController universityController,
    required TextEditingController courseController,
    required TextEditingController studyLevelController,
    required Function onSave,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                    controller: fullNameController,
                    decoration: InputDecoration(labelText: 'Full Name')),
                TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email')),
                TextFormField(
                    controller: universityController,
                    decoration: InputDecoration(labelText: 'University')),
                TextFormField(
                    controller: courseController,
                    decoration: InputDecoration(labelText: 'Course')),
                TextFormField(
                    controller: studyLevelController,
                    decoration: InputDecoration(labelText: 'Study Level')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop()),
            TextButton(child: Text('Save'), onPressed: () => onSave()),
          ],
        );
      },
    );
  }
}
