import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/widgets/Sidenav.dart';

class CompletedTasksScreen extends StatefulWidget {
  @override
  _CompletedTasksScreenState createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  List<Task> completedTasks = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedTasks();
  }

  Future<void> fetchCompletedTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? checklistId = prefs.getString('checklist_id');

    final tasksResponse = await http
        .get(Uri.parse('http://localhost:3000/tasks?checklistID=$checklistId'));
    final doneTasksResponse =
        await http.get(Uri.parse('http://localhost:3000/donetasks'));

    if (tasksResponse.statusCode == 200 &&
        doneTasksResponse.statusCode == 200) {
      List<Task> tasks = (json.decode(tasksResponse.body) as List)
          .map((task) => Task.fromJson(task))
          .toList();

      List<String> doneTaskIds =
          (json.decode(doneTasksResponse.body) as List).cast<String>();

      setState(() {
        completedTasks =
            tasks.where((task) => doneTaskIds.contains(task.id)).toList();
      });
    } else {
      throw Exception('Failed to load completed tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks'),
      ),
      drawer: SideNav(onNavItemTap: (String item) {
        // Handle navigation actions here
        Navigator.pop(context); // Close the drawer
      }),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: <DataColumn>[
            DataColumn(
              label: Text('Title'),
            ),
            DataColumn(
              label: Text('Created At'),
            ),
            DataColumn(
              label: Text('Problem'),
            ),
            DataColumn(
              label: Text('Solution'),
            ),
            DataColumn(
              label: Text('User ID'),
            ),
          ],
          rows: completedTasks.map((task) {
            return DataRow(
              cells: <DataCell>[
                DataCell(Text(task.title)),
                DataCell(Text(task.createdAt)),
                DataCell(Text(task.problem)),
                DataCell(Text(task.solution)),
                DataCell(Text(task.userId)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String createdAt;
  final String problem;
  final String solution;
  final String userId;

  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.problem,
    required this.solution,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      createdAt: json['createdAt'],
      problem: json['problem'],
      solution: json['solution'],
      userId: json['userId'],
    );
  }
}
