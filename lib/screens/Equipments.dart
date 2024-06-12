import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/widgets/Sidenav.dart';

class EquipmentsScreen extends StatefulWidget {
  @override
  _EquipmentsScreenState createState() => _EquipmentsScreenState();
}

class _EquipmentsScreenState extends State<EquipmentsScreen> {
  List<Equipment> _equipments = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _fetchEquipments();
  }

  void _fetchEquipments() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final String? checklistId = prefs.getString('checklist_id');
      final response = await http.get(Uri.parse(
          'http://localhost:3000/equipments?checklistID=$checklistId'));

      if (response.statusCode == 200) {
        final List<dynamic> equipmentsData = json.decode(response.body);
        final List<Equipment> loadedEquipments = equipmentsData
            .map((equipmentData) => Equipment.fromJson(equipmentData))
            .toList();

        setState(() {
          _equipments = loadedEquipments;
        });
      } else {
        throw Exception('Failed to load equipments');
      }
    } catch (error) {
      print('Error fetching equipments: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Equipments',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: SideNav(onNavItemTap: (String item) {
        // Handle navigation actions here
        Navigator.pop(context); // Close the drawer
      }),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: TextFormField(
                enabled: false,
                initialValue: 'Equipment List',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Equipment Name')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Room ID')),
                  DataColumn(label: Text('Equipment ID')),
                ],
                rows: _equipments.map((equipment) {
                  return DataRow(cells: [
                    DataCell(Text(equipment.equipmentName)),
                    DataCell(Text(equipment.createdAt)),
                    DataCell(Text(equipment.roomID.toString())),
                    DataCell(Text(equipment.equipmentID.toString())),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Equipment {
  final int equipmentID;
  final int roomID;
  final String equipmentName;
  final int checklistID;
  final String createdAt;
  final String updatedAt;

  Equipment({
    required this.equipmentID,
    required this.roomID,
    required this.equipmentName,
    required this.checklistID,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      equipmentID: json['equipmentID'],
      roomID: json['roomID'],
      equipmentName: json['equipmentName'],
      checklistID: json['checklistID'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
