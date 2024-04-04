import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class datainputform2 extends StatefulWidget {
  const datainputform2({super.key});

  @override
  State<datainputform2> createState() => _datainputform2State();
}

class _datainputform2State extends State<datainputform2> {
  List<File> selectedImages = [];
  bool selectingFirstImage = true; // Track if selecting first or second image
  List<String> base64EncodedImages = [];
  bool isLoading = false;
  TextEditingController diseaseNameController = TextEditingController();
  TextEditingController cropNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController solutionController = TextEditingController();

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final List<int> imageBytes = await pickedImage.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      setState(() {
        selectedImages.add(File(pickedImage.path));
        base64EncodedImages.add(base64Image);
        selectingFirstImage =
            !selectingFirstImage; // Toggle between first and second image
      });
    }
  }

  void _sendDataToApi() async {
    setState(() {
      isLoading = true;
    });
    // Prepare your request body
    Map<String, dynamic> requestBody = {
      'diseaseName': diseaseNameController.text,
      'cropName': cropNameController.text,
      'description': descriptionController.text,
      'solution': solutionController.text,
      'images': base64EncodedImages,
    };

    // Make the POST request
    final response = await http.post(
      Uri.parse(
          'https://foodappbackend.jaffnamarriage.com/public/api/storedisease'),
      body: json.encode(requestBody),
      headers: {'Content-Type': 'application/json'},
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      // Handle the response as needed
      print('Data sent successfully');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Form data submitted successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Handle error response
      print('Failed to send data. Error: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Form data submitted not successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Image of Disease (2 images)',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectingFirstImage =
                        true; // Set flag to select first image
                  });
                  _selectImage();
                },
                child: Text('Select Images'),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (selectedImages.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedImages
                  .map((image) => SizedBox(
                        width: 100,
                        height: 100,
                        child: kIsWeb
                            ? Image.network(image.path, fit: BoxFit.cover)
                            : Image.file(image, fit: BoxFit.cover),
                      ))
                  .toList(),
            ),
          SizedBox(height: 16),
          TextField(
            controller: diseaseNameController,
            decoration: InputDecoration(
              labelText: 'Disease name',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: cropNameController,
            decoration: InputDecoration(
              labelText: 'Crop name',
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
            ),
            maxLines: 3, // Allow multiple lines for description
          ),
          SizedBox(height: 16),
          TextField(
            controller: solutionController,
            decoration: InputDecoration(
              labelText: 'Solution',
            ),
            maxLines: 3, // Allow multiple lines for solution
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              _sendDataToApi();
            },
            child: Text(
              isLoading ? 'Submitting...' : 'Submit',
            ),
          ),
        ],
      ),
    );
  }
}
