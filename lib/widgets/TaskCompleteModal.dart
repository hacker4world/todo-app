import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CompleteTaskModal extends StatefulWidget {
  final Function onComplete;

  CompleteTaskModal({required this.onComplete});

  @override
  _CompleteTaskModalState createState() => _CompleteTaskModalState();
}

class _CompleteTaskModalState extends State<CompleteTaskModal> {
  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> _getImage() async {
    final pickedFile = await _imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _markAsComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('user_id');
    final String? branchId = prefs.getString('branch_id');

    final String? checklistId = prefs.getString('checklist_id');
    final String imageString = base64Encode(_image!.readAsBytesSync());
    final Map<String, dynamic> requestBody = {
      'userID': userId,
      'photo': imageString,
      "okay": 1,
      "problem": null,
      "solution": null,
      "date": DateTime.now().toIso8601String(),
      "taskID": prefs.getInt('task_id'),
    };

    String requestBodyJson = json.encode(requestBody);

    // Set up the POST request
    final response = await http.post(
      Uri.parse('http://localhost:3000/donetasks'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBodyJson,
    );

    if (response.statusCode == 201) {
      // Notify TasksScreen about the completion
      widget.onComplete(prefs.getInt('task_id'));
      Navigator.pop(context); // Close the modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Submit Task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  height: 150,
                  color: Colors.grey[200],
                  child: _image == null
                      ? Center(child: Text('Tap to select an image'))
                      : Image.file(_image!),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _markAsComplete,
                child: Text('Mark task as complete'),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
