import 'package:flutter/material.dart';

// Define a model class to represent a task
class Task {
  final String name;
  final String description;

  Task({required this.name, required this.description});
}

class TasksScreen extends StatelessWidget {
  // Sample list of tasks (replace with your actual data)
  final List<Task> tasks = [
    Task(name: 'Task 1', description: 'Description for Task 1'),
    Task(name: 'Task 2', description: 'Description for Task 2'),
    Task(name: 'Task 3', description: 'Description for Task 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          // Build each list item using ListTile
          return ListTile(
            title: Text(tasks[index].name),
            subtitle: Text(tasks[index].description),
            // Add any onTap logic here
            onTap: () {
              // This callback will be triggered when a task item is tapped
              // Add navigation or any other logic you want to perform
            },
          );
        },
      ),
    );
  }
}
