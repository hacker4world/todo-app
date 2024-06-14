import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ReportModal extends StatefulWidget {
  final Function(String, String) onSubmit;

  ReportModal({required this.onSubmit});

  @override
  _ReportModalState createState() => _ReportModalState();
}

class _ReportModalState extends State<ReportModal> {
  TextEditingController problemController = TextEditingController();
  TextEditingController solutionController = TextEditingController();
  File? _imageFile;
  String? _fileName;

  Future<void> _pickImageAndUpload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
        source: Platform.isAndroid ? ImageSource.camera : ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageFile = File(image.path);
      });

      final String uploadUrl = 'http://localhost:3000/upload';
      final Uri uri = Uri.parse(uploadUrl);
      final multipartRequest = http.MultipartRequest('POST', uri);
      multipartRequest.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        ),
      );

      try {
        final streamedResponse = await multipartRequest.send();
        final response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          setState(() {
            _fileName = data['fileName'];
          });
        } else {
          print('Failed to upload image: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

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
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImageAndUpload,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 10),
            _imageFile != null
                ? Image.file(_imageFile!)
                : Text('No image selected'),
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
