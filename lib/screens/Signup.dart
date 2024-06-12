import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Uint8List? _imageBytes; // Variable to store the selected image bytes
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _branchIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool? _success = false;

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
          final Uint8List data = Uint8List.fromList(base64.decode(parts[1]));

          setState(() {
            _imageBytes = data;
          });
        });
      }
    });
  }

  void _signUp() {
    setState(() {
      _errorMessage = null;
      _success = false;
    });
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Password and confirmation do not match';
        });
        return;
      }

      String? base64Image;
      if (_imageBytes != null) {
        base64Image = base64Encode(_imageBytes!);
      }

      final formData = {
        'name': _nameController.text,
        "username": _usernameController.text,
        'CIN': _cinController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': "",
        "branchID": int.parse(_branchIdController.text),
        'photo': base64Image,
      };

      print(formData);

      final String apiUrl = 'http://localhost:3000/users/signup';
      final url = Uri.parse(apiUrl); // Replace with your backend URL

      http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(formData),
      )
          .then((response) {
        if (response.statusCode == 201) {
          setState(() {
            _success = true;
          });
          print('User signed up successfully');
        } else if (response.statusCode == 409) {
          setState(() {
            _errorMessage = 'A user with the given username already exists';
          });
        } else {
          print('Failed to sign up: ${response.body}');
        }
      }).catchError((error) {
        print('Error sending request: $error');
      });
    } else {
      setState(() {
        _errorMessage = 'All fields are required';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_errorMessage != null) ...[
                  Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.white),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
                if (_success == true) ...[
                  Container(
                    color: Colors.green,
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.white),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            "Your account has been created and is awaiting admin approval",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _cinController,
                  decoration: InputDecoration(labelText: 'CIN'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your CIN';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _branchIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(labelText: 'Branch ID'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your branch ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(labelText: 'Confirm password'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Select Photo'),
                ),
                SizedBox(height: 16.0),
                _imageBytes == null
                    ? Text('No image selected')
                    : Image.memory(_imageBytes!),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
