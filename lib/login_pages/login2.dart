// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:study_buddy_fl/services/auth.dart';
import 'package:study_buddy_fl/widgets/reusable/loading.dart';

class Login2 extends StatefulWidget {
  @override
  _Login2State createState() => _Login2State();
}

class _Login2State extends State<Login2> {
  bool _isObscure = true; // State for password visibility
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

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
                    SizedBox(height: 20), // Adjust the size to fit your design
                    // Logo - Replace with your image asset
                    Image.asset(
                      'assets/sb_logo.png', // Replace with your logo asset path
                      height: 120, // Set your logo's height
                    ),
                    SizedBox(height: 20),

                    // Sign in text
                    Text(
                      'Sign in',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 50),

                    // Email TextField
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),

                    // Password TextField
                    TextField(
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
                    ),
                    SizedBox(height: 20),

                    // Forgot Password Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forget password functionality
                        },
                        child: Text('Forget Password?'),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Login Button
                    ElevatedButton(
                      onPressed: () async {
                        // Check if the form is valid
                        if (_formKey.currentState!.validate()) {
                          setState(() => loading = true);
                          // Form is valid, attempt to sign in
                          var user = await _authService.signIn(
                              _emailController.text, _passwordController.text);
                          if (user != null) {
                            // Sign in successful
                            Navigator.pushNamed(context, '/main_navigation');
                          } else {
                            // Sign in failed
                            setState(() => loading = false);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Sign in Failed'),
                                content: Text('Invalid email or password.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                      child: Text('Sign In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Divider (Or Log in with)
                    Row(
                      children: <Widget>[
                        Expanded(child: Divider(thickness: 2)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Or Sign in with'),
                        ),
                        Expanded(child: Divider(thickness: 2)),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Social Media Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // Google login button
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement Google login functionality
                          },
                          child: Image.asset(
                            'assets/google.png',
                            width:
                                24.0, // You can adjust the size to fit your design
                          ),
                        ),
                        // Facebook login button
                        GestureDetector(
                          onTap: () {
                            print('Facebook tapped');
                            // TODO: Implement Facebook login functionality
                          },
                          child: Image.asset(
                            'assets/facebook.png',
                            width: 24.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Sign Up Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text('Don\'t have account? Sign Up'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
