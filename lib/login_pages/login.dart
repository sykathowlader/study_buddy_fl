// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:study_buddy_fl/login_pages/verify_email.dart';
import 'package:study_buddy_fl/services/auth.dart';
import 'package:study_buddy_fl/widgets/reusable/loading.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isObscure = true; // State for password visibility
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); // helps managing the state of a form from anywhere in the widget
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
              //creating the form for email and password
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: 20),
                    // Logo of Study Buddy
                    Image.asset(
                      'assets/sb_logo.png',
                      height: 120, // logo's height
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

                    // Password TextField with lock icon
                    // password can be obscured
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
                          Navigator.pushNamed(context, '/reset_password');
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
                            if (!user.emailVerified) {
                              // If user's email is not verified, navigate to VerifyEmailPage
                              setState(() => loading = false);
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => VerifyEmailPage()));
                            } else {
                              // If email is verified, navigate to main navigation
                              Navigator.pushReplacementNamed(
                                  context, '/main_navigation');
                            }
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

                    /* // Divider (Or Sign in with)
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
                    ), */
                    //SizedBox(height: 30),

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
