import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;


import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
   
}

class _SignUpScreenState extends State<SignUpScreen> {
  Uint8List? _imageBytes; // Variable to store the selected image bytes
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _cinController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _pickImage() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement();
    input.accept = 'image/*';
    input.click();

    input.onChange.listen((event) {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final reader = html.FileReader();
        reader.readAsDataUrl(files[0]);
        reader.onError.listen((error) => setState(() {
              // Handle any error that occurs while reading the file
            }));
        reader.onLoad.first.then((event) {
          final result = reader.result as String;
          final List<String> parts = result.split(',');
          final String contentType = parts[0].split(':')[1].split(';')[0];
          final Uint8List data = Uint8List.fromList(
              parts[1].codeUnits.map((c) => c & 0xff).toList());

          setState(() {
            _imageBytes = data;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _cinController,
                decoration: InputDecoration(labelText: 'CIN'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              ElevatedButton(
                onPressed: _pickImage, // Call _pickImage function to select image
                child: Text('Select Photo'),
              ),
              _imageBytes == null
                  ? Text('No image selected')
                  : Image.memory(_imageBytes!), // Display selected image if available
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                   // Validate the form fields
    /* if (_nameController.text.isEmpty ||
        _cinController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _imageBytes == null) {
      // Show an error message or handle validation as needed
      return;
    } */

    // Prepare the form data
    final formData = {
      'name': _nameController.text,
      "username": _usernameController.text,
      'CIN': _cinController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'role': "",
      "branchID": 1
    };
  final String apiUrl = 'http://localhost:3000/users/signup';
    // Send the POST request to the backend
    final url = Uri.parse(apiUrl); // Replace with your backend URL
    http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(formData),
    ).then((response) {
      // Handle the response from the backend
      if (response.statusCode == 200) {
        // User signed up successfully
        print('User signed up successfully');
      } else {
        // Failed to sign up
        print('Failed to sign up: ${response.body}');
      }
    }).catchError((error) {
      // Handle errors that occur during the request
      print('Error sending request: $error');
    });
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
