import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:study_buddy_fl/services/study_session_service.dart';
import 'package:study_buddy_fl/study/study_session_model.dart';

class CreateSessionForm extends StatefulWidget {
  final StudySession? session;
  const CreateSessionForm({super.key, this.session});

  @override
  _CreateSessionFormState createState() => _CreateSessionFormState();
}

class _CreateSessionFormState extends State<CreateSessionForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _courseController;
  late TextEditingController _topicController;
  late TextEditingController _cityController; // Controller for city
  late TextEditingController
      _fullLocationController; // New controller for full location
  late TextEditingController
      _descriptionController; // New controller for description
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _isRecurring;

  @override
  void initState() {
    super.initState();
    _courseController =
        TextEditingController(text: widget.session?.courseId ?? '');
    _topicController = TextEditingController(text: widget.session?.topic ?? '');
    _cityController = TextEditingController(text: widget.session?.city ?? '');
    _fullLocationController = TextEditingController(
        text: widget.session?.fullLocation ??
            ''); // Initialize with session fullLocation
    _descriptionController = TextEditingController(
        text: widget.session?.description ??
            ''); // Initialize with session description
    _selectedDate = widget.session?.date ?? DateTime.now();
    _selectedTime = widget.session?.time ?? TimeOfDay.now();
    _isRecurring = widget.session?.isRecurring ?? false;
  }

// UI of the form to create a session
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _courseController,
                decoration: InputDecoration(labelText: 'Course'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Please enter the course'
                    : null,
              ),
              TextFormField(
                controller: _topicController,
                decoration: InputDecoration(labelText: 'Topic'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Please enter the topic'
                    : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Please enter the city'
                    : null,
              ),
              TextFormField(
                controller: _fullLocationController,
                decoration: InputDecoration(labelText: 'Full Location'),
                validator: (value) => value != null && value.isEmpty
                    ? 'Please enter the full location'
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: null, // Allows input to wrap to a new line
              ),

              //selection of the date
              ListTile(
                title: Text(
                    'Date: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
              ),

              // selection of the time
              ListTile(
                title: Text('Time: ${_selectedTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null && pickedTime != _selectedTime) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
              ),
              SwitchListTile(
                title: Text('Recurring Session'),
                value: _isRecurring,
                onChanged: (bool value) {
                  setState(() => _isRecurring = value);
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final User? user = auth.currentUser;
                    final String uid = user?.uid ?? '';

                    if (uid.isNotEmpty) {
                      // Creating a session object here, common to both add and update operations.
                      final session = StudySession(
                        sessionId: widget.session
                            ?.sessionId, // This will be null if it's a new session
                        courseId: _courseController.text.trim(),
                        userId: uid,
                        topic: _topicController.text.trim(),
                        date: _selectedDate,
                        time: _selectedTime,
                        city: _cityController.text.trim(),
                        isRecurring: _isRecurring,
                        fullLocation: _fullLocationController.text.trim(),
                        description: _descriptionController.text.trim(),
                      );

                      if (widget.session == null) {
                        // If widget.session is null, it means we are adding a new session.
                        await StudySessionDatabase().addStudySession(session);
                      } else {
                        // If widget.session is not null, we are updating an existing session.

                        await StudySessionDatabase()
                            .updateStudySession(session.sessionId!, session);
                      }

                      Navigator.pop(context); // Close the form
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "You need to be logged in to create or update a session."),
                      ));
                    }
                  }
                },
                child: Text(widget.session == null
                    ? 'Create Session'
                    : 'Update Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _courseController.dispose();
    _topicController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
