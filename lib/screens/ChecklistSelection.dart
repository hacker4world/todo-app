import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/screens/Tasks.dart';

class ChecklistSelection extends StatefulWidget {
  @override
  _ChecklistSelectionState createState() => _ChecklistSelectionState();
}

class _ChecklistSelectionState extends State<ChecklistSelection> {
  TextEditingController _numberController = TextEditingController();
  String _errorMessage = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  void _seeTasks() async {
    setState(() {
      _errorMessage = '';
    });

    final String numberText = _numberController.text.trim();
    if (numberText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a number';
      });
      return;
    }

    // Check if the entered value is a number
    try {
      int.parse(numberText);
    } catch (e) {
      setState(() {
        _errorMessage = 'Please enter a valid number';
      });
      return;
    }

    final String apiUrl = 'http://localhost:3000/checklists/' + numberText;
    final url = Uri.parse(apiUrl);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final SharedPreferences prefs = await _prefs;
        prefs
            .setString('checklist_id', _numberController.text)
            .then((bool success) {
          final responseData = json.decode(response.body);
          final checklistType = responseData['checklistType'];
          prefs
              .setString('checklist_type', checklistType.toString())
              .then((bool success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TasksScreen()),
            );
          });
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Checklist was not found';
        });
      }
    } catch (error) {
      // Handle errors that occur during the request
      print('Error sending request: $error');
    }
    // Perform action for "See Tasks" button
    print('See Tasks button pressed with number: $numberText');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (_errorMessage.isNotEmpty) ...[
              Container(
                color: Colors.red,
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
            ],
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter checklist id', // Updated label
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _seeTasks,
              child: Text('See Tasks'),
            ),
          ],
        ),
      ),
    );
  }
}
