import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'bill_split_screen.dart';
import 'ocr_service.dart'; // OCR handling

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  GroupScreenState createState() => GroupScreenState();
}

class GroupScreenState extends State<GroupScreen> {
  List<String> groupNames = [];
  XFile? _receiptImage;
  String extractedText = '';
  final TextEditingController _controller = TextEditingController(); // Controller for text input

  void _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptImage = image;
      });
      // Extract text from the image using OCR
      extractedText = await extractTextFromReceipt(image);
    }
  }

  void _addGroupNames() {
    final input = _controller.text.trim(); // Get the entered text
    if (input.isNotEmpty) {
      // Split the input by commas and trim each name
      final names = input.split(',').map((name) => name.trim()).toList();
      setState(() {
        groupNames.addAll(names); // Add the new names to the groupNames list
        _controller.clear(); // Clear the text field after adding
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Share The Tab")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group names input
              TextField(
                controller: _controller, // Controller linked to the text field
                decoration: InputDecoration(labelText: "Enter Group Names (comma separated)"),
                onSubmitted: (value) => _addGroupNames(),
              ),
              const SizedBox(height: 16),
              // Show added group names in a ListView
              if (groupNames.isNotEmpty)
                SizedBox(
                  height: 200, // Set a fixed height for the ListView
                  child: ListView.builder(
                    shrinkWrap: true, // Allow ListView to take only the required space
                    physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
                    itemCount: groupNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(groupNames[index]),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              // Receipt image picker
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Receipt'),
              ),
              if (_receiptImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(File(_receiptImage!.path)),
                ),
              // Submit button
              ElevatedButton(
                onPressed: () {
                  if (_receiptImage != null) {
                      print("Group names being passed: $groupNames");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BillSplitScreen(
                          groupNames: groupNames,
                          extractedText: extractedText,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please upload a receipt before submitting.')),
                    );
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}