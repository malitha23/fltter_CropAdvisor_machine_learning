import 'dart:convert';
import 'dart:io';
import 'package:agriculture/screens/getCropsWithSimilarSoilType.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UploadedImageScreen extends StatefulWidget {
  const UploadedImageScreen({Key? key}) : super(key: key);

  @override
  State<UploadedImageScreen> createState() => _UploadedImageScreenState();
}

class _UploadedImageScreenState extends State<UploadedImageScreen> {
  String? _image; // Set the initial value to null
  int? successcode;
  Map<String, dynamic> jsonResponse = {};
  bool loaderimageresponse = false;
  Future<void> _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      jsonResponse = {};
    });
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);

      if (pickedImage != null) {
        final imageFile = File(pickedImage.path);
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        _postImage(base64Image, pickedImage.path);

        // _postImage(base64Image);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _postImage(String base64Image, String imagePath) async {
    setState(() {
      loaderimageresponse = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    const String apiUrl = 'https://python.lovebird4u.com/getresponse';
    print(base64Image);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode({"image": base64Image}),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        successcode = response.statusCode;
        print('Image uploaded successfully');
        setState(() {
          jsonResponse = json.decode(response.body);
          loaderimageresponse = false;
          _image = imagePath;
        });
      } else {
        print('Failed to upload image: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          loaderimageresponse = false;
          successcode = response.statusCode;
        });
      }
    } catch (e) {
      setState(() {
        loaderimageresponse = false;
        successcode = 100;
      });
      print('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double? confidenceScore = jsonResponse?[
        'confidence_score']; // Assuming confidence_score is a double
    String? predictedClass = jsonResponse?[
        'predicted_class']; // Assuming predicted_class is a string

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center the content vertically
        children: [
          loaderimageresponse
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: LoadingAnimationWidget.stretchedDots(
                      color: Color.fromRGBO(5, 183, 119, 1),
                      size: 40,
                    ), // Display loader
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Center the buttons horizontally
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
          // ElevatedButton(
          //   onPressed: () async {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => getCropsWithSimilarSoilType(
          //               soilType: predictedClass.toString())),
          //     );
          //   },
          //   child: Text('Find the crops'),
          // ),
          SizedBox(height: 16),
          !loaderimageresponse
              ? Column(
                  children: [
                    successcode != null
                        ? Column(
                            children: [
                              successcode == 200
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal:
                                                  15), // Set left and right padding to 15
                                          child: Column(
                                            children: [
                                              Center(
                                                child: _image != null
                                                    ? (kIsWeb
                                                        ? Image.network(
                                                            _image!,
                                                            width:
                                                                200, // Set your desired width
                                                            height:
                                                                200, // Set your desired height
                                                            fit: BoxFit
                                                                .cover, // Adjust the fit as needed
                                                          )
                                                        : Image.file(
                                                            File(_image!),
                                                            width:
                                                                200, // Set your desired width
                                                            height:
                                                                200, // Set your desired height
                                                            fit: BoxFit
                                                                .cover, // Adjust the fit as needed
                                                          ))
                                                    : Text('No image selected'),
                                              ),
                                              if (confidenceScore != null &&
                                                  predictedClass != null)
                                                Column(
                                                  children: [
                                                    SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text(
                                                        'Confidence Score: $confidenceScore'),
                                                    Text(
                                                        'Predicted Class: $predictedClass'),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        SizedBox(
                                            child: _image != null
                                                ? ElevatedButton(
                                                    onPressed: () async {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                getCropsWithSimilarSoilType(
                                                                    soilType:
                                                                        predictedClass
                                                                            .toString())),
                                                      );
                                                    },
                                                    child:
                                                        Text('Find the crops'),
                                                  )
                                                : null),
                                      ],
                                    )
                                  : (successcode == 404 || successcode == 502
                                      ? Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                      15), // Set left and right padding to 15
                                              child: Center(
                                                child: _image != null
                                                    ? (kIsWeb
                                                        ? Image.network(
                                                            _image!,
                                                            width:
                                                                200, // Set your desired width
                                                            height:
                                                                200, // Set your desired height
                                                            fit: BoxFit
                                                                .cover, // Adjust the fit as needed
                                                          )
                                                        : Image.file(
                                                            File(_image!),
                                                            width:
                                                                200, // Set your desired width
                                                            height:
                                                                200, // Set your desired height
                                                            fit: BoxFit
                                                                .cover, // Adjust the fit as needed
                                                          ))
                                                    : Text(
                                                        'Model is not found, Please run model and try again!'),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal:
                                                      15), // Set left and right padding to 15
                                              child: Center(
                                                child: _image != null
                                                    ? (kIsWeb
                                                        ? Image.network(
                                                            _image!,
                                                            width:
                                                                200, // Set your desired width
                                                            height:
                                                                200, // Set your desired height
                                                            fit: BoxFit
                                                                .cover, // Adjust the fit as needed
                                                          )
                                                        : Image.file(
                                                            File(_image!),
                                                            width:
                                                                200, // Set your desired width
                                                            height:
                                                                200, // Set your desired height
                                                            fit: BoxFit
                                                                .cover, // Adjust the fit as needed
                                                          ))
                                                    : Text(
                                                        'Server error, Please Try Again'),
                                              ),
                                            ),
                                          ],
                                        ))
                            ],
                          )
                        : Container()
                  ],
                )
              : Container()
        ],
      ),
    );
  }
}
