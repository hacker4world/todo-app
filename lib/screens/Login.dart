import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    // Validate the form fields
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      // Show an error message or handle validation as needed
      return;
    }

    // Prepare the form data
    final formData = {
      'email': _usernameController.text,
      'password': _passwordController.text,
    };

    // Send the POST request to the backend
    final String apiUrl = 'http://localhost:3000/users/login';
    final url = Uri.parse(apiUrl); // Replace with your backend URL

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      );

      // Handle the response from the backend
      if (response.statusCode == 200) {
        // Login successful
        final responseData = json.decode(response.body);
        final userId = responseData['userId'];
        final role = responseData['role'];

        // Navigate to the next screen or perform other actions
        print('Login successful: User ID - $userId, Role - $role');
      } else {
        // Login failed
        print('Login failed: ${response.body}');
        // Show an error message or handle the failure as needed
      }
    } catch (error) {
      // Handle errors that occur during the request
      print('Error sending request: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
