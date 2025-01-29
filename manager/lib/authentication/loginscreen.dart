// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manager/authentication/signupscreen.dart';
import 'package:manager/mainscreens/homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  void login() async {
    try {
      // Authenticate the user using Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Successful login, redirect to HomePage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Show error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Failed'),
          content: Text(e.toString()), // Display error message
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50.0),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Business Email'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: login,
              child: const Text('Log In'),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to SignupScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
                TextButton(
                  onPressed: () {
                    // Implement logic for forgot password here
                    // This usually involves a dialog to enter the email
                  },
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
