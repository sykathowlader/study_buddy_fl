// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:study_buddy_fl/login_pages/verify_email.dart';
import 'package:study_buddy_fl/services/auth.dart';
import 'package:study_buddy_fl/widgets/signup_widgets/list_unis.dart';
import 'package:study_buddy_fl/widgets/reusable/loading.dart';
import 'package:study_buddy_fl/widgets/signup_widgets/study_level.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool _isObscure = true; // State for password visibility
  bool _isObscureConfirmPassword = true;
  final AuthService _authService = AuthService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();
  bool loading = false;
  var _studyLevel;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 20),
                    // Logo
                    Image.asset(
                      'assets/sb_logo.png',
                      height: 120,
                    ),
                    SizedBox(height: 20),

                    // Sign in text
                    Text(
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 50),

                    //full name
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full Name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Email TextField
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        // Regular expression for validating emails that end with .ac.uk
                        String pattern =
                            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@(([a-zA-Z\-0-9]+\.)+ac\.uk)$';
                        RegExp regex = RegExp(pattern);
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!regex.hasMatch(value)) {
                          return 'Enter a valid university email address (ending with .ac.uk)';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                    SizedBox(height: 20),

                    // Selection of universities

                    UniversityAutocomplete(controller: _universityController),
                    SizedBox(height: 20),

                    // selection of university course
                    TextFormField(
                      controller: _courseController,
                      decoration: InputDecoration(
                        labelText: 'Enter your course',
                        prefixIcon: Icon(Icons.subject),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    SizedBox(height: 20),

                    StudyLevelSelector(
                      onSelectionChanged: (StudyLevel? level) {
                        _studyLevel = level;
                        print(_studyLevel);
                      },
                    ),

                    // Password TextField
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: _isObscure,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password'; // Check for non-empty input
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters'; // Check for minimum length
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                    SizedBox(height: 20),
                    // Confirm Password TextField
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscureConfirmPassword =
                                  !_isObscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: _isObscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (_passwordController.text != value) {
                          return 'Passwords do not match';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                    SizedBox(height: 20),

                    // Sign up Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // Indicate loading
                          setState(() {
                            loading = true;
                          });

                          // Extract study level string
                          String studyLevelString =
                              _studyLevel.toString().split('.').last;

                          // Attempt to sign up
                          String? signUpError = await _authService.signUp(
                            _emailController.text,
                            _passwordController.text,
                            _fullNameController.text,
                            _universityController.text,
                            _courseController.text,
                            studyLevelString,
                          );

                          if (signUpError == null) {
                            // Sign up was successful
                            setState(() {
                              loading = false;
                            });

                            // Navigate to the email verification page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VerifyEmailPage()),
                            );
                          } else {
                            // Sign up failed, show an error message
                            setState(() {
                              loading = false;
                            });
                            final snackBar =
                                SnackBar(content: Text(signUpError));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      child: Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Return to Login Screen
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text('Already have an account? Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
