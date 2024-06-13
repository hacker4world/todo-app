import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RoomSelect extends StatefulWidget {
  @override
  _RoomSelectState createState() => _RoomSelectState();
}

class _RoomSelectState extends State<RoomSelect> {
  List<Map<String, dynamic>> _rooms = [];
  int? _selectedRoomId;
  String? _selectedRoomName;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  void _fetchRooms() async {
    final String apiUrl = 'http://localhost:3000/rooms';
    final url = Uri.parse(apiUrl);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _rooms = data.cast<Map<String, dynamic>>();
        });
      } else {
        print('Failed to load rooms: ${response.statusCode}');
        // Handle error loading rooms
      }
    } catch (e) {
      print('Error loading rooms: $e');
      // Handle network error
    }
  }

  void _selectRoom() async {
    if (_selectedRoomId != null && _selectedRoomName != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('room_id', _selectedRoomId!);
      await prefs.setString('room_name', _selectedRoomName!);

      // Navigate to tasks page
      Navigator.pushReplacementNamed(context, '/tasks');
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select a room first.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Room'),
      ),
      body: _rooms.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  DropdownButtonFormField<int>(
                    value: _selectedRoomId,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedRoomId = value;
                        _selectedRoomName = _rooms.firstWhere(
                            (room) => room['roomID'] == value)['roomName'];
                      });
                    },
                    items: _rooms.map((room) {
                      return DropdownMenuItem<int>(
                        value: room['roomID'],
                        child: Text(room['roomName']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Room',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a room';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _selectRoom,
                    child: Text('Select Room'),
                  ),
                ],
              ),
            ),
    );
  }
}
