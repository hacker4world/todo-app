import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testing/widgets/Sidenav.dart';
import 'package:testing/widgets/TaskCompleteModal.dart'; // Update the import path if necessary

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void _openCompleteTaskModal(int taskId) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt('task_id', taskId);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => CompleteTaskModal(
        onComplete: _removeTaskById,
      ),
    );
  }

  void _removeTaskById(int? taskId) {
    print(taskId);
    setState(() {
      _tasks.removeWhere((task) => task.taskID == taskId);
    });
    print(_tasks);
  }

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final String? checklistId = prefs.getString('checklist_id');
      final response = await http.get(
          Uri.parse('http://localhost:3000/tasks?checklistID=' + checklistId!));
      final doneTasksResponse =
          await http.get(Uri.parse('http://localhost:3000/donetasks'));

      if (response.statusCode == 200) {
        final List<dynamic> tasksData = json.decode(response.body);
        final List<dynamic> doneTasksData = json.decode(doneTasksResponse.body);

        // Extract taskIDs from doneTasksData
        final List<int> doneTaskIDs =
            doneTasksData.map<int>((task) => task['taskID']).toList();

        // Filter out tasks that are completed
        final List<Task> filteredTasks = tasksData
            .map((taskData) => Task.fromJson(taskData))
            .where((task) => !doneTaskIDs.contains(task.taskID))
            .toList();

        setState(() {
          _tasks = filteredTasks;
        });
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (error) {
      print('Error fetching tasks: $error');
    }
  }

  void _markAsComplete(int index) {
    setState(() {
      _tasks[index].isComplete = true;
    });
  }

  void _reportProblem(int index) {
    // Handle reporting a problem with the task
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Problem reported for ${_tasks[index].title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: TextStyle(color: Colors.white), // Set text color to white
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
                enabled: false, // Set input field as disabled
                initialValue: 'Daily Checklist',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color:
                      Colors.grey[700], // Adjust the color to your preference
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
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _tasks.map((task) {
                  int index = _tasks.indexOf(task);
                  return DataRow(cells: [
                    DataCell(Text(task.title)),
                    DataCell(Text(task.createdAt)),
                    DataCell(
                      Row(
                        children: [
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.green, // Change the color to green
                              BlendMode.srcIn,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.check_circle_outline),
                              onPressed: () =>
                                  _openCompleteTaskModal(task.taskID),
                            ),
                          ),
                          ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.red, // Change the color to red
                              BlendMode.srcIn,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.report_problem),
                              onPressed: () => _reportProblem(index),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class Task {
  final String title;
  final String createdAt;
  final int taskID;
  bool isComplete;

  Task({
    required this.taskID,
    required this.title,
    required this.createdAt,
    this.isComplete = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskID: json['taskID'],
      title: json['taskTitle'], // Ensure this matches your JSON structure
      createdAt: json['createdAt'] ??
          '', // Handle cases where 'createdAt' might be null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskID': taskID,
      'taskTitle': title,
      'createdAt': createdAt,
      'isComplete': isComplete,
    };
  }
}
