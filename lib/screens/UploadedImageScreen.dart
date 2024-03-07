import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UploadedImageScreen extends StatefulWidget {
  const UploadedImageScreen({Key? key}) : super(key: key);

  @override
  State<UploadedImageScreen> createState() => _UploadedImageScreenState();
}

class _UploadedImageScreenState extends State<UploadedImageScreen> {
  String? _image; // Set the initial value to null

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) {
        _image = pickedImage.path;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the content vertically
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center the buttons horizontally
            children: [
              FloatingActionButton(
                onPressed: () => _getImage(ImageSource.camera),
                tooltip: 'Capture Image',
                child: Icon(Icons.camera),
              ),
              SizedBox(width: 16),
              FloatingActionButton(
                onPressed: () => _getImage(ImageSource.gallery),
                tooltip: 'Pick Image from Gallery',
                child: Icon(Icons.photo_library),
              ),
            ],
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 15), // Set left and right padding to 15
            child: Center(
              child: _image != null
                  ? (kIsWeb
                      ? Image.network(
                          _image!,
                          width: 200, // Set your desired width
                          height: 200, // Set your desired height
                          fit: BoxFit.cover, // Adjust the fit as needed
                        )
                      : Image.file(
                          File(_image!),
                          width: 200, // Set your desired width
                          height: 200, // Set your desired height
                          fit: BoxFit.cover, // Adjust the fit as needed
                        ))
                  : Text('No image selected'),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
              child: _image != null
                  ? ElevatedButton(
                      onPressed: () async {},
                      child: Text('Find the crops'),
                    )
                  : null),
        ],
      ),
    );
  }
}
