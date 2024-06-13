import 'package:flutter/material.dart';

class ReportModal extends StatefulWidget {
  final Function(String, String) onSubmit;

  ReportModal({required this.onSubmit});

  @override
  _ReportModalState createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  TextEditingController problemController = TextEditingController();
  TextEditingController solutionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report problem'),
      content: Container(
        width: double.maxFinite, // Take up full width of the AlertDialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: problemController,
              decoration: InputDecoration(labelText: 'Problem'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: solutionController,
              decoration: InputDecoration(labelText: 'Solution'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Submit'),
          onPressed: () {
            String problem = problemController.text;
            String solution = solutionController.text;
            widget.onSubmit(problem, solution);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
